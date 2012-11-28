//
// Created by cetauri on 12. 10. 25..
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BaasIOResponse.h"
#import "BaasQuery.h"

@interface BaasClient : NSObject

/********************* Default Setting *********************/
/**
 setApplicationInfo
 @param orgName orgName
 @param applicationName applicationName
 */
+ (void)setApplicationInfo:(NSString *)orgName applicationName:(NSString *)applicationName;
/**
 setApplicationInfo
 @param apiURL apiURL
 @param orgName orgName
 @param applicationName applicationName
 */
+ (void)setApplicationInfo:(NSString *)apiURL organizationName:(NSString *)orgName applicationName:(NSString *)applicationName;
/** createInstance */
+ (id) createInstance;
/** getAppInfo */
- (NSString *)getAppInfo;
/** getAPIURL */
- (NSString *)getAPIURL;
/** getAPIHost */
- (NSString *)getAPIHost;
/** 
 setDelegate
 @param delegate delegate
 */
- (BOOL)setDelegate:(id)delegate;
/**
 setAuth
 @param auth auth
 */
- (void)setAuth:(NSString *)auth;
/** getAccessToken */
- (NSString *)getAccessToken;

/********************* LOGIN / LOGOUT *********************/
/**
 log in with the given username and password
 @param username username
 @param password password
 */
-(BaasIOResponse *)logInUser: (NSString *)userName password:(NSString *)password;
/**
 log out the current user. The Client only supports one user logged in at a time.
 You can have multiple instances of UGClient if you want multiple
 users doing transactions simultaneously. This does not require network communication,
 so it has no return. It doesn't actually "log out" from the server. It simply clears
 the locally stored auth information
 */
-(void)logOut;

/********************* USER MANAGEMENT *********************/
/**
 adds a new user
 @param username username
 @param email email
 @param name name
 @param password password
 */
-(BaasIOResponse *)addUser:(NSString *)username email:(NSString *)email name:(NSString *)name password:(NSString *)password;

/**
 adds a new user via facebook
 @param accessToken accessToken
 */
-(BaasIOResponse *)addUserViaFacebook:(NSString *)accessToken;

/**
 updates a user's password
 @param usernameOrEmail usernameOrEmail
 @param oldPassword oldPassword
 @param newPassword newPassword
 */
-(BaasIOResponse *)updateUserPassword:(NSString *)usernameOrEmail oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;

/**
 get all the groups this user is in
 @param userID userID
 */
-(BaasIOResponse *)getGroupsForUser: (NSString *)userID;

/**
 get users in this app. Definitely want to consider sending a Query along
 with this call
 @param query query
 */
-(BaasIOResponse *)getUsers: (BaasQuery *)query;

/******************** ENTITY MANAGEMENT ********************/
//
/**
 adds an entity to the specified collection.
 @param entityName entityName
 @param newEntity newEntity
 */
-(BaasIOResponse *)createEntity: (NSString *)entityName entity:(NSDictionary *)newEntity;

/**
 get a list of entities that meet the specified query.
 @param entityName entityName
 @param query query
 */

-(BaasIOResponse *)getEntities: (NSString *)entityName query:(BaasQuery *)query;

/**
 updates an entity (it knows the type from the entity data)
 @param entityName entityName
 @param entityID entityID
 @param updatedEntity updatedEntity
 */

-(BaasIOResponse *)updateEntity: (NSString *)entityName entityID:(NSString *)entityID entity:(NSDictionary *)updatedEntity;

/**
 removes an entity of the specified entityName
 @param entityName entityName
 @param entityID entityID
 */
-(BaasIOResponse *)removeEntity: (NSString *)entityName entityID:(NSString *)entityID;

/**
 read an entity of the specified entityName
 @param entityName entityName
 @param entityID entityID
 */
-(BaasIOResponse *)readEntity: (NSString *)entityName entityID:(NSString *)entityID;

/********************* PUSH NOTIFICATION MANAGEMENT *********************/
/**
 device register for PUSH
 @param token token
 @param tagst ags
 */
- (BaasIOResponse *)registerDevice:(NSString *)token tags:(NSArray *)tags;
/**
 device unregister for PUSH
 @param uuid uuid
 */
- (BaasIOResponse *)unregisterDevice:(NSString *)uuid;

/************* File MANAGEMENT *************/
/**
 file download 
 @param remotePath remotePath
 @param localPath localPath 
 @param successBlock successBlock
 @param failureBlock failureBlock
 @param progressBlock progressBlock
 */
-(void)download:(NSString *)remotePath
           path:(NSString*)localPath
   successBlock:(void (^)(NSDictionary *response))successBlock
   failureBlock:(void (^)(NSError *error))failureBlock
  progressBlock:(void (^)(float progress))progressBlock;

/**
 file upload : filepath 자동 생성
 @param data data
 @param header header
 @param successBlock successBlock
 @param failureBlock failureBlock
 @param progressBlock progressBlock
 */
-(void)upload:(NSData *)data
       header:(NSDictionary*)header
 successBlock:(void (^)(NSDictionary *response))successBlock
 failureBlock:(void (^)(NSError *error))failureBlock
progressBlock:(void (^)(float progress))progressBlock;

/**
 file upload
 @param path path
 @param data data
 @param header header
 @param successBlock successBlock
 @param failureBlock failureBlock
 @param progressBlock progressBlock
 */

-(void)upload:(NSString *)path
         data:(NSData *)data
       header:(NSDictionary*)header
 successBlock:(void (^)(NSDictionary *response))successBlock
 failureBlock:(void (^)(NSError *error))failureBlock
progressBlock:(void (^)(float progress))progressBlock;

/** 
 file re-upload (modify) 
 @param uuid uuid
 @param data data
 @param header header
 @param successBlock successBlock
 @param failureBlock failureBlock
 @param progressBlock progressBlock
 */
-(void)reUpload:(NSString *)uuid
           data:(NSData*)data
         header:(NSDictionary*)header
   successBlock:(void (^)(NSDictionary *response))successBlock
   failureBlock:(void (^)(NSError *error))failureBlock
  progressBlock:(void (^)(float progress))progressBlock;

/** 
 file delete 
 @param uuid uuid
 @param successBlock successBlock
 @param failureBlock failureBlock
 */
-(void)delete:(NSString *)uuid
successBlock:(void (^)(NSDictionary *response))successBlock
failureBlock:(void (^)(NSError *error))failureBlock;

-(void)fileInformation:(void (^)(NSDictionary *response))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock;

-(void)fileInformation:(NSString *)uuid
          successBlock:(void (^)(NSDictionary *response))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock;

-(void)fileList:(NSString *)dir
   successBlock:(void (^)(NSDictionary *response))successBlock
   failureBlock:(void (^)(NSError *error))failureBlock;

/*********************** DEBUGGING ASSISTANCE ************************/
/** 
 Logging
 @param loggingState loggingState
 */
-(void)setLogging: (BOOL)loggingState;

@end