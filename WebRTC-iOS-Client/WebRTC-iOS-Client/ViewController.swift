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
        
        addLocalPreview()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    func addLocalPreview(){
        
        rtcClient.initialize(delegate: self)
        /*
        let videoSource = factory.avFoundationVideoSource(with: RTCFactory.getMediaConstraints(receiveMedia: nil))
        let previewLayer = AVCaptureVideoPreviewLayer(session: videoSource.captureSession)
        previewLayer?.frame = localVideoView.bounds
        
        // localVideoTrack?.add(localVideoView)
        localVideoView.backgroundColor = UIColor.black
        
        localVideoView.layer.addSublayer(previewLayer!)
        
        //let localMediaStream = RTCMediaStream()
        rtcClient.localVideoTrack = factory.videoTrack(with: videoSource, trackId: "localVideoTrack")
        rtcClient.connect(roomId: "myroom")
        */
        //rtcClient
    }


}
extension ViewController: RTCClientDelegate{
    
    func rtcClientDidSetLocalMediaStream(client: RTCClient, authorized: Bool, audioOnly: Bool){
        if authorized{
            if !audioOnly{
                localVideoTrack = client.localVideoTrack
                localVideoTrack?.add(localVideoView)
            }else{
                assertionFailure("Wrong config")
            }
        }else{
            assertionFailure("Unauthorized to access media device")
        }
        
        
    }

}

