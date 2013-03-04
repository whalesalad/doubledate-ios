//
//  DDStoreKitController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDStoreKitController.h"

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
    
}

@end

