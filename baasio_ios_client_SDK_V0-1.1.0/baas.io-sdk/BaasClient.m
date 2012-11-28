//
// Created by cetauri on 12. 10. 25..
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BaasClient.h"
#import "UGClient.h"
#import "UGHTTPManager.h"
#import "JSONKit.h"
#import "FileUtils.h"
#import <objc/message.h>

@implementation BaasClient {
    UGClient *_client;

}
static NSString * _apiURL;
static NSString * _applicationName;
static NSString * _orgName;

+ (void)setApplicationInfo:(NSString *)orgName applicationName:(NSString *)applicationName{
    _apiURL = @"https://stgapi.baas.io";
    [BaasClient setApplicationInfo:_apiURL organizationName:orgName applicationName:applicationName];

}

+ (void)setApplicationInfo:(NSString *)apiURL organizationName:(NSString *)orgName applicationName:(NSString *)applicationName
{
    _apiURL = apiURL;
    _applicationName = applicationName;
    _orgName = orgName;
}

//static BaasClient *instance = nil;
+ (id) createInstance{
    BaasClient *baasIO = [[BaasClient alloc] init];
    return baasIO;
}

- (NSString *)getAppInfo{
    NSString *info = [NSString stringWithFormat:@"%@/%@", _orgName, _applicationName];
    return info;
}

- (NSString *)getAPIURL{
    return [NSString stringWithFormat:@"%@/%@", self.getAPIHost, self.getAppInfo];
}

- (NSString *)getAPIHost{
    return _apiURL;
}
-(id)init
{
    if (self = [super init])
    {
        NSString *applicationID = [self getAppInfo];
        NSString *baseURL = [self getAPIHost];
        _client = [[UGClient alloc] initWithApplicationID:applicationID baseURL:baseURL];
    }
    return self;
}

-(BOOL) setDelegate:(id)delegate{
    return [_client setDelegate:delegate];
}

-(void) setAuth:(NSString *)auth{
    return [_client setAuth:auth];
}

-(NSString *) getAccessToken{
    return [_client getAccessToken];
}
/*************************** LOGIN / LOGOUT ****************************/

-(BaasIOResponse *)logInUser: (NSString *)userName password:(NSString *)password
{
    return (BaasIOResponse*)[_client logInUser:userName password:password];
}

//-(BaasIOResponse *)logInUserWithPin: (NSString *)userName pin:(NSString *)pin
//{
//    return [_client logInUserWithPin:userName pin:pin];
//}

//-(BaasIOResponse *)logInAdmin: (NSString *)adminUserName secret:(NSString *)adminSecret
//{
//    return [_client logInAdmin:adminUserName secret:adminSecret];
//}

-(void)logOut
{
    // clear out auth
    [_client setAuth: nil];
}

/*************************** USER MANAGEMENT ***************************/
-(BaasIOResponse *)addUser:(NSString *)username email:(NSString *)email name:(NSString *)name password:(NSString *)password
{
    return (BaasIOResponse*)[_client addUser:username email:email name:name password:password];
}

-(BaasIOResponse *)addUserViaFacebook:(NSString *)accessToken
{
    NSString *url = [self createURL:@"auth" append2:@"facebook"];
    NSString *urlWithParameters = [url stringByAppendingFormat:@"?fb_access_token=%@", accessToken];

    return (BaasIOResponse*)[self httpTransaction:urlWithParameters op:kUGHTTPGet opData:nil];
}


// updates a user's password
-(BaasIOResponse *)updateUserPassword:(NSString *)usernameOrEmail oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword
{
    return (BaasIOResponse*)[_client updateUserPassword:usernameOrEmail oldPassword:oldPassword newPassword:newPassword];
}

-(BaasIOResponse *)getGroupsForUser: (NSString *)userID;
{
    return (BaasIOResponse*)[_client getGroupsForUser:userID];
}

-(BaasIOResponse *)getUsers: (BaasQuery *)query
{
    return (BaasIOResponse*)[_client getUsers:query];
}


/******************** ENTITY MANAGEMENT ********************/

-(BaasIOResponse *)createEntity: (NSString *)entityName entity:(NSDictionary *)newEntity
{
    NSMutableDictionary *entity = [NSMutableDictionary dictionaryWithDictionary:newEntity];
    [entity setObject:entityName forKey:@"type"];
    return (BaasIOResponse*)[_client createEntity:entity];
}

-(BaasIOResponse *)getEntities: (NSString *)entityName query:(BaasQuery *)query
{
    return (BaasIOResponse*) [_client getEntities:entityName query:query];
}

-(BaasIOResponse *)updateEntity: (NSString *)entityName entityID:(NSString *)entityID entity:(NSDictionary *)updatedEntity
{
    NSMutableDictionary *entity = [NSMutableDictionary dictionaryWithDictionary:updatedEntity];
    [entity setObject:entityName forKey:@"type"];
    return (BaasIOResponse*)[_client updateEntity:entityID entity:entity];
}

-(BaasIOResponse *)removeEntity: (NSString *)entityName entityID:(NSString *)entityID
{
    return (BaasIOResponse*) [_client removeEntity:entityName entityID:entityID];
}


