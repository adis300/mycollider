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
    static let RTC_SERVER_URL = "wss://localhost:8081/ws/"
    static let STUN_SERVER_URL = "stun:stun.l.google.com:19302"
    static let TURN_SERVER_URL = "https://turn.votebin.com"
    
    // Default Configs
    static let defaultOfferToReceiveAudio = true
    static let defaultOfferToReceiveVideo = true
    
    static let defaultReceiveMedia = ["mandatory": ["OfferToReceiveAudio":defaultOfferToReceiveAudio, "OfferToReceiveVideo" :defaultOfferToReceiveVideo]];
    
    static let enableDataChannels = true
    
    static let peerVolumeWhenSpeaking = 0.25
    
    static let media = ["video":true, "audio" : true]
    
    // If loopback
    // static let kDefaultMediaConstraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio":"true", "OfferToReceiveVideo" :"true"], optionalConstraints: ["DtlsSrtpKeyAgreement" : "true"])
    
    static let defaultOptions:[String: Any] = [:]
    
    static let dataChannelConfiguration = RTCDataChannelConfiguration()
    
    
    
}

class RTCFactory{
    
    static func getMediaConstraints(receiveMedia: [String: Any]) -> RTCMediaConstraints{
        
        let mandatory = receiveMedia["mandatory"] as! [String: Bool]
        
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
