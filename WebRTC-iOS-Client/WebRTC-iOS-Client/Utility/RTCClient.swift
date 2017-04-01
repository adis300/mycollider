//
//  RTCClient.swift
//  WebRTC-iOS-Client
//
//  Created by Disi A on 3/30/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

import UIKit
import WebRTC
import Starscream

let RTC_SERVER_URL = "wss://localhost:8443/ws/"
let STUN_SERVER_URL = "stun:stun.l.google.com:19302"
let TURN_SERVER_URL = "https://turn.votebin.com"

class RTCClient: NSObject {
    
    var audioMute = false
    var videoMute = false
    
    var localVideoTrack: RTCVideoTrack?
    
    var localAudioTrack: RTCAudioTrack?

    var localMediaStream: RTCMediaStream?
    
    var socket: WebSocket?
    
    func connect(roomId: String){
        socket = WebSocket(url: URL(string: RTC_SERVER_URL + roomId)!)
        socket?.disableSSLCertValidation = true
        socket?.delegate = self
        self.socket?.connect()
    }
    
    func joinRoom(roomId: String){
        
    }
    
    func handleServerMessage(data: [String: Any]){
        if let event = data["event"] as? String{
            switch event {
            case "connect":
                print("This is a connect message")
                print(data)
            default:
                print("ERROR: Unknown server envent")
            }
        }else{
            print("ERROR: Event marker missing")

        }
    }
}

extension RTCClient: WebSocketDelegate{
    func websocketDidConnect(socket: WebSocket){
        print("Did connect")
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?){
        print("Did disconnect")
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String){
        if let data = text.data(using: .utf8){
            do {
                let json = try parseJson(data: data)
                handleServerMessage(data: json)
            } catch {
                print("ERROR: parsing json data")
                print(text)
            }
            
        }else{
            print("ERROR: Should not happen")
            print(text)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data){
        print("Received some data \(data.count)")
    }
}
