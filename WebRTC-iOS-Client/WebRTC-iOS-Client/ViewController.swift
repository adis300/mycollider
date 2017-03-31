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

    var localVideoTrack:RTCVideoTrack?
    
    @IBOutlet weak var localVideoView: RTCEAGLVideoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addLocalPreview()
        
    }

    func addLocalPreview(){
        let mediaConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        
        let videoSource = factory.avFoundationVideoSource(with: mediaConstraints)
        let previewLayer = AVCaptureVideoPreviewLayer(session: videoSource.captureSession)
        previewLayer?.frame = localVideoView.bounds
        
        localVideoTrack = factory.videoTrack(with: videoSource, trackId: "localVideoTrack")
        // localVideoTrack?.add(localVideoView)
        localVideoView.backgroundColor = UIColor.black
        
        localVideoView.layer.addSublayer(previewLayer!)
    }


}

