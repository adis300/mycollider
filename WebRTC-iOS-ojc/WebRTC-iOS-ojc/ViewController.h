//
//  ViewController.h
//  WebRTC-iOS-ojc
//
//  Created by Innovation on 4/12/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RTCSignaling/RTCSignaling-Swift.h>

@interface ViewController : UIViewController<RTCClientDelegate>

- (void)rtcClientDidSetLocalMediaStreamWithClient:(RTCClient *)client authorized:(BOOL)authorized audioOnly:(BOOL)audioOnly;
- (void)rtcClientDidAddRemoteMediaStreamWithPeer:(RTCPeer *)peer stream:(RTCMediaStream *)stream audioOnly:(BOOL)audioOnly;

@end

