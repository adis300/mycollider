//
//  ViewController.m
//  WebRTC-iOS-ojc
//
//  Created by Innovation on 4/12/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

#import "ViewController.h"

#define SERVER_URL "wss://iconthin.com:8443/ws/"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *localVideoContainer;
@property (weak, nonatomic) IBOutlet UIView *remoteVideoContainer;

@property (weak, nonatomic) IBOutlet UITextField *roomIdField;

@property (nonatomic) BOOL audioOn;
@property (nonatomic) BOOL videoOn;
@property (nonatomic) BOOL useSpeaker;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [RTCClientConfig loadWithConfig:@{@"audioOnly": @YES}];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _audioOn = YES;
    _videoOn = YES;
    _useSpeaker = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectClick:(id)sender {
    [_roomIdField resignFirstResponder];
    
    if(_roomIdField.text.length > 0){
        NSString* roomId = [_roomIdField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        [RTCClient.shared connectWithServerUrl:@SERVER_URL roomId:roomId delegate:self];
    }else{
        // Show an alert, useless code
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please enter an roomId"preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (IBAction)audioClick:(id)sender {
    _audioOn = !_audioOn;
    [RTCClient.shared setAudioOn:_audioOn];
}
- (IBAction)videoClick:(id)sender {
    _videoOn = !_videoOn;
    [RTCClient.shared setVideoOn:_videoOn];

}
- (IBAction)speakerClick:(id)sender {
    _useSpeaker = !_useSpeaker;
    [RTCClient.shared setAudioOutputWithUseSpeaker:_useSpeaker];
}
- (IBAction)disconnectClick:(id)sender {
    [RTCClient.shared disconect];
}

#pragma mark - RTCClientDelegate metods impl

- (void)rtcClientDidSetLocalMediaStreamWithClient:(RTCClient *)client authorized:(BOOL)authorized audioOnly:(BOOL)audioOnly{
    if(authorized){
        [client setLocalVideoContainerWithView:_localVideoContainer];
    }else{
        // Show an alert, useless code
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Unable to access camera"preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (void)rtcClientDidAddRemoteMediaStreamWithPeer:(RTCPeer *)peer stream:(RTCMediaStream *)stream audioOnly:(BOOL)audioOnly{
    [peer setRemoteVideoContainerWithView:_remoteVideoContainer];
    
}



@end
