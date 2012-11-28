//
//  baas_io_sdkTests.m
//  baas.io-sdkTests
//
//  Created by cetauri on 12. 10. 25..
//  Copyright (c) 2012년 kth. All rights reserved.
//

#import "baas_io_sdkTests.h"
#import "BaasClient.h"
#import "JSONKit.h"
@implementation baas_io_sdkTests{
    BOOL exitRunLoop;

}

static NSString *access_token;
- (void)setUp
{
    [BaasClient setApplicationInfo:@"test.file" applicationName:@"bropbox"];
    exitRunLoop = NO;
}

- (void)test1_Login
{
    BaasClient *client = [BaasClient createInstance];
//    [client setDelegate:self];
    [client setLogging:YES];
    BaasIOResponse *response = [client logInUser:@"test" password:@"test"];

    NSLog(@"response : %@", response.response);
    access_token = [response.response objectForKey:@"access_token"];
    NSLog(@"access_token = %@", access_token);
}
//
//
//- (void)test2_CreateEntity
//{
//    BaasClient *client = [BaasClient createInstance];
//    [client setAuth:access_token];
////    [client setDelegate:self];
//    [client setLogging:YES];
//
//    BaasIOResponse *response = [client createEntity:@"test" entity:@{@"key" : @"value2"}];
//    NSLog(@"response : %@", response.rawResponse);
//}


//- (void)test3_updateEntity
//{
//    BaasClient *client = [BaasClient createInstance];
//    [client setAuth:access_token];
//    //    [client setDelegate:self];
//    [client setLogging:YES];
//    
//    BaasIOResponse *response = [client updateEntity:@"test" entityID:@"d210eef6-1f17-11e2-a91a-02004d450054" entity:@{@"key" : @"value3"}];
//    NSLog(@"response : %@", response.rawResponse);
//}

//
//- (void)test5_readEntity
//{
//    BaasClient *client = [BaasClient createInstance];
//    
//    [client setAuth:access_token];
//    //    [client setDelegate:self];
//    [client setLogging:YES];
//    
//    BaasQuery *query = [[BaasQuery alloc] init];
//    [query addRequirement:@"key = 'value2'"];
//    
//    
//    BaasIOResponse *response = [client getEntities:@"test" query:query];
//    NSLog(@"response : %@", response.rawResponse);
//}

- (void)test5_readEntity
{
    BaasClient *client = [BaasClient createInstance];
    
    [client setAuth:access_token];
//    [client setDelegate:self];
    [client setLogging:YES];
    
    BaasIOResponse *response = [client readEntity:@"test" entityID:@"d210eef6-1f17-11e2-a91a-02004d450054"];
    NSLog(@"response : %@", response.rawResponse);
}

//
//- (void)test6_removeEntity
//{
//    BaasClient *client = [BaasClient createInstance];
//    [client setAuth:access_token];
////    [client setDelegate:self];
//    [client setLogging:YES];
//
//    BaasIOResponse *response = [client removeEntity:@"test" entityID:@"a624268c-1e9a-11e2-a91a-02004d450054"];
//    NSLog(@"response : %@", response.rawResponse);
//}
//- (void)test5_registerDevice
//{
//    BaasClient *client = [BaasClient createInstance];
//    
//    [client setAuth:access_token];
//    //    [client setDelegate:self];
//    [client setLogging:YES];
//    
//    BaasIOResponse *response = [client registerDevice:@"test" tags:@[@"a",@"b"]];
//    NSLog(@"response : %@", response.rawResponse);
//}
//
//- (void)test7_unregisterDevice
//{
//    BaasClient *client = [BaasClient createInstance];
//    
//    [client setAuth:access_token];
//    //    [client setDelegate:self];
//    [client setLogging:YES];
//    
//    BaasIOResponse *response = [client unregisterDevice:@"test"];
//    NSLog(@"response : %@", response.rawResponse);
//}

//- (void)test8_filesInformation
//{
//    BaasClient *client = [BaasClient createInstance];
//    
//    [client setAuth:access_token];
//    [client setLogging:YES];
//    
//    [client fileInformation:^(NSDictionary *response){
//                                NSLog(@"response : %@", response.description);
//                                exitRunLoop = YES;
//                            }
//                            failureBlock:^(NSError *error){
//                                NSLog(@"error : %@", error.localizedDescription);
//                                exitRunLoop = YES;
//                            }];
//    
//    [self runTestLoop];
//}

- (void)test9_fileInformation
{
    BaasClient *client = [BaasClient createInstance];
    
    [client setAuth:access_token];
    [client setLogging:YES];
    
    [client fileInformation:@"1df2de6a-1f40-11e2-83cf-020026de0053"
               successBlock:^(NSDictionary *response){
        NSLog(@"response : %@", response.description);
        exitRunLoop = YES;
    }
               failureBlock:^(NSError *error){
                   NSLog(@"error : %@", error.localizedDescription);
                   exitRunLoop = YES;
               }];
    
    [self runTestLoop];
}

- (void)test9_fileList
{
    BaasClient *client = [BaasClient createInstance];
    
    [client setAuth:access_token];
    [client setLogging:YES];
    
    [client fileList:@"public/20121026"
               successBlock:^(NSDictionary *response){
                   NSLog(@"response : %@", response.description);
                   exitRunLoop = YES;
               }
               failureBlock:^(NSError *error){
                   NSLog(@"error : %@", error.localizedDescription);
                   exitRunLoop = YES;
               }];
    
    [self runTestLoop];
}


- (void)runTestLoop{
    while (!exitRunLoop){
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}
@end
