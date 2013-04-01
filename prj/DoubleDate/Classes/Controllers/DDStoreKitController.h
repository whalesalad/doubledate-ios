//
//  DDStoreKitController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@protocol DDStoreKitControllerDelegate

@optional

- (void)productsReceived:(NSArray*)products;
- (void)productsReceivingFailed:(NSError*)error;

- (void)productPurchasingIsNotAuthorized;

- (void)productPurchased:(NSString*)pid;
- (void)productPurchasingFailed:(NSError*)error;

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

- (void)purchaseProductWithPid:(NSString*)pid;

- (NSString*)localizedPriceOfProductWithPid:(NSString*)pid;
- (NSString*)descriptionOfProductWithPid:(NSString*)pid;
- (NSString*)titleOfProductWithPid:(NSString*)pid;

@end
