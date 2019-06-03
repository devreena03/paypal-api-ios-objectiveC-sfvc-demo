//
//  ViewController.h
//  paypal-ec-objC
//
//  Created by Kumari, Reena on 10/1/18.
//  Copyright © 2018 Kumari, Reena. All rights reserved.
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
- (void) success: (NSString *)paymentId;
- (void) cancel: (NSString *)ecToken;
- (void) error: (NSString *)ecToken;

@end

