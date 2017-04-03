//
//  RTCClient.swift
//  WebRTC-iOS-Client
//
//  Created by Disi A on 3/30/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

import UIKit
import WebRTC

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
    
    var peers:[RTCPeer] = []
    
    // Utility properties
    // fileprivate var peerConnections:[RTCPeerConnection] = []

    
    func connect(roomId: String){
        guard localAudioTrack != nil || localVideoTrack != nil else { // localMediaStream != nil && (localAudioTrack != nil || localVideoTrack != nil)
            assertionFailure("Local media not ready")
            return
        }
        
        clearSession()
        self.roomId = roomId
        socket = WebSocket(url: URL(string: RTCClientConfig.RTC_SERVER_URL + roomId)!)
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
        for (id, clientResource) in roomDescription {
            for (type, typeEnabled) in clientResource{
                if typeEnabled.boolValue {
                    let receiveMedia = [
                        "mandatory":[
                            "OfferToReceiveAudio": type != "screen" && RTCClientConfig.defaultOfferToReceiveAudio,
                            "OfferToReceiveVideo": RTCClientConfig.defaultOfferToReceiveVideo
                        ]
                    ]
                    let peer = RTCPeer(options: ["id": id, "type": type, "enableDataChannels": RTCClientConfig.enableDataChannels && type != "screen", "receiveMedia": receiveMedia], delegate: self)
                    peers.append(peer)
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
        // TODO: Remove all peers
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

extension RTCClient: RTCPeerConnectionDelegate{
    
    
    // MARK: Peer connection active methods
    
    private func sendMessage(){
        var message = ["to":roomId!, "sid":sessionId, "broadcaster": sessionId!]
        /*
        var message = [
            to: this.id,
            sid: this.sid,
            broadcaster: this.broadcaster,
            roomType: this.type,
            type: messageType,
            payload: payload,
            prefix: "webkit"
        ];
         */
    }
    
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

class RTCPeer {
    
    fileprivate static let peerConnectionFactory = RTCPeerConnectionFactory()

    var peerConnection: RTCPeerConnection
    var peerId: String!
    var type = "video"   //default peer type to video
    var oneway = false
    var sharemyscreen = false
    var browserPrefix = "webkit"
    var enableDataChannels = RTCClientConfig.enableDataChannels
    var sid: String = String(Date().timeIntervalSince1970)
    //var stream
    //var channels
    //var receiveMedia
    var receiveMedia:[String: Any] = RTCClientConfig.defaultReceiveMedia
    
    private func getReceiveMedia () -> [String: Any]{
        
        var receiveMedia:[String: Any] = [:]
        var mandatory:[String: Bool] = [:]
        
        if type == "screen"{
            mandatory["OfferToReceiveAudio"] = false
        }else{
            mandatory["OfferToReceiveAudio"] = RTCClientConfig.defaultOfferToReceiveAudio
        }
        
        mandatory["OfferToReceiveVideo"] = RTCClientConfig.defaultOfferToReceiveVideo
        
        receiveMedia["mandatory"] = mandatory
        
        return receiveMedia
    }
    

    init(options: [String: Any], delegate: RTCPeerConnectionDelegate) {
        
        var opt: [String: Any] = RTCClientConfig.defaultOptions
        
        for (key, value) in options {
            opt[key] = value
        }
        peerId = opt["id"] as! String
        
        if let val  = opt["type"] as? String{
            type = val
        }
        if let val  = opt["sid"] as? String{
            sid = val
        }
        if let val  = opt["browserPrefix"] as? String{
            browserPrefix = val
        }
        if let val  = opt["enableDataChannels"] as? Bool{
            enableDataChannels = val
        }
        if let val  = opt["sharemyscreen"] as? Bool{
            sharemyscreen = val
        }
        if let val  = opt["oneway"] as? Bool{
            oneway = val
        }
        
        if let val = opt["receiveMedia"] as? [String: Any]{
            receiveMedia = val
        }else{
            receiveMedia = RTCClientConfig.defaultReceiveMedia
        }
        
        let mediaConstraints = RTCFactory.getMediaConstraints(receiveMedia: receiveMedia)
        peerConnection = RTCPeer.peerConnectionFactory.peerConnection(with: RTCConfiguration(), constraints: mediaConstraints, delegate: delegate)
        
    }
    
    func start(){
        if (self.enableDataChannels) {
            let dataChannel = peerConnection.dataChannel(forLabel: "simplewebrtc", configuration: RTCClientConfig.dataChannelConfiguration)
            // TODO: Make use of dataChannel
        }
        
        peerConnection.offer(for: RTCFactory.getMediaConstraints(receiveMedia: receiveMedia)) { (sessionDescription, error) in
            // TODO: Make use of sessionDescription & err
            if let err = error{
                print(err.localizedDescription)
                return
            }
            if let sdp = sessionDescription{
                print(sdp)
            }
        }
        
        // this.pc.offer(this.receiveMedia, function(err, sessionDescription) {
            //self.send('offer', sessionDescription);
        // });
    }
    
}

