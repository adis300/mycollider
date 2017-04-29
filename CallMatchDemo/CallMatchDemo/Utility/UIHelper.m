//
//  UIHelper.h
//
//  Created by by Disi A on 3/14/17.
//

#import "UIHelper.h"
#import "AppDelegate.h"

static UIView *  currentLoadingView;

static CGFloat kLoadingViewWidth = 160;
static CGFloat kLoadingViewHeight = 180;
static CGFloat kLoadingViewMargin = 20;

@implementation UIHelper

+ (void) showAlert: (NSString * ) title message: (NSString * ) message {
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [UIHelper showAlert:title message:message viewController:vc];
    
}

+ (void) showAlert: (NSString * ) title message: (NSString * ) message viewController: (UIViewController * )vc{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: nil];
    
    [alert addAction:okAction];
    
    [vc presentViewController:alert animated:YES completion:nil];
    
}

+ (void) showLoadingIndicator: (UIViewController *) viewController message: (NSString * ) msg {
    [UIHelper showLoadingIndicatorOnView:viewController.view message:msg];
}

+ (void) showLoadingIndicatorOnView: (UIView *) parentView message: (NSString * ) msg {
    // Clear out existing loading view
    [UIHelper dismissLoadingIndicator];
    
    // Create dimmer and loading view
    UIView* dimmer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height)];
    
    dimmer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    
    UIView * loadingView = [[UIView alloc] initWithFrame: CGRectMake(dimmer.frame.origin.x + dimmer.frame.size.width/2 - kLoadingViewWidth/2, dimmer.frame.origin.y + dimmer.frame.size.height/2 - kLoadingViewHeight/2, kLoadingViewWidth, kLoadingViewHeight)];
    
    loadingView.layer.cornerRadius = 16;
    loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    // Create activity indicator and text message
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(kLoadingViewMargin, kLoadingViewMargin, kLoadingViewWidth - 2 * kLoadingViewMargin, kLoadingViewWidth - 2 * kLoadingViewMargin);
    
    [activityIndicator startAnimating];
    
    UILabel* messageLabel =  [[UILabel alloc] initWithFrame:CGRectMake(kLoadingViewMargin, kLoadingViewWidth - 1.6 * kLoadingViewMargin, kLoadingViewWidth - 2 * kLoadingViewMargin, 20)];
    
    messageLabel.text = msg;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = [UIColor whiteColor];
    
    // Adding activity indicator
    [loadingView addSubview:activityIndicator];
    [loadingView addSubview:messageLabel];
    [dimmer addSubview:loadingView];
    [parentView addSubview:dimmer];
    currentLoadingView = dimmer;
}

+(void) dismissLoadingIndicator {
    if(currentLoadingView) {
        [currentLoadingView removeFromSuperview];
        currentLoadingView = nil;
    }
}

@end
