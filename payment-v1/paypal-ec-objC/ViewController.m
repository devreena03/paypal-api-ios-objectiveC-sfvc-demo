//
//  ViewController.m
//  paypal-ec-objC
//
//  Created by Kumari, Reena on 10/1/18.
//  Copyright © 2018 Kumari, Reena. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <SFSafariViewControllerDelegate>

@end

@implementation ViewController

NSString *CURRENCY_INR = @"INR";
NSString *CURRENCY_USD = @"USD";

NSString *BASE_URL = @"https://paypal-ec-server.herokuapp.com";
NSString *CREATE_URL = @"/api/paypal/ec/create-payment/";
NSString *RETURN_URL = @"/api/paypal/ec/success";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.amount.text = @"1.00";
    self.currency.text = CURRENCY_INR;
    indicator = [self getActivityIndicator];
}

- (IBAction)currencySwitch:(id)sender {
    if ([sender isOn]) {
        self.currency.text = CURRENCY_INR;
    } else {
        self.currency.text = CURRENCY_USD;
    }
    
}

- (IBAction)payNow:(id)sender {
    
    
    NSDictionary *requestBody = [self payload];

    NSString *createPayment = [NSString stringWithFormat: @"%@%@", BASE_URL, CREATE_URL];
    
    NSData *httpBody = [NSJSONSerialization dataWithJSONObject:requestBody options:kNilOptions error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    [request setURL:[NSURL URLWithString:createPayment]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:httpBody];
    
    [self startProgress];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:kNilOptions
                                                                                                           error:nil];
                                                NSArray *links = jsonData[@"links"];
                                                for(id link in links) {
                                                    if([link[@"rel"]  isEqual: @"approval_url"]) {
                                                        NSString *approval_url = link[@"href"];
                                                        [self stopProgress];
                                                        [self openUrlInSVC:approval_url];
                                                        break;
                                                    }
                                                }
                                }];
    [task resume];
    
}

-(void) openUrlInSVC:(NSString*) url {
    NSLog(@"enter safari view controller");
    NSLog(@"%@", url);
    safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:url] entersReaderIfAvailable:NO];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:true completion:nil];
    NSLog(@"exit safari view controller");
}

- (NSDictionary*) payload {
    NSString *amount = [NSString stringWithFormat:@"%.02f",[self.amount.text floatValue]];
    NSDictionary *body = @{@"intent": @"sale",
                           @"payer": @{@"payment_method": @"paypal"},
                           @"application_context" : @{@"landing_page":@"login",
                                                      @"user_action":@"commit"},
                           @"transactions": @[@{@"amount":
                                                    @{@"total": amount,
                                                      @"currency": self.currency.text
                                                      }
                                                }],
                           @"redirect_urls" : @{
                                   @"return_url": [NSString stringWithFormat: @"%@%@", BASE_URL, RETURN_URL],
                                   @"cancel_url": @"com.reena.ec-rest://cancel"
                                   }
                           };
    return body;
}

- (void) success: (NSString *)paymentId{
    NSLog(@"success paymentId: %@", paymentId);
    [self displayAlertMessage: [NSString stringWithFormat:@"Payment completed, Payment Id: %@",paymentId]];
}

- (void) cancel: (NSString *)ecToken{
    NSLog(@"cancel ecToken: %@", ecToken);
    [self displayAlertMessage: [NSString stringWithFormat:@"Payment cancelled, Ec-token: %@",ecToken]];
}

- (void) error: (NSString *)ecToken{
    NSLog(@"error ecToken: %@", ecToken);
    [self displayAlertMessage: [NSString stringWithFormat:@"Some error occured, Ec-token: %@",ecToken]];
}

- (void) displayAlertMessage: (NSString *) msg{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                   message:msg
                                                   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *userAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:userAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIActivityIndicatorView *) getActivityIndicator {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = self.view.center;
    activityIndicator.hidesWhenStopped = true;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    return activityIndicator;

}

- (void) startProgress {
    [[self view] addSubview: indicator];
    [indicator startAnimating];
}

- (void) stopProgress{
    [indicator stopAnimating];
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    NSLog(@"dismiss");
    [controller dismissViewControllerAnimated:true completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
