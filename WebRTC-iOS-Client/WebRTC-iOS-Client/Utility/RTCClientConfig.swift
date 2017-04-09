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
    static let RTC_SERVER_URL = "wss://192.168.200.112:8081/ws/"
    static let STUN_SERVER_URL = "stun:stun.l.google.com:19302"
    static let TURN_SERVER_URL = "https://turn.votebin.com"
    static let validateSsl = false
    
    static let audioOnly = false
    // Default Configs
    static let defaultOfferToReceiveAudio = true
    static let defaultOfferToReceiveVideo = !audioOnly
    
    static let defaultReceiveMedia = ["mandatory": ["OfferToReceiveAudio":defaultOfferToReceiveAudio, "OfferToReceiveVideo" :defaultOfferToReceiveVideo]];
    
    static let enableDataChannels = true
    
    static let peerVolumeWhenSpeaking = 0.25
    
    static let media = ["video":true, "audio" : true]
    
    static let enableSpeaker = true
    
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
    
    static func useSpeaker(){
        do{
            if RTCClientConfig.enableSpeaker {
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
    
    static let peerConnectionFactory = RTCPeerConnectionFactory()

    static func getMediaConstraints(receiveMedia: [String: Any]?) -> RTCMediaConstraints{
        
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
}
/* Some default stun servers 
 stun.l.google.com:19302
 stun1.l.google.com:19302
 stun2.l.google.com:19302
 stun3.l.google.com:19302
 stun4.l.google.com:19302
 stun01.sipphone.com
 stun.ekiga.net
 stun.fwdnet.net
 stun.ideasip.com
 stun.iptel.org
 stun.rixtelecom.se
 stun.schlund.de
 stunserver.org
 stun.softjoys.com
 stun.voiparound.com
 stun.voipbuster.com
 stun.voipstunt.com
 stun.voxgratia.org
 stun.xten.com
 */

protocol RTCClientDelegate {
    
    func rtcClientDidSetLocalMediaStream(client: RTCClient, authorized: Bool, audioOnly: Bool)

    func rtcClientDidAddRemoteMediaStream(client: RTCClient, peerConnection:RTCPeerConnection, stream: RTCMediaStream, audioOnly: Bool)

}

