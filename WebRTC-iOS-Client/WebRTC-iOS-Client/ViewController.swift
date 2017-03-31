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

    var localVideoTrack:RTCVideoTrack?
    
    @IBOutlet weak var localVideoView: RTCEAGLVideoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let factory = RTCPeerConnectionFactory()
        let mediaConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let videoSource = factory.avFoundationVideoSource(with: mediaConstraints)
        let captureSession = videoSource.captureSession;
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = localVideoView.bounds
        
        localVideoTrack = factory.videoTrack(with: videoSource, trackId: "localTrack")
        // localVideoTrack?.add(localVideoView)
        localVideoView.backgroundColor = UIColor.black
        
        localVideoView.layer.addSublayer(previewLayer!)
        
        
        // [self.localView.layer addSublayer:self.previewLayer];

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

