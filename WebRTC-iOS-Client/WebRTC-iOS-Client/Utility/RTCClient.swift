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
    
    var iceServers : [RTCIceServer] = [] //[String] = []
    
    var roomId: String?
    var sessionId: String?
    
    var sessionReady = false
    
    var peers:[String: RTCPeer] = [:]
    
    var delegate: RTCClientDelegate?
    
    
    fileprivate func filterPeers(peerId: String?, type: String?) -> [RTCPeer]{
        return peers.filter{(peerId, peer) in
            return (peer.peerId == peerId) && (type == nil || peer.type == type)
            }.map{(key, val) in val}
    }
    
    // Utility properties
    // fileprivate var peerConnections:[RTCPeerConnection] = []
    
    func initialize(delegate: RTCClientDelegate){
        
        clearSession()

        self.delegate = delegate
        self.localMediaStream = RTCFactory.peerConnectionFactory.mediaStream(withStreamId: RTCClientConfig.localMediaStreamId)
        
        // Initialize audio track
        localAudioTrack = RTCFactory.peerConnectionFactory.audioTrack(withTrackId: RTCClientConfig.localAudioTrackId)
        localMediaStream?.addAudioTrack(localAudioTrack!)
        
        // let audioDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInMicrophone, mediaType: AVMediaTypeAudio, position: .unspecified)
        
        
        
        if RTCClientConfig.audioOnly{
            delegate.rtcClientDidSetLocalMediaStream(client: self, authorized: true, audioOnly: RTCClientConfig.audioOnly)
        }else{
            
            
            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if authStatus == .restricted || authStatus == .denied {
                print("相机访问受限");
                delegate.rtcClientDidSetLocalMediaStream(client: self, authorized: false, audioOnly: RTCClientConfig.audioOnly)
            }else{
                
                if let _ = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front){
                    let videoSource = RTCFactory.peerConnectionFactory.avFoundationVideoSource(with: RTCFactory.getMediaConstraints(receiveMedia: nil))
                    localVideoTrack = RTCFactory.peerConnectionFactory.videoTrack(with: videoSource, trackId: RTCClientConfig.localVideoTrackId)
                    
                    localMediaStream?.addVideoTrack(localVideoTrack!)
                    
                    delegate.rtcClientDidSetLocalMediaStream(client: self, authorized: true, audioOnly: RTCClientConfig.audioOnly)

                }else{
                    print("无法访问相机");
                    delegate.rtcClientDidSetLocalMediaStream(client: self, authorized: false, audioOnly: RTCClientConfig.audioOnly)
                }

            }
        }
        
        
        
    }
    
    func connect(roomId: String){
        guard localAudioTrack != nil || localVideoTrack != nil else { // localMediaStream != nil && (localAudioTrack != nil || localVideoTrack != nil)
            assertionFailure("Local media not ready")
            return
        }
        
        // TODO: Implement? RTCPeerConnectionFactory.initialize()
        
        self.roomId = roomId
        socket = WebSocket(url: URL(string: RTCClientConfig.RTC_SERVER_URL + roomId)!)
        if !RTCClientConfig.validateSsl{
            socket?.disableSSLCertValidation = true
        }
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
                        iceServers.append(RTCIceServer(urlStrings: [turnServer["url"].string!]))
                    }
                }
                
                if let stunServers = data["stunservers"].array{
                    for stunServer in stunServers{
                        iceServers.append(RTCIceServer(urlStrings: [stunServer["url"].string!]))
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
            
            case "message":
                let data = msg["data"]
                onMessage(data)
            case "remove":
                let peerId = msg["data"]["id"].string!
                removePeer(peerId: peerId)
            default:
                assertionFailure("ERROR: Unknown server envent")
            }
        }else{
            assertionFailure("ERROR: Event marker missing")
        }
    }
    
    private func joinRoom(){
        guard roomId != nil else {
            assertionFailure("roomId unavailable when join")
            return
        }
        
        sendMessage(event: "join", data: roomId!)
    }
    
    public func disconect(){
        clearSession()
        socket?.disconnect()
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
                    let peer = RTCPeer(options: ["id": id, "type": type, "enableDataChannels": RTCClientConfig.enableDataChannels && type != "screen", "receiveMedia": receiveMedia], parent:self)
                    //TODO: self.emit("createdPeer")
                    peer.start()
                    peer.sendOffer()
                    peers[id] = peer
                }
            }
        }
    }
    
    private func onMessage(_ data: JSON){
        
        if let type = data["type"].string{
            
            let sessionPeers = filterPeers(peerId: data["from"].string, type: data["roomType"].string)
            var peer: RTCPeer?

            if type == "offer"{
                

                for p in sessionPeers {
                    if p.sid  == data["sid"].string!{
                        peer = p
                        break
                    }
                }
                
                if peer == nil{
                    let isScreen = data["roomType"].string! == "screen"
                    
                    var enableDataChannels = false, sharemyscreen = false, broadcaster: String? = nil
                    
                    if !isScreen && RTCClientConfig.enableDataChannels{
                        enableDataChannels = true
                    }
                    if isScreen {
                        if data["broadcaster"] == JSON.null {
                            sharemyscreen = true
                            broadcaster = sessionId!
                        }
                    }
                    
                    peer = RTCPeer(options: [
                        "id": data["from"].string,
                        "sid": data["sid"].string!,
                        "type": data["roomType"].string!,
                        "enableDataChannels": enableDataChannels,
                        "sharemyscreen": sharemyscreen,
                        "broadcaster": broadcaster
                        ], parent: self)
                    //TODO: self.emit("createdPeer")
                    peer?.startAnswer()
                    
                    peers["id"] = peer!
                }else{
                    peer?.handleMessage(data)
                }
            }else{
                for p in sessionPeers {
                    let sid = data["sid"].string
                    if sid == nil || sid == p.sid{
                        p.handleMessage(data);
                    }
                }
            }
        }else{
            assertionFailure("type unavailable, bad offer")
        }
    
    }
}

