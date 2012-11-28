//
//  PostMessageViewController.h
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 8..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PostMessageViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPageViewControllerDelegate>{
    int step;
    BOOL imageSelected;
    UIButton *postButton;
    
    //이미지 정보 저장을 위한
    NSMutableDictionary *dictionary;
    NSMutableArray *_uploadFileList;
}

@property (weak, nonatomic) IBOutlet UITextView *messageTextField;
@property (nonatomic, retain) IBOutlet UIImageView *profileImage;
@property (nonatomic, retain) IBOutlet UIButton *imageAddButton, *postButton;

-(IBAction)imageAddTouched:(id)sender;
@end
