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
    
    static var DEFAULT_STUN_SERVER_URL = "stun:stun.l.google.com:19302"
    static var DEFAULT_TURN_SERVER_URL = "https://turn.votebin.com"
    
    static var DEFAULT_PEER_TYPE = "video"
    static var DEFAULT_ENABLE_DATA_CHANNELS = true
    static var DEFAULT_USE_SPEAKER = true


    static var validateSsl = false
    
    static var audioOnly = false
    // Default Configs
    static var offerToReceiveAudio = true
    static var offerToReceiveVideo = !audioOnly
    
    private(set) static var defaultReceiveMedia = ["mandatory": ["OfferToReceiveAudio":offerToReceiveAudio, "OfferToReceiveVideo" :offerToReceiveVideo]];
    
    
    // static let peerVolumeWhenSpeaking = 0.25
    
    // If loopback
    // static let kDefaultMediaConstraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio":"true", "OfferToReceiveVideo" :"true"], optionalConstraints: ["DtlsSrtpKeyAgreement" : "true"])
    
    static let dataChannelConfiguration = RTCDataChannelConfiguration()
    
    private static let rtcConfiguration = RTCConfiguration()
    
    static func load(config: [String: Any]){
        if let val  = config["defaultEnableDataChannels"] as? Bool{
            DEFAULT_ENABLE_DATA_CHANNELS = val
        }
        if let val  = config["defaultUseSpeaker"] as? Bool{
            DEFAULT_USE_SPEAKER = val
        }
        if let val  = config["defaultPeerType"] as? String{
            DEFAULT_PEER_TYPE = val
        }
        if let val = config["validateSsl"] as? Bool{
            validateSsl = val
        }
        if let val = config["offerToReceiveAudio"] as? Bool{
            offerToReceiveAudio = val
        }
        if let val = config["offerToReceiveVideo"] as? Bool{
            offerToReceiveVideo = val
        }
        if let val = config["audioOnly"] as? Bool{
            audioOnly = val
            if audioOnly && offerToReceiveVideo{
                offerToReceiveVideo = false
            }
        }
        
        defaultReceiveMedia = ["mandatory": ["OfferToReceiveAudio":offerToReceiveAudio, "OfferToReceiveVideo" :offerToReceiveVideo]]
        
    }
    
    static func getRTCConfiguration(iceServers: [RTCIceServer]?) -> RTCConfiguration {
        if let servers = iceServers{
            RTCClientConfig.rtcConfiguration.iceServers = servers
        }else{
            RTCClientConfig.rtcConfiguration.iceServers = [RTCIceServer(urlStrings: [RTCClientConfig.DEFAULT_STUN_SERVER_URL])]
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
                if RTCClientConfig.DEFAULT_USE_SPEAKER {
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
        
        var offerVideo = RTCClientConfig.offerToReceiveVideo
        var offerAudio = RTCClientConfig.offerToReceiveAudio
        if let val = mandatory["OfferToReceiveVideo"]{
            offerVideo = val
        }
        if let val = mandatory["OfferToReceiveAudio"]{
            offerAudio = val
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
