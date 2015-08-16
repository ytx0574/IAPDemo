//
//  ViewController.m
//  IapPurchase
//
//  Created by Johnson on 8/14/15.
//  Copyright (c) 2015 Johnson. All rights reserved.
//

#import "ViewController.h"
@import StoreKit;

#ifdef DEBUG
    #define StoreURL [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"]
#else
    #define StoreURL [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"]
#endif

@interface ViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation ViewController
- (IBAction)xx:(id)sender {
    if ([SKPaymentQueue canMakePayments]) {
        [self getProductsInfo];
    } else {
        NSLog(@"失败，用户禁止应用内付费购买.");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self xx:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getProductsInfo
{
    NSSet * set = [NSSet setWithArray:@[@"com.Johnson.purchase.one",
                                        @"com.Johnson.purchase.two",
                                        @"com.Johnson.purchase.three",
                                        @"com.Johnson.purchase.four",
                                        @"com.Johnson.purchase.five"]];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response NS_AVAILABLE_IOS(3_0);
{
    NSLog(@"%@\n%@",response.products, response.invalidProductIdentifiers);
    if (response.products.count == 0) {
        NSLog(@"无法获取产品信息，购买失败。");
        return;
    }
    SKProduct *productOne = response.products.firstObject;
    
    SKPayment * payment = [SKPayment paymentWithProduct:productOne];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
  }

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions NS_AVAILABLE_IOS(3_0);
{
    SKPaymentTransaction *transaction = transactions.firstObject;
    
    if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
        
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
        
        NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/receipt"];
        [receipt writeToFile:path atomically:YES];
        
        NSError *error;
        NSDictionary *requestContents = @{
                                          @"receipt-data": [receipt base64EncodedStringWithOptions:0]
                                          };
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                              options:0
                                                                error:&error];
        
        if (!requestData) { /* ... Handle error ... */ }
        
        // Create a POST request with the receipt data.
        NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:StoreURL];
        [storeRequest setHTTPMethod:@"POST"];
        [storeRequest setHTTPBody:requestData];
        [NSURLConnection sendAsynchronousRequest:storeRequest queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            id xx = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            NSLog(@"¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨%@¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨", xx);
        }];
    }
}
// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions NS_AVAILABLE_IOS(3_0);
{
//    SKPaymentTransaction *transaction = transactions.firstObject;
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error NS_AVAILABLE_IOS(3_0);
{
    
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue NS_AVAILABLE_IOS(3_0);
{

}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads NS_AVAILABLE_IOS(6_0);
{

}

@end
