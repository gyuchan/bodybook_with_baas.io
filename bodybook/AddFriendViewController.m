//
//  AddFriendViewController.m
//  bodybook
//
//  Created by Jeon Gyuchan on 12. 11. 18..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "AddFriendViewController.h"
#import "BaasClient.h"

@interface AddFriendViewController ()

@end


@implementation AddFriendViewController

@synthesize friendTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    friendTextField.text = @"";
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"친구";
    
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 29)];
    [bt setBackgroundImage:[UIImage imageNamed:@"rightButton@2x.png"] forState:UIControlStateNormal];
    [bt setTitle:@"+" forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(addPeople) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *src = [[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.rightBarButtonItem = src;

    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)addPeople{
    // Parsing rpcData to JSON!
    if(![friendTextField.text isEqualToString:@""]) {
        NSString *username = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"username"];
        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];

        BaasClient *client = [BaasClient createInstance];
        [client setLogging:NO];
        [client setDelegate:self];
        [client setAuth:access_token];
        
        UGClientResponse *clientResponse = [client createEntity:[NSString stringWithFormat:@"users/%@/following/user/%@",
                                                                 username, [friendTextField text]] entity:nil];
        NSLog(@"response.transactionID : %i", clientResponse.transactionID);
    } else {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:[NSString stringWithFormat:@"Username을 입력하세요"]
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)ugClientResponse:(UGClientResponse *)response
{
    NSDictionary *resp = (NSDictionary *)response.rawResponse;
    if (response.transactionState == kUGClientResponseFailure) {
        NSLog(@"실패response : %@", resp);
    } else if (response.transactionState == kUGClientResponseSuccess) {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"성공"]
                              message:[NSString stringWithFormat:@"친구추가가 성공적으로 이루어졌습니다"]
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        friendTextField.text = @"";
        [friendTextField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
