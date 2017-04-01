package main

// setup mongodb

const DEBUG_MODE = false

var PORT string = ":8080"
var PORT_SECURE string = ":8443"

const SERVE_SECURE = true

// EMAIL_RGX will only fit 99% of all emails...
const EMAIL_RGX string = `(?i)[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,6}`

const INVALID_ROOM int = 9
const STUN string = "stun:stun.l.google.com:19302"
const TURN string = "https://turn.votebin.com:3478"

/*
func getStunServers() []byte {

	return []byte(fmt.Sprintf(`{"event":"stunservers","data":[{"url": "%s"}]}`, STUN))
}

func getTurnServers() []byte {
	 { "url": "turn:your.turn.server.here",
	   "secret": "turnserversharedsecret",
	   "expiry": 86400 }

		    { "url": "turn:your.turn.server.here",
			   "credential": "turnserversharedsecret",
			   "username": 86400 }

	// From secret generate credential and push over
	// Also need to add credential information if has turnserver
	return []byte(`{"event":"turnservers","data":[]}`)
}*/
