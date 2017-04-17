//
//  ViewController.swift
//  WebRTC-iOS-Client
//
//  Created by Innovation on 3/30/17.
//  Copyright © 2017 Disi A. All rights reserved.
//

import UIKit
import RTCSignaling

let serverUrl = "wss://iconthin.com:8443/ws/"
// let roomId = "abc"

class ViewController: UIViewController {
    
    var localVideoTrack: RTCVideoTrack? //Not yet used
    var remoteVideoTrack: RTCVideoTrack? //Not yet used
    var useSpeaker = false
    var videoSwitch = true
    var audioSwitch = true
    
    @IBOutlet weak var remoteVideoContainer: UIView!
    @IBOutlet weak var localVideoContainer: UIView!
    
    @IBOutlet weak var roomIdField: UITextField!
    
    @IBAction func connectClick(_ sender: Any) {
        roomIdField.resignFirstResponder()
        if let text = roomIdField.text {
            let roomId = text.replacingOccurrences(of: " ", with: "")
            if !roomId.isEmpty{
                RTCClient.shared.connect(serverUrl: serverUrl, roomId: roomId, delegate: self)
                return
            }
        }
        let alert = UIAlertController(title: "Sorry", message: "Please enter a valid roomId", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        RTCClient.shared.setAudioOutput(useSpeaker: useSpeaker)
    }

}
extension ViewController: RTCClientDelegate{
    
    func rtcClientDidSetLocalMediaStream(client: RTCSignaling.RTCClient, authorized: Bool, audioOnly: Bool){
        if authorized{
            client.setLocalVideoContainer(view: localVideoContainer)
        }else{
            assertionFailure("Unauthorized to access media device")
        }
    }
    
    func rtcClientDidAddRemoteMediaStream(client: RTCSignaling.RTCClient, peer: RTCSignaling.RTCPeer, stream: RTCMediaStream, audioOnly: Bool){
        peer.setRemoteVideoContainer(view: remoteVideoContainer)
    }
    
    func rtcClientDidRemoveRemoteMediaStream(client: RTCSignaling.RTCClient, peer: RTCSignaling.RTCPeer, stream: RTCMediaStream, audioOnly: Bool){
        print("Remote peer did finish.")
    }

}

