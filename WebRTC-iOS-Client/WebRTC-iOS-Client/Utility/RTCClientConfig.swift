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
    static let defaultMediaConstriantsMandatory = ["OfferToReceiveAudio":"true", "OfferToReceiveVideo" :"true"];
    static let defaultMediaConstraints = RTCMediaConstraints(mandatoryConstraints: defaultMediaConstriantsMandatory, optionalConstraints: nil)
    
    static let enableDataChannels = true
    
    static let peerVolumeWhenSpeaking = 0.25
    
    static let media = ["video":true, "audio" : true]
    
    // If loopback
    // static let kDefaultMediaConstraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio":"true", "OfferToReceiveVideo" :"true"], optionalConstraints: ["DtlsSrtpKeyAgreement" : "true"])
    
    static let defaultOptions:[String: Any] = [:]
    
}
