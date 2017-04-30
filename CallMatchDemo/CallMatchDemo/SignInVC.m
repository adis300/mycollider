//
//  SignInVC.m
//  CallMatchDemo
//
//  Created by Disi A on 4/28/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

#import "SignInVC.h"
#import "AppDelegate.h"
#import "UIHelper.h"

@interface SignInVC ()

@end

@implementation SignInVC

- (IBAction)signInClick:(id)sender {
    if([_usernameField.text length] > 0){
        AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.username = _usernameField.text;
        appDelegate.gender = _genderSelector.selectedSegmentIndex == 0 ? @"m" : @"f";
        [self performSegueWithIdentifier:@"signin_segue" sender:self];
    }else{
        [UIHelper showAlert:@"Sorry" message:@"Please enter a valid username" viewController:self];
    }
    
}

@end
