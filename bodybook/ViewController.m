//
//  ViewController.m
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 2..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "ViewController.h"
#import "JoinController.h"
#import "SHSidebarController.h"
#import "UserViewController.h"
#import "NewsFeedController.h"
#import "AddFriendViewController.h"

#import "BaasClient.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize usernameTextField, passwordTextField, bodybook;

- (void)viewDidLoad
{
    [super viewDidLoad];
    passwordTextField.secureTextEntry = YES;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)loginTouched:(id)sender{
    BaasClient *client = [BaasClient createInstance];
    [client setDelegate:self];
    [client logInUser:usernameTextField.text password:passwordTextField.text];
}
-(IBAction)JoinTouched:(id)sender{
    JoinController *joinView = [[JoinController alloc] init];
    [self presentModalViewController:joinView animated:NO];
}

-(void)goToMainPage{
    NSMutableArray *vcs = [NSMutableArray array];
    
    //Creating view
    UserViewController *userView = [[UserViewController alloc] init];
    //Navigation Controller is required
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:userView];
    //Dictionary of the view and title
    NSDictionary *view1 = [NSDictionary dictionaryWithObjectsAndKeys:nav1, @"vc", [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"name"], @"title", nil];
    //And we finally add it to the array
    [vcs addObject:view1];
    
    //Creating view
    NewsFeedController *newsFeeds = [[NewsFeedController alloc] init];
    //Navigation Controller is required
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:newsFeeds];
    //Dictionary of the view and title
    NSDictionary *view2 = [NSDictionary dictionaryWithObjectsAndKeys:nav2, @"vc", @"뉴스피드", @"title", nil];
    //And we finally add it to the array
    [vcs addObject:view2];
    
    
    //Creating view
    AddFriendViewController *addFriends = [[AddFriendViewController alloc] init];
    //Navigation Controller is required
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:addFriends];
    //Dictionary of the view and title
    NSDictionary *view3 = [NSDictionary dictionaryWithObjectsAndKeys:nav3, @"vc", @"친구추가", @"title", nil];
    //And we finally add it to the array
    [vcs addObject:view3];
    
    SHSidebarController *sidebar = [[SHSidebarController alloc] initWithArrayOfVC:vcs];
    [self presentViewController:sidebar animated:NO completion:nil];
}

- (void)ugClientResponse:(UGClientResponse *)response
{
    NSDictionary *resp = (NSDictionary *)response.rawResponse;
    if (response.transactionState == kUGClientResponseFailure) {
        NSLog(@"실패\n response : %@", resp);
    } else if (response.transactionState == kUGClientResponseSuccess) {
        NSString *access_token = [resp objectForKey:@"access_token"];
        NSDictionary *user = [resp objectForKey:@"user"];
        NSLog(@"로그인 정보 response : %@", resp);
        [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self goToMainPage];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFieldView {
    [textFieldView resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textFieldView {
    currentTextField = nil;
    [textFieldView resignFirstResponder];
}

@end
