package main

import (
	"log"
	"net/http"

	"github.com/bitly/go-simplejson"
	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/pborman/uuid"
)

// Meeting represents information about dogs.
type Meeting struct {
	Room    string
	Locked  bool
	Clients map[*websocket.Conn]*Client
}

// Client is a struct that has connections;
type Client struct {
	SessionID string
	Resources ClientResources
}

// ClientResources is stream resources that sits in client
type ClientResources struct {
	Screen bool `json:"screen"`
	Video  bool `json:"video"`
	Audio  bool `json:"audio"`
}

var allMeetings map[string]*Meeting

func getDefaultClientResources() ClientResources {
	return ClientResources{Screen: false, Video: true, Audio: false}
}

var roomTemplate = LoadView("room")
var homeTemplate = LoadView("home")
var roomSecureTemplate = LoadView("room-secure")

/*
func (meeting *Meeting) getPeerSessionIds() []string {
	peers := []string{}
	for _, peer := range meeting.Clients {
		peers = append(peers, peer.SessionID)
	}
	return peers
}*/
func (meeting *Meeting) getNumberOfClients() int {
	return len(meeting.Clients)
}

func (meeting *Meeting) getConn(sessionid string) *websocket.Conn {
	for conn, client := range meeting.Clients {
		if client.SessionID == sessionid {
			return conn
		}
	}
	return nil
}

func (meeting *Meeting) describeMeeting(thisConn *websocket.Conn) []byte {
	clients := simplejson.New()
	for conn, client := range meeting.Clients {
		if conn != thisConn {
			clients.Set(client.SessionID, client.Resources)
		}
	}
	data := simplejson.New()
	data.Set("roomDescription", clients)
	joinMsg := simplejson.New()
	joinMsg.Set("event", "_join")
	joinMsg.Set("data", data)
	msg, err := joinMsg.MarshalJSON()
	if err != nil {
		return []byte(`{"event":"_join","data":{"err":"Json marshal error"}}`)
	}
	return msg
}

func (meeting *Meeting) removeFeed(thisConn *websocket.Conn, tp string) {
	thisClient := meeting.Clients[thisConn]
	if thisClient != nil {
		if len(tp) == 0 {
			meeting.removeClient(thisConn)
		} else {
			removeMsg := getRemoveFeedMessage(thisClient.SessionID, tp)
			for conn := range meeting.Clients {
				if conn != thisConn {
					if err := conn.WriteMessage(websocket.TextMessage, removeMsg); err != nil {
						meeting.removeClient(conn)
					}
				}
			}
		}
	}
}

func (meeting *Meeting) removeClient(thisConn *websocket.Conn) {
	defer thisConn.Close()
	thisClient := meeting.Clients[thisConn]
	if thisClient != nil {
		delete(meeting.Clients, thisConn)
		if len(meeting.Clients) > 0 {
			// TODO: Notify other users
			for clientConnection := range meeting.Clients {
				if err := clientConnection.WriteMessage(websocket.TextMessage, getRemoveClientMessage(thisClient.SessionID)); err != nil {
					meeting.removeClient(clientConnection)
				}
			}
		} else {
			delete(allMeetings, meeting.Room)
		}
	}
}

func entranceHandler(w http.ResponseWriter, r *http.Request) {
	w.Write(homeTemplate)
}
func roomHandler(w http.ResponseWriter, r *http.Request) {
	roomPath := mux.Vars(r)["room"]
	log.Println(roomPath)
	if len(roomPath) < 3 { // roomPath is not available or not valid
		w.Write([]byte("Invalid room url"))
	} else {
		w.Write(roomTemplate)
	}
}

func roomSecureHandler(w http.ResponseWriter, r *http.Request) {
	roomPath := mux.Vars(r)["room"]
	log.Println(roomPath)
	if len(roomPath) < 3 { // roomPath is not available or not valid
		w.Write([]byte("Invalid room url"))
	} else {
		w.Write(roomSecureTemplate)
	}
}

func roomMessageHandler(meeting *Meeting, rawMsg []byte, thisConn *websocket.Conn) {
	log.Println("Message received from client:" + meeting.Room)
	log.Println(string(rawMsg))
	clientMessage, err := simplejson.NewJson(rawMsg)
	if err != nil {
		log.Println("Json parsing error")
		return
	}
	if thisClient := meeting.Clients[thisConn]; thisClient != nil {
		switch clientMessage.Get("event").MustString() {
		case "join":
			if rm := clientMessage.Get("data").MustString(); rm == meeting.Room {
				// Send a join message with room description
				if err := thisConn.WriteMessage(websocket.TextMessage, meeting.describeMeeting(thisConn)); err != nil {
					log.Println("Error sending join message with room description")
					meeting.removeClient(thisConn)
				}
			} else {
				log.Println("Might be a hack! room to join is different!")
			}
		case "message":
			if details := clientMessage.Get("data"); details != nil {
				if to := details.Get("to").MustString(); len(to) > 0 {
					if otherClientConn := meeting.getConn(to); otherClientConn != nil {
						details.Set("from", thisClient.SessionID)
						clientMessage.Set("data", details)
						newMsg, err := clientMessage.MarshalJSON()
						if err != nil {
							log.Println("Forwarding Message: Marshal json error!")
							return
						}
						if err := otherClientConn.WriteMessage(websocket.TextMessage, newMsg); err != nil {
							log.Println("Forwarding Message socket error!")
							return
						}
					} else {
						log.Println("No target connection found!")
					}
				} else {
					log.Println("No ~to~ attribute specified in data!")
				}
			} else {
				log.Println("No data field in raw message")
			}
		case "shareScreen":
			thisClient.Resources.Screen = true
		case "unshareScreen":
			thisClient.Resources.Screen = false
			meeting.removeFeed(thisConn, "screen")
		case "leave":
			meeting.removeClient(thisConn)
		case "disconnect":
			meeting.removeClient(thisConn)
		case "trace": // Log all the bugs
			log.Println("Trace:")
			log.Println(clientMessage.Get("data").MarshalJSON())
		// case "create":
		// case "join"
		default:
			log.Println("Unknown message received")
		}
	}

}

