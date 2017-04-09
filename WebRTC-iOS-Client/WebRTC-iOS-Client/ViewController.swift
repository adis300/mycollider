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

    let factory = RTCPeerConnectionFactory()
    let rtcClient = RTCClient()
    
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTracks: [RTCVideoTrack] = [];
    
    @IBOutlet weak var localVideoView: RTCEAGLVideoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        localVideoView.backgroundColor = UIColor.black
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
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


}
extension ViewController: RTCClientDelegate{
    
    func rtcClientDidSetLocalMediaStream(client: RTCClient, authorized: Bool, audioOnly: Bool){
        if authorized{
            if !audioOnly{
                localVideoTrack = client.localVideoTrack
                // let localView = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                // localView.backgroundColor = UIColor.red
                localVideoTrack?.remove(localVideoView)
                localVideoView.renderFrame(nil)
                
                localVideoTrack?.add(localVideoView)
                print("ADDED renderer")
                client.connect(roomId: "abc")

            }else{
                assertionFailure("Wrong config")
            }
        }else{
            assertionFailure("Unauthorized to access media device")
        }
        
    }

}

