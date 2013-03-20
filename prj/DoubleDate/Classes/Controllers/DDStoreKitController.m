//
//  DDStoreKitController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDStoreKitController.h"
#import "DDTools.h"
#import "DDAuthenticationController.h"
#import "DDRequestsController.h"
#import <SBJson.h>
#import <RestKit/NSData+Base64.h>
#import <RestKit/RestKit.h>

@implementation DDStoreKitController

@synthesize delegate=delegate_;

static DDStoreKitController *_sharedController = nil;

+ (DDStoreKitController *)sharedController
{
	if (!_sharedController)
        _sharedController = [[self alloc] init];
    return _sharedController;
}

+ (NSString*)localizedPriceFromProduct:(SKProduct*)product
{
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	return [numberFormatter stringFromNumber:product.price];
}

- (id)init
{
	id ret = [super init];
	if (ret)
	{
		if ([SKPaymentQueue canMakePayments])
			[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return ret;
}

- (SKProduct*)productForPid:(NSString*)pid
{
    for (SKProduct *product in products_)
    {
        if ([product.productIdentifier isEqualToString:pid])
            return product;
    }
    return nil;
}

- (void)requestProductDataWithPids:(NSSet*)pids
{
	//delete old request
	request_.delegate = nil;
	[request_ release];
    
	//create new request
	request_= [[SKProductsRequest alloc] initWithProductIdentifiers: pids];
	request_.delegate = self;
	[request_ start];
}

- (void)purchaseProductWithPid:(NSString*)pid
{
    if ([SKPaymentQueue canMakePayments])
	{
		SKProduct *product = [self productForPid:pid];
		if (product)
		{
			NSLog(@"Try to purchase the product: %@", product.productIdentifier);
			SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
			payment.quantity = 1;
			[[SKPaymentQueue defaultQueue] addPayment:payment];
		}
        else
            NSLog(@"Error: product %@ not found", pid);
	}
	else
	{
		if ([(id)self.delegate respondsToSelector:@selector(productPurchasingIsNotAuthorized)])
			[(id)self.delegate productPurchasingIsNotAuthorized];
	}
}

- (NSString*)localizedPriceOfProductWithPid:(NSString*)pid
{
    return [[self class] localizedPriceFromProduct:[self productForPid:pid]];
}

- (NSString*)descriptionOfProductWithPid:(NSString*)pid
{
    return [[self productForPid:pid] localizedDescription];
}

- (NSString*)titleOfProductWithPid:(NSString*)pid
{
    return [[self productForPid:pid] localizedTitle];
}

- (void)provideTransaction:(SKPaymentTransaction*)transaction
{
    if (transaction.transactionState == SKPaymentTransactionStatePurchased)
    {
        //set dictionary
        NSMutableDictionary *purchaseDic = [NSMutableDictionary dictionary];
        [purchaseDic setObject:transaction.payment.productIdentifier forKey:@"identifier"];
        [purchaseDic setObject:[transaction.transactionReceipt base64EncodedString] forKey:@"receipt"];
        
        //create request
        NSString *requestPath = [[DDTools authUrlPath] stringByAppendingPathComponent:@"/me/purchases"];
        RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
        request.method = RKRequestMethodPOST;
        request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:[NSDictionary dictionaryWithObject:purchaseDic forKey:@"purchase"]];
        NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
        request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        //send request
        [[DDRequestsController sharedDummyController] startRequest:request];
    }
}

- (void)dealloc
{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
	[products_ release];
	[request_ release];
	[super dealloc];
}

#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	//check the request
	if (request == request_)
	{
		//remove all products
		[products_ release];
		products_ = nil;
		
		NSLog(@"Invalid products: %@", response.invalidProductIdentifiers);
		for (SKProduct *product in response.products)
			NSLog(@"Valid product: %@", product.productIdentifier);
        
		//set new products
		products_ = [response.products retain];
        
		//notify delegate
		if ([(id)self.delegate respondsToSelector:@selector(productsReceived:)])
			[(id)self.delegate productsReceived:products_];
		
		//release old request
		[request_ autorelease];
		request_ = nil;
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	//check the request
	if (request == request_)
	{
		NSLog(@"Error while requesting the products: %@", [error localizedDescription]);
		
		//notify delegate
		if ([(id)self.delegate respondsToSelector:@selector(productsReceivingFailed:)])
			[(id)self.delegate productsReceivingFailed:error];
		
		//release old request
		[request_ autorelease];
		request_ = nil;
	}
}

#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
	{
		//check transaction state
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				NSLog(@"Purchased the product: %@", transaction.payment.productIdentifier);
                [self provideTransaction:transaction];
				if ([(id)self.delegate respondsToSelector:@selector(productPurchased:)])
					[(id)self.delegate productPurchased:transaction.payment.productIdentifier];
                break;
            case SKPaymentTransactionStateFailed:
				NSLog(@"Purchasing of the product failed: %@", transaction.payment.productIdentifier);
                [self provideTransaction:transaction];
				if ([(id)self.delegate respondsToSelector:@selector(productPurchasingFailed:)])
					[(id)self.delegate productPurchasingFailed:transaction.error];
				break;
            default:
                break;
		}
		
		//finish transaction
		if (transaction.transactionState != SKPaymentTransactionStatePurchasing)
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	}
}

@end