func lockRoom(meeting *Meeting, lockFlag bool) {
	//lockRoom(meeting, clientMessage.Get("flag").MustBool())
	if meeting.Locked != lockFlag {
		meeting.Locked = lockFlag
		// TODO broadcast a lock state change message;
		log.Println("Meeting lock state changed.")
	}
}

func socketHandler(w http.ResponseWriter, r *http.Request) {
	roomPath := mux.Vars(r)["room"]
	conn, err := websocket.Upgrade(w, r, nil, 1024, 1024)
	defer removeConnectionFromRoom(conn, roomPath) // Gauranteed removal of a connection
	if err == nil {
		if len(roomPath) > 2 {
			meeting := addClientToRoom(roomPath, conn)
			for {
				_, msg, readErr := conn.ReadMessage()
				if readErr == nil {
					roomMessageHandler(meeting, msg, conn)
				} else {
					log.Println("Socket read error(This socket might be dropped):")
					log.Println(readErr)
					return
				}
			}
		}
	} else {
		log.Println("Socket connection error: ")
		log.Println(err)
	}
}

func getMeeting(room string) *Meeting {
	return allMeetings[room]
}

func createClient() *Client {
	sessionid := uuid.NewRandom().String()
	return &Client{SessionID: sessionid, Resources: getDefaultClientResources()}
}

func addClientToRoom(room string, conn *websocket.Conn) *Meeting {
	meeting := getMeeting(room)
	client := createClient()

	// Send connect event with information
	if err := conn.WriteMessage(websocket.TextMessage, getConnectMessage(client.SessionID)); err != nil {
		log.Println("Error sending connect message with turn and stun information")
		conn.Close()
	}

	if meeting == nil {
		log.Println("Meeting not found, creating: " + room)
		meeting = createMeeting(room, conn, client)
	} else {
		log.Println("Meeting found: " + room)
		meeting.Clients[conn] = client
		log.Println("Client added")
	}
	return meeting
}

func removeConnectionFromRoom(conn *websocket.Conn, room string) {
	meeting := getMeeting(room)
	if meeting == nil {
		conn.Close()
	} else {
		meeting.removeClient(conn)
	}
}

func createMeeting(room string, conn *websocket.Conn, client *Client) *Meeting {
	clients := make(map[*websocket.Conn]*Client)
	clients[conn] = client
	var meeting *Meeting
	meeting = &Meeting{Room: room, Locked: false, Clients: clients}
	allMeetings[room] = meeting
	log.Println("Meeting created: " + room)
	return meeting
}

func init() {
	allMeetings = make(map[string]*Meeting)
}

func main() {
	// handle all requests by serving a file of the same name
	fileServer := http.FileServer(http.Dir("public"))

	router := mux.NewRouter()
	router.HandleFunc("/", entranceHandler)
	if SERVE_SECURE {
		router.HandleFunc("/{room}", roomSecureHandler)
	} else {
		router.HandleFunc("/{room}", roomHandler)
	}
	router.PathPrefix("/public").Handler(http.StripPrefix("/public", fileServer))
	router.HandleFunc("/ws/{room}", socketHandler)

	http.Handle("/", router)

	log.Println("Serving on" + PORT)
	log.Println("Go to localhost" + PORT)
	if SERVE_SECURE {
		go func() {
			log.Println("HTTP port" + PORT)
			log.Println("HTTP redirecting on port" + PORT_SECURE)
			httpErr := http.ListenAndServe(PORT, secureRedirectHandler(http.StatusFound))
			if httpErr != nil {
				panic("Error: " + httpErr.Error())
			}
		}()
		log.Println("Security is on use HTTPS")
		if err := http.ListenAndServeTLS(PORT_SECURE, GetAbsolutePath("ssl/cert.crt"), GetAbsolutePath("ssl/server.key"), nil); err != nil {
			log.Fatal("ListenAndServeTLS:", err)
		}
	} else {
		if err := http.ListenAndServe(PORT, nil); err != nil {
			log.Fatal("ListenAndServe:", err)
		}
	}

}
