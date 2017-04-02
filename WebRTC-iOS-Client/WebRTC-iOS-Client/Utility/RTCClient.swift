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

let kDefaultMediaConstraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio":"true", "OfferToReceiveVideo" :"true"]
    , optionalConstraints: nil)

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
    
    // Utility properties
    fileprivate var peerConnectionFactory = RTCPeerConnectionFactory()

    
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
    
    fileprivate func handleServerMessage(msg: JSON){
        
        print(msg)

        if let event = msg["event"].string{
            switch event {
            case "connect":
                let data = msg["data"]
                if let turnServers = data["turnservers"].array{
                    for turnServer in turnServers{
                        iceServers.append(turnServer["url"].string!)
                    }
                }
                
                if let stunServers = data["stunservers"].array{
                    for stunServer in stunServers{
                        iceServers.append(stunServer["url"].string!)
                    }
                }
                if let sid = data["sessionid"].string{
                    sessionId = sid
                    sessionReady = true
                    joinRoom()
                }else{
                    assertionFailure("Invalid sessionId received")
                }
                
                // emit sessionReady event
            case "_join": //On join implementation
                let data = msg["data"]
                if let err = data["err"].string{
                    assertionFailure("Server room description error: \(err)")
                    return
                }
                let roomDescription = data["roomDescription"]
                onJoin(roomDescription: roomDescription)
                
            default:
                assertionFailure("ERROR: Unknown server envent")
            }
        }else{
            print("ERROR: Event marker missing")

        }
    }
    
    private func joinRoom(){
        guard roomId != nil else {
            assertionFailure("roomId unavailable when join")
            return
        }
        
        let msg: [String: Any] = ["event":"join", "data": roomId!]
        sendMessage(msg)
    }
    
    private func onJoin(roomDescription: JSON) {
        print(roomDescription.count)
        for (sid, clientResource) in roomDescription {
            for (type, typeEnabled) in clientResource{
                if typeEnabled.boolValue {
                    let rtcConfig = RTCConfiguration()
                    
                    let peerConnection = peerConnectionFactory.peerConnection(with: rtcConfig, constraints: kDefaultMediaConstraints, delegate: self)
                }
            }
            /*
            if let clientRes as? [String: Bool] {
                
            }else{
                assertionFailure("Invalid client resources format")
            }*/
        }
        /*
            if (roomDescription) {
                var id,
                    client,
                    type,
                    peer;
                for (id in roomDescription) {
                    client = roomDescription[id];
                    for (type in client) {
                        if (client[type]) {
                            peer = self.webrtc.createPeer({
                                id: id,
                                type: type,
                                enableDataChannels: self.config.enableDataChannels && type !== 'screen',
                                receiveMedia: {
                                    mandatory: {
                                        OfferToReceiveAudio: type !== 'screen' && self.config.receiveMedia.OfferToReceiveAudio,
                                        OfferToReceiveVideo: self.config.receiveMedia.OfferToReceiveVideo
                                    }
                                }
                            });
                            self.emit('createdPeer', peer);
                            peer.start();
                        }
                    }
                }
            }
         */
    }
}

extension RTCClient {
    
    fileprivate func sendMessage(_ msg: [String: Any]){
        
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
    
    fileprivate func clearSession(){
        self.sessionId = nil
        self.sessionReady = false
        self.localVideoTrack = nil
        self.localAudioTrack = nil
        self.localMediaStream = nil
        self.socket = nil
        self.roomId = nil
        self.iceServers = []
        self.audioMute = false
        self.videoMute = false
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
            let json = JSON(data: data)
            handleServerMessage(msg: json)
            /*
            do {
                let json = try parseJson(data: data)
            } catch {
                print("ERROR: parsing json data")
                print(text)
            }*/
            
        }else{
            print("ERROR: Should not happen")
            print(text)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data){
        print("Received some data \(data.count)")
    }
    
}

extension RTCClient: RTCPeerConnectionDelegate {
    
    /** Called when the SignalingState changed. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState){

    }
    
    /** Called when media is received on a new stream from remote peer. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream){

    }
    
    /** Called when a remote peer closes a stream. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream){
        
    }
    
    /** Called when negotiation is needed, for example ICE has restarted. */
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection){
        
    }
    
    /** Called any time the IceConnectionState changes. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState){
        
    }
    
    
    /** Called any time the IceGatheringState changes. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState){
        
    }
    
    /** New ice candidate has been found. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate){
        
    }
    
    /** Called when a group of local Ice candidates have been removed. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]){
        
    }
    
    /** New data channel has been opened. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel){
        
    }
}

