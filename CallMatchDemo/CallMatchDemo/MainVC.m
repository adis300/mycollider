//
//  MainVC.m
//  CallMatchDemo
//
//  Created by Innovation on 4/29/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

#import "AppDelegate.h"
#import "MainVC.h"
#import "UIHelper.h"

@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Pseudo load username
    _usernameLabel.text = ((AppDelegate *)[UIApplication sharedApplication].delegate).username;
    
}

@end
