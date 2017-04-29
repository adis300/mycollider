//
//  UIHelper.h
//
//  Created by by Disi A on 3/14/17.
//

#import <UIKit/UIKit.h>

@interface UIHelper : NSObject

+ (void) showAlert: (NSString * ) title message: (NSString * ) message viewController: (UIViewController * )vc;
+ (void) showAlert: (NSString * ) title message: (NSString * ) message;

+ (void) showLoadingIndicator: (UIViewController *) viewController message: (NSString * ) msg;
+ (void) showLoadingIndicatorOnView: (UIView *) parentView message: (NSString * ) msg;

+(void) dismissLoadingIndicator;

@end
