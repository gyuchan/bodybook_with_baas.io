//
//  ProfileInfoCell.h
//  bodybook
//
//  Created by Jeon Gyuchan on 12. 11. 23..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileInfoCell : UITableViewCell <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIPageViewControllerDelegate>{
    NSDictionary *userInfo;
    UIViewController *viewController;
        
    UIButton *profileImageChangeButton;
    UIView *profileImageBackground;
    UIImageView *profileImage;
    UIImageView *profileBigImage;
    UIImageView *photoButtonImage;
    UIImage *uploadImage;
    UILabel *userNameLabel;
}

@property (nonatomic, retain)IBOutlet UIButton *profileImageChangeButton;
@property (nonatomic, retain)IBOutlet UIView *profileImageBackground;
@property (nonatomic, retain)IBOutlet UIImageView *profileImage, *profileBigImage, *photoButtonImage;
@property (nonatomic, retain)IBOutlet UILabel *userNameLabel;
@property (nonatomic, assign)UIViewController *viewController;

- (void)initCustomCell:(NSDictionary*)contentDic;
- (IBAction)profileImageChange:(id)sender;


@end
