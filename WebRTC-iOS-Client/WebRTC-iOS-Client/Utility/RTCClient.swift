//
//  RTCClient.swift
//  WebRTC-iOS-Client
//
//  Created by Disi A on 3/30/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

import UIKit
import WebRTC

let RTC_SERVER_URL = "wss://localhost:8081/ws/"
let STUN_SERVER_URL = "stun:stun.l.google.com:19302"
let TURN_SERVER_URL = "https://turn.votebin.com"

class RTCClient: NSObject {
    
    var audioMute = false
    var videoMute = false
    
    var localVideoTrack: RTCVideoTrack?
    
    var localAudioTrack: RTCAudioTrack?

    var localMediaStream: RTCMediaStream?
    
    var socket: WebSocket?
    
    var iceServers : [String] = []
    
    var roomId: String?
    var sessionId: String?
    
    var sessionReady = false
    
    func connect(roomId: String){
        guard localAudioTrack != nil || localVideoTrack != nil else { // localMediaStream != nil && (localAudioTrack != nil || localVideoTrack != nil)
            assertionFailure("Local media not ready")
            return
        }
        
        clearSession()
        self.roomId = roomId
        socket = WebSocket(url: URL(string: RTC_SERVER_URL + roomId)!)
        socket?.disableSSLCertValidation = true
        socket?.delegate = self
        self.socket?.connect()
        
    }
    
    func clearSession(){
        self.roomId = nil
        self.iceServers = []
    }
    
    fileprivate func handleServerMessage(msg: [String: Any]){
        
        print(msg)

        if let event = msg["event"] as? String{
            switch event {
            case "connect":
                let data = msg["data"] as! [String: Any]
                if let turnServers = data["turnservers"] as? [[String: Any]]{
                    for turnServer in turnServers{
                        iceServers.append(turnServer["url"] as! String)
                    }
                }
                
                if let stunServers = data["stunservers"] as? [[String: Any]]{
                    for stunServer in stunServers{
                        iceServers.append(stunServer["url"] as! String)
                    }
                }
                if let sid = data["sessionid"] as? String{
                    sessionId = sid
                    sessionReady = true
                    joinRoom()
                }else{
                    assertionFailure("Invalid sessionId received")
                }
                
                // emit sessionReady event
                
            default:
                assertionFailure("ERROR: Unknown server envent")
            }
        }else{
            print("ERROR: Event marker missing")

        }
    }
    
    private func sendMessage(_ msg: [String: Any]){
        
        if let sock = socket{
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: msg) //, options: .prettyPrinted
                sock.write(data: jsonData)
            } catch {
                print("RTCClient:sendMessage: error serializing msg")
                print(error.localizedDescription)
            }
        }else{
            assertionFailure("Trying to send socket message before session is initialized")
        }
    }
    
    private func joinRoom(){
        var msg: [String: Any] = [:]
        
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
                handleServerMessage(msg: json)
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
