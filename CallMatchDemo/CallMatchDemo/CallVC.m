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

#define SERVER_URL @"http://iconthin:8080/"

NSString* username = nil;
NSString* gender = nil;

@interface CallVC ()

@end

@implementation CallVC

- (void)viewDidLoad {
    [super viewDidLoad];
    username = ((AppDelegate *)[UIApplication sharedApplication].delegate).username;
    gender = ((AppDelegate *)[UIApplication sharedApplication].delegate).gender;

    [self startCall];
}

- (void) startCall {
    [UIHelper showLoadingIndicator:self message:@"Calling"];
    NSString* url = [NSString stringWithFormat:@"%@%@%@%@%@", SERVER_URL, @"match?uname=", username, @"&gender=", gender];
    [HTTPRequest get:url success:^(NSDictionary<NSString *,id> * response) {
        NSLog(@"%@", response[@"inst"]);
    } failure:^(NSError *  err) {
        NSLog(@"%@", err);
    }];
    

}

-(void) endCall {
    [UIHelper dismissLoadingIndicator];
}

@end
