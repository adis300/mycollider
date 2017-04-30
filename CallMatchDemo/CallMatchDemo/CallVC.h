//
//  CallVC.h
//  CallMatchDemo
//
//  Created by Disi A on 4/29/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RTCSignaling/RTCSignaling-Swift.h>

@interface CallVC : UIViewController<RTCClientDelegate>

- (void)rtcClientDidSetLocalMediaStreamWithClient:(RTCClient *)client authorized:(BOOL)authorized audioOnly:(BOOL)audioOnly;
- (void)rtcClientDidAddRemoteMediaStreamWithClient:(RTCClient *)client peer:(RTCPeer *)peer stream:(RTCMediaStream *)stream audioOnly:(BOOL)audioOnly;
- (void)rtcClientDidRemoveRemoteMediaStreamWithClient:(RTCClient *)client peer:(RTCPeer *)peer stream:(RTCMediaStream *)stream audioOnly:(BOOL)audioOnly;

@end
