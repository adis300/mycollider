//
//  ViewController.swift
//  WebRTC-iOS-Client
//
//  Created by Innovation on 3/30/17.
//  Copyright © 2017 Disi A. All rights reserved.
//

import UIKit
import WebRTC

let serverUrl = "wss://192.168.200.112:8443/ws/"
let roomId = "abc"

class ViewController: UIViewController {
    
    var localVideoTrack: RTCVideoTrack? //Not yet used
    var remoteVideoTrack: RTCVideoTrack? //Not yet used
    var useSpeaker = false
    var videoSwitch = true
    var audioSwitch = true
    
    @IBOutlet weak var remoteVideoContainer: UIView!
    @IBOutlet weak var localVideoContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RTCClientConfig.setAudioOutput(useSpeaker: useSpeaker)
        RTCClient.shared.initialize(delegate: self)
    }

    @IBAction func videoSwitchClick(_ sender: Any) {
        videoSwitch = !videoSwitch
        RTCClient.shared.setVideo(on: videoSwitch)
    }
    
    @IBAction func audioSwitchClick(_ sender: Any) {
        audioSwitch = !audioSwitch
        RTCClient.shared.setAudio(on: audioSwitch)
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
            }
            client.connect(serverUrl: serverUrl, roomId: roomId)
        }else{
            assertionFailure("Unauthorized to access media device")
        }
        
    }
    
    func rtcClientDidAddRemoteMediaStream(peer: RTCPeer, stream: RTCMediaStream, audioOnly: Bool){
        if !audioOnly{
            peer.setRemoteVideoContainer(view: remoteVideoContainer)
        }
    }
}

