//
//  ViewController.swift
//  WebRTC-iOS-Client
//
//  Created by Innovation on 3/30/17.
//  Copyright © 2017 Disi A. All rights reserved.
//

import UIKit
import WebRTC

class ViewController: UIViewController {

    let rtcClient = RTCClient()
    
    var localVideoTrack: RTCVideoTrack? //Not yet used
    var remoteVideoTrack: RTCVideoTrack? //Not yet used
    var useSpeaker = false
    var videoSwitch = true
    var audioSwitch = true
    
    @IBOutlet weak var remoteVideoView: RTCEAGLVideoView!
    @IBOutlet weak var localVideoContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rtcClient.initialize(delegate: self)
    }

    @IBAction func videoSwitchClick(_ sender: Any) {
        videoSwitch = !videoSwitch
        rtcClient.setVideo(on: videoSwitch)
    }
    
    @IBAction func audioSwitchClick(_ sender: Any) {
        audioSwitch = !audioSwitch
        rtcClient.setAudio(on: audioSwitch)
    }
    
    func joinRoom(){
        rtcClient.connect(roomId: "abc")
    }

    @IBAction func toggleSpeaker(_ sender: Any) {
        useSpeaker = !useSpeaker
        
        RTCClientConfig.setAudioOutput(useSpeaker: useSpeaker)
    }

}
extension ViewController: RTCClientDelegate{
    
    func rtcClientDidSetLocalMediaStream(client: RTCClient, authorized: Bool, audioOnly: Bool){
        if authorized{
            if !audioOnly{
                client.setLocalVideoContainer(view: localVideoContainer)
                client.connect(roomId: "abc")

            }else{
                assertionFailure("Wrong config")
            }
        }else{
            assertionFailure("Unauthorized to access media device")
        }
        
    }
    
    func rtcClientDidAddRemoteMediaStream(client: RTCClient, peerConnection:RTCPeerConnection, stream: RTCMediaStream, audioOnly: Bool){
        remoteVideoTrack = stream.videoTracks.first
        stream.videoTracks.first?.add(remoteVideoView)
        RTCClientConfig.setAudioOutput(useSpeaker: useSpeaker)

    }

}