extension RTCClient {
    
    fileprivate func sendMessage(event: String, data: Any){
        
        let msg = ["event": event, "data": data]
        sendMessage(msg)
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
    
    fileprivate func removePeer(peerId: String){
        if let peer = peers[peerId]{
            if let stream = localMediaStream {
                peer.peerConnection.remove(stream)
            }
            peer.peerConnection.close()
            peers.removeValue(forKey: peerId)
        }
    }
    
    fileprivate func clearSession(){
        for (_, peer) in peers{
            if let stream = localMediaStream {
                peer.peerConnection.remove(stream)
                peer.peerConnection.close()
            }
        }
        peers = [:]
        self.iceServers = []
        self.sessionId = nil
        self.sessionReady = false
        self.localVideoTrack = nil
        self.localAudioTrack = nil
        self.localMediaStream = nil
        self.socket = nil
        self.roomId = nil
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
            
        }else{
            print("ERROR: Should not happen")
            print(text)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data){
        print("Received some data \(data.count)")
    }
    
}

extension RTCPeer: RTCPeerConnectionDelegate{
    
    /** Called when the SignalingState changed. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState){
        print("DEBUG, peer connection state changed to \(stateChanged.rawValue)")
    }
    
    /** Called when media is received on a new stream from remote peer. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream){
        print("DEBUG, peer connection did add stream")
    }
    
    /** Called when a remote peer closes a stream. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream){
        print("DEBUG, peer connection did remove stream")
    }
    
    /** Called when negotiation is needed, for example ICE has restarted. */
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection){
        print("DEBUG, peer connection should negotiate, no op")
    }
    
