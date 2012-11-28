//
// Created by cetauri on 12. 10. 25..
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "UGClientResponse.h"
/**
 BaasIOResponse
 */
@interface BaasIOResponse : UGClientResponse

/**
 this will be a unique ID for this transaction. If you have
 multiple transactions in progress, you can keep track of them
 with this value. Note: The transaction ID of a synchronous
 call response is always -1.
 */
@property (nonatomic, assign) NSInteger transactionID;

/** 
 this will be one of three possible valuse:
 kUGClientResponseSuccess: The operation is complete and was successful. response will
 be valid, as will rawResponse
 
 kUGClientResponseFailure: There was an error with the operation. No further
 processing will be done. response will be an NSString with
 a plain-text description of what went wrong. rawResponse
 will be valid if the error occurred after receiving data from
 the service. If it occurred before, rawResponse will be nil.
 
 kUGClientResponsePending: The call is being handled asynchronously and not yet complete.
 response will be nil. rawResponse will also be nil
 
 */
@property (nonatomic, assign) NSInteger transactionState;

/**
 This is the response. The type of this variable is dependant on the call that caused
 this response.
 */
@property (nonatomic, assign) id response;

/**
 This is the raw text that was returned by the server.
 */
@property (nonatomic, retain) id rawResponse;
@end