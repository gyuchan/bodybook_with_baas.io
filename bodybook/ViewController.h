//
//  ViewController.h
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 2..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    UITextField *currentTextField;
    UIButton *loginButton;
    
    UIImageView *bodybook;
}


@property (nonatomic, retain) IBOutlet UIImageView *bodybook;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

-(IBAction)loginTouched:(id)sender;
-(IBAction)JoinTouched:(id)sender;
@end
