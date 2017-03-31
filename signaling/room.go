package main

import (
	"github.com/bitly/go-simplejson"
	"github.com/gorilla/websocket"
)

// Room represents information about room.
type Room struct {
	RoomID string
	Locked bool
	Users  map[*websocket.Conn]*User
}

type User struct {
	UserID   string
	Resource UserResource
}

type UserResource struct {
	Screen bool `json:"screen"`
	Video  bool `json:"video"`
	Audio  bool `json:"audio"`
}

func getUserDefault(userID string) *User {
	return &User{UserID: userID, Resource: UserResource{Screen: false, Video: false, Audio: true}}
}

func (room *Room) numberOfUser() int {
	return len(room.Users)
}

func (room *Room) getUserConnection(userID string) *websocket.Conn {
	for conn, client := range room.Users {
		if client.UserID == userID {
			return conn
		}
	}
	return nil
}

func (room *Room) describeRoom(thisConn *websocket.Conn) []byte {
	users := simplejson.New()
	for conn, user := range room.Users {
		if conn != thisConn {
			users.Set(user.UserID, user.Resource)
		}
	}
	data := simplejson.New()
	data.Set("roomDescription", users)
	joinMsg := simplejson.New()
	joinMsg.Set("event", "_join")
	joinMsg.Set("data", data)
	msg, err := joinMsg.MarshalJSON()
	if err != nil {
		return []byte(`{"event":"_join","data":{"err":"Json marshal error"}}`)
	}
	return msg
}
