//
//  UGAppAppDelegate.m
//  UGAPIApp
//
//  Created by Ed Anuff on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UGAppAppDelegate.h"
#import "UGHTTPManager.h"
//#import "SBJson.h"
#import "UGClient.h"
#import "UGClientResponse.h"

UGClient *g_client = nil;
int g_taps = 0;

@implementation UGAppAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // called when there's a touch.
    [self testUGClient];
}

-(void)testUGClient
{
    // creation and init
    if ( !g_client )
    {
        g_client =[[UGClient alloc] initWithApplicationID:@"iOSSample"];
    }
    
    UGClientResponse *response = nil;
    response = [g_client logInUser:@"Alice" password:@"cheshire"];
    if ( [response transactionState] == kUGClientResponseFailure )
    {
        [self outputResponse:response title:@"LOG IN ERROR"];
        return;
    }
    
    CLLocation *fakeLocation = [[CLLocation alloc] initWithLatitude:37.776753 longitude:-122.407846];
    
    UGQuery *query = [UGQuery new];
    [query addRequiredWithinLocation:@"location" location:fakeLocation distance:2000];
    
    response = [g_client getUsers:query];
    [self outputResponse:response title:@"getUsers Response"];
}

-(void)ugClientResponse:(UGClientResponse *)response
{
    // note the results
    [self outputResponse:response title:@"Asynch Response"];
}

-(void)outputResponse:(UGClientResponse *)response title:(NSString *)title
{
    NSLog(@"-----%@-----", title);
    if ( !response )
    {
        NSLog(@"Response is nil");
        NSLog(@"------------------");
        return;
    }
    
    
    if ( [response transactionState] == kUGClientResponseSuccess )
    {
        NSLog(@"state: SUCCESS");
        NSLog(@"id: %d", [response transactionID]);
        NSLog(@"raw:\n%@", [response rawResponse]);
    }
    else if ( [response transactionState] == kUGClientResponsePending )
    {
        NSLog(@"state: PENDING");
        NSLog(@"id: %d", [response transactionID]);
    }
    else if ( [response transactionState] == kUGClientResponseFailure )
    {
        NSLog(@"state: FAILURE");
        NSLog(@"id: %d", [response transactionID]);
        NSLog(@"reason: '%@'", [response response]);
        NSLog(@"raw:\n%@", [response rawResponse]);
    }
    else 
    {
        NSLog(@"Object is mangled or invalid.");
    }
    NSLog(@"------------------");
}



@end
