//
//  DDStoreKitController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@protocol DDStoreKitControllerDelegate

@optional

- (void)productsReceived:(NSArray*)products;
- (void)productsReceivingFailed:(NSError*)error;

@end

@interface DDStoreKitController : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
	id<DDStoreKitControllerDelegate> delegate_;
	SKProductsRequest *request_;
	NSArray *products_;
}

@property(assign) id<DDStoreKitControllerDelegate> delegate;

+ (DDStoreKitController *)sharedController;

- (void)requestProductDataWithPids:(NSSet*)pids;

- (NSString*)localizedPriceOfProductWithPid:(NSString*)pid;
- (NSString*)descriptionOfProductWithPid:(NSString*)pid;
- (NSString*)titleOfProductWithPid:(NSString*)pid;

@end
