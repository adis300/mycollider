//
//  RTCConfig.swift
//  WebRTC-iOS-Client
//
//  Created by Disi A on 4/2/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

import Foundation
import WebRTC

class RTCClientConfig {
    
    // static let SECURE_CONNECTION = false
    static let RTC_SERVER_URL = "wss://192.168.200.112:8443/ws/"
    static let STUN_SERVER_URL = "stun:stun.l.google.com:19302"
    static let TURN_SERVER_URL = "https://turn.votebin.com"
    static let validateSsl = false
    
    static let audioOnly = true
    // Default Configs
    static let defaultOfferToReceiveAudio = true
    static let defaultOfferToReceiveVideo = !audioOnly
    
    static let defaultReceiveMedia = ["mandatory": ["OfferToReceiveAudio":defaultOfferToReceiveAudio, "OfferToReceiveVideo" :defaultOfferToReceiveVideo]];
    
    static let enableDataChannels = true
    
    static let peerVolumeWhenSpeaking = 0.25
    
    static let media = ["video":true, "audio" : true]
    
    static let useSpeaker = true
    
    // If loopback
    // static let kDefaultMediaConstraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio":"true", "OfferToReceiveVideo" :"true"], optionalConstraints: ["DtlsSrtpKeyAgreement" : "true"])
    
    static let defaultOptions:[String: Any] = [:]
    
    static let dataChannelConfiguration = RTCDataChannelConfiguration()
    
    private static let rtcConfiguration = RTCConfiguration()
    
    static func getRTCConfiguration(iceServers: [RTCIceServer]?) -> RTCConfiguration {
        if let servers = iceServers{
            RTCClientConfig.rtcConfiguration.iceServers = servers
        }else{
            RTCClientConfig.rtcConfiguration.iceServers = [RTCIceServer(urlStrings: [RTCClientConfig.STUN_SERVER_URL])]
        }
        return RTCClientConfig.rtcConfiguration
    }
    
    static let localMediaStreamId = "local_stream"
    static let localAudioTrackId = "local_audio"
    static let localVideoTrackId = "local_video"
    
    static func setAudioOutput(useSpeaker: Bool?){
        do{
            var use: Bool = false
            if let useSpeaker = useSpeaker{
                if useSpeaker{
                    use = true
                }
            }else{
                if RTCClientConfig.useSpeaker {
                    use = true
                }
            }
            
            if use {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            }else{
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            }
            
        }catch{
            print(error.localizedDescription)
        }
        
    }

}

class RTCFactory{
    
    private static var peerConnectionFactory: RTCPeerConnectionFactory? = nil
    static func getPeerConnectionFactory() -> RTCPeerConnectionFactory{
        if let factory = peerConnectionFactory{
            return factory
        }else{
            peerConnectionFactory = RTCPeerConnectionFactory()
            return peerConnectionFactory!
        }
    }

    static func getMediaConstraints(receiveMedia: [String: Any]?) -> RTCMediaConstraints{
        
        if receiveMedia == nil{
            return RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        }
        
        var mandatory:[String: Bool] = [:]
        if let mandatoryObj = receiveMedia?["mandatory"] as? [String: Bool]{
            mandatory = mandatoryObj
        }
        
        var mediaConstraintsMandatory: [String:String] = [:]
        
        var offerVideo, offerAudio: Bool
        if let val = mandatory["OfferToReceiveVideo"]{
            offerVideo = val
        }else{
            offerVideo = RTCClientConfig.defaultOfferToReceiveVideo
        }
        
        if let val = mandatory["OfferToReceiveAudio"]{
            offerAudio = val
        }else{
            offerAudio = RTCClientConfig.defaultOfferToReceiveAudio
        }
        
        if offerVideo {
            mediaConstraintsMandatory["OfferToReceiveVideo"] = "true"
        }else{
            mediaConstraintsMandatory["OfferToReceiveVideo"] = "false"
        }
        if offerAudio {
            mediaConstraintsMandatory["OfferToReceiveAudio"] = "true"
        }else{
            mediaConstraintsMandatory["OfferToReceiveAudio"] = "false"
        }
        
        return RTCMediaConstraints(mandatoryConstraints: mediaConstraintsMandatory, optionalConstraints: nil)
    }
    
    /* Some free public stun servers */
    static func alternativeStunServers() -> [RTCIceServer]{
        return [
            RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"]),
            RTCIceServer(urlStrings: ["stun:stun1.l.google.com:19302"]),
            RTCIceServer(urlStrings: ["stun:stun2.l.google.com:19302"]),
            RTCIceServer(urlStrings: ["stun:stun3.l.google.com:19302"]),
            RTCIceServer(urlStrings: ["stun:stun4.l.google.com:19302"]),
            RTCIceServer(urlStrings: ["stun:stun01.sipphone.com"]),
            RTCIceServer(urlStrings: ["stun:stun.ekiga.net"]),
            RTCIceServer(urlStrings: ["stun:stun.fwdnet.net"]),
            RTCIceServer(urlStrings: ["stun:stun.ideasip.com"]),
            RTCIceServer(urlStrings: ["stun:stun.iptel.org"]),
            RTCIceServer(urlStrings: ["stun:stun.iptel.org"]),
            RTCIceServer(urlStrings: ["stun:stun.rixtelecom.se"]),
            RTCIceServer(urlStrings: ["stun:stun.schlund.de"]),
            RTCIceServer(urlStrings: ["stun:stunserver.org"]),
            RTCIceServer(urlStrings: ["stun:stun.softjoys.com"]),
            RTCIceServer(urlStrings: ["stun:stun.voiparound.com"]),
            RTCIceServer(urlStrings: ["stun:stun.voipbuster.com"]),
            RTCIceServer(urlStrings: ["stun:stun.voipstunt.com"]),
            RTCIceServer(urlStrings: ["stun:stun.voxgratia.org"]),
            RTCIceServer(urlStrings: ["stun:stun.xten.com"])
        ]
    }
}

protocol RTCClientDelegate {
    
    func rtcClientDidSetLocalMediaStream(client: RTCClient, authorized: Bool, audioOnly: Bool)

    func rtcClientDidAddRemoteMediaStream(peer: RTCPeer, stream: RTCMediaStream, audioOnly: Bool)
    
    // Optional peer delegate methods
    func rtcRemotePeerDidChangeAudioState(peer: RTCPeer, on: Bool)
    
    func rtcRemotePeerDidChangeVideoState(peer: RTCPeer, on: Bool)

    func rtcRemotePeerFailedToGenerateIceCandidate(peer: RTCPeer)
}

// Default optional delegate methods
extension RTCClientDelegate{
    func rtcRemotePeerDidChangeAudioState(peer: RTCPeer, on: Bool){
        print("RTCClientDelegate:rtcRemotePeerDidChangeAudioState:empty")
    }
    
    func rtcRemotePeerDidChangeVideoState(peer: RTCPeer, on: Bool){
        print("RTCClientDelegate:rtcRemotePeerDidChangeVideoState:empty")
    }
    
    func rtcRemotePeerFailedToGenerateIceCandidate(peer: RTCPeer){
        print("RTCClientDelegate:rtcFailedToGenerateIce:empty")
    }
}

