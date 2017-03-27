// Copyright (c) 2014 The WebRTC project authors. All Rights Reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file in the root of the source
// tree.

package main

import (
	"flag"
	"golang.org/x/net/websocket"
	"log"
	"mycollider/collider"
	"net/http"
	"strconv"
)

var tls = flag.Bool("tls", true, "whether TLS is used")
var port = flag.Int("port", 443, "The TCP port that the server listens on")
var roomSrv = flag.String("room-server", "https://apprtc.appspot.com", "The origin of the room server")

func main() {
	flag.Parse()

	log.Printf("Starting collider: tls = %t, port = %d, room-server=%s", *tls, *port, *roomSrv)

	c := collider.NewCollider(*roomSrv)

	http.Handle("/ws", websocket.Handler(c.WsHandler))
	http.HandleFunc("/status", c.HttpStatusHandler)
	http.HandleFunc("/", c.HttpHandler)

	var e error

	pstr := ":" + strconv.Itoa(*port)
	if *tls {
		e = http.ListenAndServeTLS(pstr, "/cert/cert.pem", "/cert/key.pem", nil)
	} else {
		e = http.ListenAndServe(pstr, nil)
	}

	if e != nil {
		log.Fatal("Run: " + e.Error())
	}
	// c.Run(*port, *tls)
}
