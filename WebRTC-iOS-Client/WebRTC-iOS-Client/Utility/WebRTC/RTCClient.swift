//
//  RTCClient.swift
//  WebRTC-iOS-Client
//
//  Created by Disi A on 3/30/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

import UIKit
import WebRTC

let RTC_SERVER_URL = "http://localhost:8080"
let STUN_SERVER_URL = "stun:stun.l.google.com:19302"
let TURN_SERVER_URL = "https://turn.votebin.com"

class RTCClient {
    
    var audioMute = false
    var videoMute = false
    
    var localVideoTrack: RTCVideoTrack?
    
    var localAudioTrack: RTCAudioTrack?

    var localMediaStream: RTCMediaStream?

}