    /** Called any time the IceConnectionState changes. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState){
        print("DEBUG, peer connection ice state did change")
    }
    
    
    /** Called any time the IceGatheringState changes. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState){
        print("DEBUG, peer connection ice gathering state did change")
    }
    
    /** New ice candidate has been found. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate){
        print("DEBUG, peer connection did generate new ICE candidate")
        print(candidate.sdp)
        let candidate:[String: Any] = ["candidate":"candidate:" + candidate.sdp,"sdpMid":candidate.sdpMid!,"sdpMLineIndex":candidate.sdpMLineIndex]
        sendPeerMessage(messageType: "candidate", payload: candidate)
    }
    
    /** Called when a group of local Ice candidates have been removed. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]){
        print("DEBUG, peer connection did remove candidates")
    }
    
    /** New data channel has been opened. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel){
        print("DEBUG, peer connection did open data channel")
    }
    
    func sedPeerMessage(messageType: String, payload: String){
        // send via signalling channel
        let data: [String: Any]
        if let broadcaster = self.broadcaster{
            data = [
                "to": self.peerId,
                "sid": self.sid,
                "broadcaster": broadcaster,
                "roomType": self.type,
                "type": messageType,
                "payload": payload,
                "prefix": browserPrefix
            ]
        }else{
            data = [
                "to": self.peerId,
                "sid": self.sid,
                "roomType": self.type,
                "type": messageType,
                "payload": payload,
                "prefix": browserPrefix
            ]
        }
        parent.sendMessage(event: "message", data: data)
    }
}

class RTCPeer: NSObject {
    
    var peerConnection: RTCPeerConnection!
    var peerId: String!
    var type = "video"   //default peer type to video
    var oneway = false
    var sharemyscreen = false
    var browserPrefix = "webkit"
    var enableDataChannels = RTCClientConfig.enableDataChannels
    var sid: String = String(Date().timeIntervalSince1970)
    var broadcaster: String?
    //var stream
    //var channels
    //var receiveMedia
    var receiveMedia:[String: Any] = RTCClientConfig.defaultReceiveMedia
    let parent: RTCClient
    
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
    

    init(options: [String: Any?], parent: RTCClient) {
        
        self.parent = parent
        
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
    }
    
    fileprivate func start() {
        let mediaConstraints = RTCFactory.getMediaConstraints(receiveMedia: receiveMedia)
        peerConnection = RTCFactory.peerConnectionFactory.peerConnection(with: RTCClientConfig.getRTCConfiguration(iceServers: parent.iceServers), constraints: mediaConstraints, delegate: self)
        
        // handle screensharing/broadcast mode
        if type == "screen" {
            if sharemyscreen { //&& has a localScreen
                print("adding local screen stream to peer connection");
                // peerConnection.add(<#T##stream: RTCMediaStream##RTCMediaStream#>) // Add a local screen
                // broadcaster = opt["broadcaster"] as! String
                assertionFailure("Screensharing is not yet supported")
            }
        } else {
            if let localStream = parent.localMediaStream{
                peerConnection.add(localStream)
            }else{
                assertionFailure("Failed to add local stream, not ready.")
            }
        }
        
        if (self.enableDataChannels) {
            let dataChannel = peerConnection.dataChannel(forLabel: "simplewebrtc", configuration: RTCClientConfig.dataChannelConfiguration)
            // TODO: Make use of dataChannel
        }
    }
    
    fileprivate func sendOffer(){

        peerConnection.offer(for: RTCFactory.getMediaConstraints(receiveMedia: receiveMedia)) { (sessionDescription, error) in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            if let sessionDesc = sessionDescription{
                self.peerConnection.setLocalDescription(sessionDesc, completionHandler: { (localSdpError) in
                    if let e = localSdpError{
                        assertionFailure(e.localizedDescription)
                    }
                })
                self.sendPeerMessage(messageType: "offer", payload: ["type":"offer", "sdp": sessionDesc.sdp])
            }else{
                assertionFailure("Failed to get session description")
            }
        }
    }
    fileprivate func sendAnswer(){
        
        peerConnection.answer(for: RTCFactory.getMediaConstraints(receiveMedia: receiveMedia)) { (sessionDescription, error) in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            if let sessionDesc = sessionDescription{
                self.peerConnection.setLocalDescription(sessionDesc, completionHandler: { (localSdpError) in
                    if let e = localSdpError{
                        assertionFailure(e.localizedDescription)
                    }
                })
                self.sendPeerMessage(messageType: "answer", payload: <#T##[String : Any]#>)
            }else{
                assertionFailure("Failed to get session description")
            }
        }
    }
    
    // MARK: Peer connection active methods
    
    fileprivate func sendPeerMessage(messageType: String, payload:[String : Any]){
        let message: [String: Any]
        if let broadcaster = self.broadcaster{
            message = ["type": messageType, "to":self.peerId, "sid":self.sid, "broadcaster": broadcaster, "roomType": self.type, "payload": payload, "prefix": self.browserPrefix]
        }else{
            message = ["type": messageType, "to":self.peerId, "sid":self.sid, "roomType": self.type, "payload": payload, "prefix": self.browserPrefix]
        }
        parent.sendMessage(event: "message", data: message)
    }
    
    fileprivate func handleMessage(_ message: JSON){
        // TODO: Implement
        print("RTCPeer:handleMessage:\(message)")
        let payload = message["payload"]

        if let prefix = message["prefix"].string{
            self.browserPrefix = prefix
        }
        
        let type = message["type"].string!  //Type must by available, protected from top level onMessage
        
        switch type {
        case "offer":
            
            //TODO: peerConnection
            print(type)
        case "answer":
            let remoteSdp = RTCSessionDescription(type: .answer, sdp: payload["sdp"].string!)
            peerConnection.setRemoteDescription(remoteSdp, completionHandler: { (error) in
                if let err = error{
                    print("RTCPeer:onAnswer: failed to set remote description: \(err.localizedDescription)")
                }
            })
        case "candidate":
            
            if let _ = parent.peers[message["from"].string!]{
                let candidateJson = payload["candidate"]
                var candidateSdp = candidateJson["candidate"].string!
                candidateSdp = candidateSdp[candidateSdp.index(candidateSdp.startIndex, offsetBy: 10)..<candidateSdp.endIndex]
                let candidate = RTCIceCandidate(sdp: candidateSdp, sdpMLineIndex: candidateJson["sdpMLineIndex"].int32!, sdpMid: candidateJson["sdpMid"].string!)
                
                peerConnection.add(candidate)
            }else{
                assertionFailure("Peer not found for answer")
            }
        case "endOfCandidates":
            print("End of candidate received.")
            /* TODO: Find out about mLine and transceivers.
            var mLines = this.pc.pc.peerconnection.transceivers || [];
            mLines.forEach(function(mLine) {
                if (mLine.iceTransport) mLine.iceTransport.addRemoteCandidate({});
            });
            */
        default:
            assertionFailure("RTCPeer:handleMessage: unknown message type")
        }
        /*
        if (message.prefix) this.browserPrefix = message.prefix;
        
        if (message.type === 'offer') {
            if (!this.nick) this.nick = message.payload.nick;
            delete message.payload.nick;
            this.pc.handleOffer(message.payload, function(err) {
            if (err) {
            return;
            }
            // auto-accept
            self.pc.answer(function(err, sessionDescription) {
            //self.send('answer', sessionDescription);
            });
            });
        } else if (message.type === 'answer') {
            if (!this.nick) this.nick = message.payload.nick;
            delete message.payload.nick;
            this.pc.handleAnswer(message.payload);
        } else if (message.type === 'candidate') {
            this.pc.processIce(message.payload);
        } else if (message.type === 'connectivityError') {
            this.parent.emit('connectivityError', self);
        } else if (message.type === 'mute') {
            this.parent.emit('mute', { id: message.from, name: message.payload.name });
        } else if (message.type === 'unmute') {
            this.parent.emit('unmute', { id: message.from, name: message.payload.name });
        } else if (message.type === 'endOfCandidates') {
            console.log("Peer connection");
            console.log(this.pc);
            var mLines = this.pc.pc.peerconnection.transceivers || [];
            mLines.forEach(function(mLine) {
                if (mLine.iceTransport) mLine.iceTransport.addRemoteCandidate({});
            });
        }
        */
    }
}

