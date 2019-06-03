//
//  ViewController.m
//  orderv2
//
//  Created by Kumari, Reena on 6/3/19.
//  Copyright © 2019 Kumari, Reena. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <SFSafariViewControllerDelegate>

@end

@implementation ViewController

NSString *CURRENCY_INR = @"INR";
NSString *CURRENCY_USD = @"USD";

NSString *BASE_URL = @"https://paypal-ec-server.herokuapp.com";
//NSString *BASE_URL = @"https://nequeo.serveo.net";
NSString *CREATE_URL = @"/api/paypal/orderv2/create/";
NSString *RETURN_URL = @"/api/paypal/orderv2/success";
NSString *CANCEL_URL = @"/api/paypal/orderv2/cancel";


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
    
    //[self openUrlInSVC:@"https://www.sandbox.paypal.com/checkoutnow?token=4D292096818577712"];
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
                                                    if([link[@"rel"]  isEqual: @"approve"]) {
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
    safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:url] configuration:NO];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:true completion:nil];
    NSLog(@"exit safari view controller");
}

- (NSDictionary*) payload {
    NSString *amount = [NSString stringWithFormat:@"%.02f",[self.amount.text floatValue]];
    NSDictionary *body = @{@"intent": @"CAPTURE",
                           @"application_context" : @{@"landing_page":@"LOGIN",
                                                      @"user_action":@"PAY_NOW",
                                                      @"return_url": [NSString stringWithFormat: @"%@%@", BASE_URL, RETURN_URL],
                                                      @"cancel_url": [NSString stringWithFormat: @"%@%@", BASE_URL, CANCEL_URL]
                                                      },
                           @"purchase_units": @[@{@"amount":
                                                    @{@"value": amount,
                                                      @"currency_code": self.currency.text
                                                      }
                                                }]
                           };
    return body;
}

- (void) success: (NSString *)token{
    NSLog(@"success paymentId: %@", token);
    [self displayAlertMessage: [NSString stringWithFormat:@"Payment completed, Payment Id: %@",token]];
}

- (void) cancel: (NSString *)token{
    NSLog(@"cancel ecToken: %@", token);
    [self displayAlertMessage: [NSString stringWithFormat:@"Payment cancelled, token: %@",token]];
}

- (void) error: (NSString *)token{
    NSLog(@"error ecToken: %@", token);
    [self displayAlertMessage: [NSString stringWithFormat:@"Some error occured, token: %@",token]];
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
