//
//  CallVC.m
//  CallMatchDemo
//
//  Created by Innovation on 4/29/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

#import "CallVC.h"
#import "UIHelper.h"
#import "AppDelegate.h"
#import "HTTPRequest.h"



#define SERVER_URL @"https://iconthin.com:8443/"
#define SOCKET_SERVER_URL @"wss://iconthin.com:8443/ws/"

NSString* username = nil;
NSString* gender = nil;

dispatch_queue_t taskQueue;

@interface CallVC ()
@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;

@end

@implementation CallVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _connectedLabel.hidden = YES;
    username = ((AppDelegate *)[UIApplication sharedApplication].delegate).username;
    gender = ((AppDelegate *)[UIApplication sharedApplication].delegate).gender;

    [self startCall];
}

- (void) startCall {
    [UIHelper showLoadingIndicator:self message:@"Calling"];
    NSString* url = [NSString stringWithFormat:@"%@%@%@%@%@", SERVER_URL, @"match?uname=", username, @"&gen=", gender];
    [HTTPRequest get:url success:^(NSDictionary<NSString *,id> * response) {
        NSString * instrction = response[@"inst"];
        if ([instrction isEqualToString:@"wait"]){
            NSLog(@"Instruct client to wait");
            [self waitForMatch];
        }else if ([instrction isEqualToString:@"join"]){
            NSString* roomId = response[@"data"];
            NSLog(@"Instruct client to join room: %@", roomId);
            [self startCall:roomId];
        }else{
            [UIHelper showAlert:@"Error" message:@"Unknown instruction" viewController:self okClick:^(UIAlertAction *action) {
                [self endCall];
            }];
        }
    } failure:^(NSError *  err) {
        [UIHelper showAlert:@"Error" message:err.localizedDescription viewController:self okClick:^(UIAlertAction *action) {
            [self endCall];
        }];
    }];
    
}

-(void) waitForMatch{
    NSLog(@"Waiting for a match");
    [self checkRoom];
    
}
-(void) checkRoom{
    NSLog(@"Checking for room match");
    NSString* url = [NSString stringWithFormat:@"%@%@%@", SERVER_URL, @"myroom?uname=", username];
    [HTTPRequest get:url success:^(NSDictionary<NSString *,id> * response) {
        if ([response[@"data"] isKindOfClass:[NSNull class]] || !response[@"data"]){
            [self scheduleTaskAfter:5 callback:^{
                [self checkRoom];
            }];
        }else{
            NSString* roomId = response[@"data"];
            [self startCall: roomId];
        }
    } failure:^(NSError * err) {
        [UIHelper showAlert:@"Error" message:err.localizedDescription viewController:self okClick:^(UIAlertAction *action) {
            [self endCall];
        }];
    }];
    
}

-(dispatch_queue_t) getTaskQueue{
    if(!taskQueue) taskQueue = dispatch_queue_create([@"wait_for_match_queue" cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    return taskQueue;
}

- (void) scheduleTaskAfter: (int) sec callback: (void (^)(void))cb{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), [self getTaskQueue], ^{
        dispatch_async(dispatch_get_main_queue(), cb);
    });
}

-(void) startCall: (NSString*) roomId{
    NSLog(@"Starting a call session in room: %@", roomId);
    NSDictionary<NSString*, NSString*>* params = @{@"uname":username};
    [RTCClient.shared connectWithServerUrl:SOCKET_SERVER_URL roomId:roomId delegate:self params: params];
}

-(void) endCall {
    [UIHelper dismissLoadingIndicator];
    [RTCClient.shared disconect];
    
    [self performSegueWithIdentifier:@"callend_segue" sender:self];

}

- (void)rtcClientDidSetLocalMediaStreamWithClient:(RTCClient *)client authorized:(BOOL)authorized audioOnly:(BOOL)audioOnly{
    if(authorized) NSLog(@"Local stream OK, continue");
    else [UIHelper showAlert:@"Error" message: @"Unable to access microphone" viewController:self];
    
}
- (void)rtcClientDidAddRemoteMediaStreamWithClient:(RTCClient *)client peer:(RTCPeer *)peer stream:(RTCMediaStream *)stream audioOnly:(BOOL)audioOnly{
    [UIHelper dismissLoadingIndicator];
    _connectedLabel.hidden = NO;

}
- (void)rtcClientDidRemoveRemoteMediaStreamWithClient:(RTCClient *)client peer:(RTCPeer *)peer stream:(RTCMediaStream *)stream audioOnly:(BOOL)audioOnly{
    NSLog(@"Remote peer removed");
    [UIHelper showAlert:@"Notice" message:@"Call ended" viewController:self okClick:^(UIAlertAction *action) {
        [self endCall];
    }];
}

@end
