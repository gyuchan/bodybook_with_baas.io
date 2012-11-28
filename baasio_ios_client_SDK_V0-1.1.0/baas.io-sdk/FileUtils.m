//
//  FileUtils.m
//  baas.io-sdk-ios
//
//  Created by cetauri on 12. 10. 10..
//  Copyright (c) 2012년 kth. All rights reserved.
//

#import "FileUtils.h"
#import "AFNetworking.h"
#import "UGClient.h"

@implementation FileUtils{
    NSString *_access_token;
    NSString *_apiURL;
}

-(id)initWithClient:(BaasClient *)client
{
    if (self = [super init])
    {
        _access_token = client.getAccessToken;
        _apiURL = client.getAPIURL;
    }
    return self;
}

-(void)information:(void (^)(NSDictionary *response))successBlock
      failureBlock:(void (^)(NSError *error))failureBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/files/information", _apiURL];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [self addAuthorization:request];
    
    void (^success)(NSURLRequest *, NSHTTPURLResponse *, id) = [self success:successBlock];
    void (^failure)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id) = [self failure:failureBlock];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:success
                                                                                        failure:failure];
    [operation start];
}

-(void)fileInformation:(NSString *)uuid
          successBlock:(void (^)(NSDictionary *response))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/files/%@", _apiURL, uuid];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [self addAuthorization:request];
    
    void (^success)(NSURLRequest *, NSHTTPURLResponse *, id) = [self success:successBlock];
    void (^failure)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id) = [self failure:failureBlock];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:success
                                                                                        failure:failure];
    [operation start];
}


-(void)download:(NSString *)url
           path:(NSString*)path
   successBlock:(void (^)(NSDictionary *response))successBlock
        failureBlock:(void (^)(NSError *error))failureBlock
  progressBlock:(void (^)(float progress))progressBlock
{
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [self addAuthorization:request];

    void (^success)(NSURLRequest *, NSHTTPURLResponse *, id) = [self success:successBlock];
    void (^failure)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id) = [self failure:failureBlock];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:success
                                                                                        failure:failure];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
        float progress = (float)totalBytesRead / totalBytesExpectedToRead;
        progressBlock(progress);
//        NSLog(@"Sent %lld of %lld bytes : %lf", totalBytesRead, totalBytesExpectedToRead, progress);

    }];
    [operation start];
}

-(void)reUpload:(NSString *)uuid
           data:(NSData *)data
         header:(NSDictionary*)header
   successBlock:(void (^)(NSDictionary *response))successBlock
   failureBlock:(void (^)(NSError *error))failureBlock
  progressBlock:(void (^)(float progress))progressBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/files/%@", _apiURL, uuid];
    [self uploadWithData:url method:@"PUT" header:header data:data successBlock:successBlock failureBlock:failureBlock progressBlock:progressBlock];
}


-(void)upload:(NSString *)path
         data:(NSData *)data
       header:(NSDictionary*)header
 successBlock:(void (^)(NSDictionary *response))successBlock
 failureBlock:(void (^)(NSError *error))failureBlock
progressBlock:(void (^)(float progress))progressBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/files/%@", _apiURL, path];
    [self uploadWithData:url method:@"POST" header:header data:data successBlock:successBlock failureBlock:failureBlock progressBlock:progressBlock];
}


-(void)upload:(NSData *)data
       header:(NSDictionary*)header
 successBlock:(void (^)(NSDictionary *response))successBlock
 failureBlock:(void (^)(NSError *error))failureBlock
progressBlock:(void (^)(float progress))progressBlock
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *yyyymmdd = [formatter stringFromDate:[NSDate date]];
    
    [formatter setDateFormat:@"HHmmssSSS"];
    NSString *HHmmssSSS = [formatter stringFromDate:[NSDate date]];
    
    NSString *path = [NSString stringWithFormat:@"%@/files/public/%@/%@/%@", _apiURL, yyyymmdd, HHmmssSSS, [FileUtils uuid]];
    [self uploadWithData:path method:@"POST" header:header data:data successBlock:successBlock failureBlock:failureBlock progressBlock:progressBlock];
}


- (void)uploadWithData:(NSString *)path
                method:(NSString *)method
                header:(NSDictionary*)header
                    data:(NSData *)data successBlock:(void (^)(NSDictionary *))successBlock
            failureBlock:(void (^)(NSError *))failureBlock
           progressBlock:(void (^)(float))progressBlock
{
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [request setAllHTTPHeaderFields:header];
    [self addAuthorization:request];
    [request setHTTPMethod:method];
    [request setHTTPBody:data];
    
    void (^success)(NSURLRequest *, NSHTTPURLResponse *, id) = [self success:successBlock];
    void (^failure)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id) = [self failure:failureBlock];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:success
                                                                                        failure:failure];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        float progress = totalBytesWritten / totalBytesExpectedToWrite;
        progressBlock(progress);
    }];
    
    [operation start];
}

-(void)delete:(NSString *)uuid
   successBlock:(void (^)(NSDictionary *response))successBlock
   failureBlock:(void (^)(NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/files/%@", _apiURL, uuid];
    NSURL *nurl = [NSURL URLWithString:path];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:nurl];
    [request setHTTPMethod:@"DELETE"];
    [self addAuthorization:request];

    void (^success)(NSURLRequest *, NSHTTPURLResponse *, id) = [self success:successBlock];
    void (^failure)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id) = [self failure:failureBlock];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:success
                                                                                        failure:failure];
    [operation start];

}

#pragma mark - private method
- (void)addAuthorization:(NSMutableURLRequest *)request{
    if (_access_token != nil && ![_access_token isEqualToString:@""]){
        [request addValue:[NSString stringWithFormat:@"Bearer %@", _access_token] forHTTPHeaderField:@"Authorization"];
    }
}

+ (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge NSString *)(uuidStringRef);
}

#pragma mark - API response method
- (void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure:(void (^)(NSError *))failureBlock {
    void (^failure)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        if (JSON == nil){
            failureBlock(error);
            return;
        }
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:[JSON objectForKey:@"error_description"] forKey:NSLocalizedDescriptionKey];

        NSString *domain = [JSON objectForKey:@"error"];
        NSError *e = [NSError errorWithDomain:domain code:error.code userInfo:details];

        failureBlock(e);
    };
    return failure;
}

- (void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success:(void (^)(NSDictionary *))successBlock {
    void (^success)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        successBlock(JSON);
    };
    return success;
}
@end