/************* PUSH NOTIFICATION MANAGEMENT *************/
- (BaasIOResponse *)registerDevice:(NSString *)token tags:(NSArray *)tags
{
    if (!token) {

        NSError *tokenError = [NSError errorWithDomain:@"UGClientErrorDomain"
                                                  code:kUGHTTPErrorDomainFailedSelector
                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"There is no device token.", NSLocalizedDescriptionKey, nil]];

        BaasIOResponse *response = [BaasIOResponse new];
        [response setTransactionID:-1];
        [response setTransactionState:kUGClientResponseFailure];
        [response setResponse:tokenError];
        [response setRawResponse:nil];

        return response;
    }


    NSString *url = [self createURL:@"pushes" append2:@"devices"];

    NSMutableDictionary *opInfo = [NSMutableDictionary new];

    [opInfo setValue:@"I" forKey:@"platform"];

    if (tags) {
        [opInfo setValue:[tags JSONString] forKey:@"tags"];
    }

    [opInfo setValue:token forKey:@"token"];

    NSLog(@"opinfo : %@", opInfo);


    return [self httpTransaction:url op:kUGHTTPPost opData:[opInfo JSONString]];
}


-(BaasIOResponse *)readEntity: (NSString *)entityName entityID:(NSString *)entityID
{
    return [self getEntities:[NSString stringWithFormat:@"%@/%@", entityName, entityID] query:nil];
}

- (BaasIOResponse *)unregisterDevice:(NSString *)uuid
{

    NSString *url = [self createURL:@"pushes" append2:@"devices" append3:uuid];

    return [self httpTransaction:url op:kUGHTTPDelete opData:nil];
}

/************* File MANAGEMENT *************/
-(void)download:(NSString *)remotePath
           path:(NSString*)localPath
   successBlock:(void (^)(NSDictionary *response))successBlock
   failureBlock:(void (^)(NSError *error))failureBlock
  progressBlock:(void (^)(float progress))progressBlock{

    FileUtils *file = [[FileUtils alloc]initWithClient:self];
    [file download:remotePath
              path:localPath
      successBlock:successBlock
      failureBlock:failureBlock
     progressBlock:progressBlock];
}

-(void)upload:(NSData *)data
       header:(NSDictionary*)header
 successBlock:(void (^)(NSDictionary *response))successBlock
 failureBlock:(void (^)(NSError *error))failureBlock
progressBlock:(void (^)(float progress))progressBlock
{
    FileUtils *file = [[FileUtils alloc]initWithClient:self];
    [file upload:data
          header:header
    successBlock:successBlock
    failureBlock:failureBlock
   progressBlock:progressBlock];
    
}

-(void)upload:(NSString *)path
         data:(NSData *)data
       header:(NSDictionary*)header
 successBlock:(void (^)(NSDictionary *response))successBlock
 failureBlock:(void (^)(NSError *error))failureBlock
progressBlock:(void (^)(float progress))progressBlock
{
    FileUtils *file = [[FileUtils alloc]initWithClient:self];
    [file upload:path
            data:data
          header:header
    successBlock:successBlock
    failureBlock:failureBlock
   progressBlock:progressBlock];
}


-(void)reUpload:(NSString *)uuid
           data:(NSData*)data
         header:(NSDictionary*)header
   successBlock:(void (^)(NSDictionary *response))successBlock
   failureBlock:(void (^)(NSError *error))failureBlock
  progressBlock:(void (^)(float progress))progressBlock{
    FileUtils *file = [[FileUtils alloc]initWithClient:self];
    [file reUpload:uuid
              data:data
            header:header
      successBlock:successBlock
      failureBlock:failureBlock
     progressBlock:progressBlock];
}

-(void)delete:(NSString *)uuid
 successBlock:(void (^)(NSDictionary *response))successBlock
 failureBlock:(void (^)(NSError *error))failureBlock{
    FileUtils *file = [[FileUtils alloc]initWithClient:self];
    [file delete:uuid
    successBlock:successBlock
    failureBlock:failureBlock];
}

-(void)fileInformation:(void (^)(NSDictionary *response))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock
{
    FileUtils *file = [[FileUtils alloc]initWithClient:self];
    [file information:successBlock
         failureBlock:failureBlock];
}

-(void)fileInformation:(NSString *)uuid
          successBlock:(void (^)(NSDictionary *response))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock{
    
    FileUtils *file = [[FileUtils alloc]initWithClient:self];
    [file fileInformation:uuid
             successBlock:successBlock
         failureBlock:failureBlock];
}

-(void)fileList:(NSString *)dir
          successBlock:(void (^)(NSDictionary *response))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock{
    
    if (![dir hasSuffix:@"/"])
        dir = [NSString stringWithFormat:@"%@/", dir];
    
    FileUtils *file = [[FileUtils alloc]initWithClient:self];
    [file fileInformation:dir
             successBlock:successBlock
             failureBlock:failureBlock];
}
-(void)setLogging: (BOOL)loggingState{
    [_client setLogging:loggingState];
}

#pragma mark - Gateway method

-(BaasIOResponse *)httpTransaction:(NSString *)url op:(NSInteger)op opData:(NSString *)opData{
    return objc_msgSend(_client, @selector(httpTransaction:op:opData:), url, op, opData);
}

- (NSString *)createURL:(NSString *)append append2:(NSString *)append2 {
    return [_client performSelector:@selector(createURL:append2:) withObject:append withObject:append2];
}

- (NSString *)createURL:(NSString *)append append2:(NSString *)append2 append3:(NSString *)append3 {
    return objc_msgSend(_client, @selector(createURL:append2:append3:), append, append2, append3);
}

@end