//
//  ViewController.swift
//  WebRTC-iOS-Client
//
//  Created by Innovation on 3/30/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

import UIKit
import WebRTC

class ViewController: UIViewController {

    let rtcClient = RTCClient()
    
    var localVideoTrack: RTCVideoTrack? //Not yet used
    var remoteVideoTrack: RTCVideoTrack? //Not yet used
    var useSpeaker = false
    
    @IBOutlet weak var remoteVideoView: RTCEAGLVideoView!
    @IBOutlet weak var localVideoView: RTCEAGLVideoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rtcClient.initialize(delegate: self)
    }

    func joinRoom(){
        
        rtcClient.connect(roomId: "abc")

        /*
        let videoSource = factory.avFoundationVideoSource(with: RTCFactory.getMediaConstraints(receiveMedia: nil))
        let previewLayer = AVCaptureVideoPreviewLayer(session: videoSource.captureSession)
        previewLayer?.frame = localVideoView.bounds
        
        // localVideoTrack?.add(localVideoView)
        
        localVideoView.layer.addSublayer(previewLayer!)
        
        //let localMediaStream = RTCMediaStream()
        rtcClient.localVideoTrack = factory.videoTrack(with: videoSource, trackId: "localVideoTrack")
        */
        //rtcClient
    }

    @IBAction func toggleSpeaker(_ sender: Any) {
        useSpeaker = !useSpeaker
        
        RTCClientConfig.setAudioOutput(enableSpeaker: useSpeaker)
    }

}
extension ViewController: RTCClientDelegate{
    
    func rtcClientDidSetLocalMediaStream(client: RTCClient, authorized: Bool, audioOnly: Bool){
        if authorized{
            if !audioOnly{
                
                client.localVideoTrack?.add(localVideoView)
 
                client.connect(roomId: "abc")

            }else{
                assertionFailure("Wrong config")
            }
        }else{
            assertionFailure("Unauthorized to access media device")
        }
        
    }
    
    func rtcClientDidAddRemoteMediaStream(client: RTCClient, peerConnection:RTCPeerConnection, stream: RTCMediaStream, audioOnly: Bool){
        // remoteVideoView.renderFrame(nil)
        remoteVideoTrack = stream.videoTracks.first
        stream.videoTracks.first?.add(remoteVideoView)
        RTCClientConfig.setAudioOutput(enableSpeaker: useSpeaker)

    }
    
    

}

