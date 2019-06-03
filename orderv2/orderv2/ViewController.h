//
//  ViewController.h
//  orderv2
//
//  Created by Kumari, Reena on 6/3/19.
//  Copyright © 2019 Kumari, Reena. All rights reserved.
//

#import <UIKit/UIKit.h>
@import SafariServices;

@interface ViewController : UIViewController
{
    SFSafariViewController *safariVC;
    UIActivityIndicatorView *indicator;
}


@property (weak, nonatomic) IBOutlet UITextField *amount;
@property (weak, nonatomic) IBOutlet UILabel *currency;

- (IBAction)currencySwitch:(id)sender;
- (IBAction)payNow:(id)sender;
- (NSDictionary*) payload;
- (void) openUrlInSVC:(NSString*) url;
- (void) success: (NSString *)token;
- (void) cancel: (NSString *)token;
- (void) error: (NSString *)token;

@end
