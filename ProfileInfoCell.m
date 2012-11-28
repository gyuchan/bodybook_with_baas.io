//
//  ProfileInfoCell.m
//  bodybook
//
//  Created by Jeon Gyuchan on 12. 11. 23..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "ProfileInfoCell.h"
#import "UIImage+Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaasClient.h"

#define PROFILEBIGIMAGE_HEIGHT 175.0f
#define IMAGE_WIDTH 612.0f
#define IMAGE_HEIGHT 612.0f

@implementation ProfileInfoCell

@synthesize profileImage, profileBigImage, userNameLabel, profileImageBackground, profileImageChangeButton, photoButtonImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initCustomCell:(NSDictionary*)contentDic{
    userInfo = contentDic;
    
    [profileBigImage setImageWithURL:[NSURL URLWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"picture"]] placeholderImage:nil];
    [profileImage setImageWithURL:[NSURL URLWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"picture"]] placeholderImage:nil];
    [userNameLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"username"]];
    
    [self.profileBigImage setClipsToBounds:YES];
    [self.profileBigImage setFrame:CGRectMake(self.profileBigImage.frame.origin.x, self.profileBigImage.frame.origin.y, self.profileBigImage.frame.size.width, PROFILEBIGIMAGE_HEIGHT)];
    
    [self.photoButtonImage setFrame:CGRectMake(self.profileImage.frame.origin.x, self.profileImage.frame.origin.y, 30, 30)];
    
    [self.profileImage setClipsToBounds:YES];
    [self.profileImage setFrame:CGRectMake(self.profileImage.frame.origin.x, self.profileImage.frame.origin.y, 90, 90)];
    
    [self.profileImageChangeButton setFrame:CGRectMake(self.profileImageChangeButton.frame.origin.x,  PROFILEBIGIMAGE_HEIGHT-50, 90, 90)];
    
    [self.profileImageBackground setFrame:CGRectMake(self.profileImageBackground.frame.origin.x, PROFILEBIGIMAGE_HEIGHT-50, 100, 100)];
    
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.profileImageBackground.bounds];
    self.profileImageBackground.layer.masksToBounds = NO;
    self.profileImageBackground.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.profileImageBackground.layer.shadowOpacity = 1.0;
    self.profileImageBackground.layer.shadowRadius = 1.5;
    self.profileImageBackground.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.profileImageBackground.layer.shadowPath = shadowPath.CGPath;
    self.profileImageBackground.layer.shouldRasterize = YES;
    
    [self.userNameLabel setFrame:CGRectMake(self.userNameLabel.frame.origin.x, PROFILEBIGIMAGE_HEIGHT+10, self.userNameLabel.frame.size.width, self.userNameLabel.frame.size.height)];
}

- (IBAction)profileImageChange:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self.viewController presentModalViewController:picker animated:YES];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    NSLog(@"이미지가 선택되었음");
    NSString *uuid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"uuid"];
    NSString *username = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"username"];
    NSString *email = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"email"];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    NSString *picture = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"picture"];
    
    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    cropRect = [originalImage convertCropRect:cropRect];
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [[UIImage alloc]init];

    if(croppedImage.size.width > 612){
        if(croppedImage.size.height > 612){
            resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT) imageOrientation:originalImage.imageOrientation];
        }else{
            resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, croppedImage.size.height) imageOrientation:originalImage.imageOrientation];
        }
    }else{
        resizedImage = croppedImage;
    }

    NSData *contentImageData = UIImageJPEGRepresentation(resizedImage, 1.0);
    NSDictionary *header = [NSDictionary dictionary];
    BaasClient *client = [BaasClient createInstance];
    [client setAuth:access_token];
    [client upload:contentImageData
            header:header
      successBlock:^(NSDictionary *response){
          NSLog(@"response : %@", response.description);
          //insert directories Collection
          NSMutableDictionary *actorInfo = [[NSMutableDictionary alloc] init];
          // User Params
          [actorInfo setObject:uuid forKey:@"uuid"];
          [actorInfo setObject:email forKey:@"email"];
          [actorInfo setObject:username forKey:@"username"];
          BaasClient *client = [BaasClient createInstance];
          [client setLogging:NO];
          [client setDelegate:self];
          [client setAuth:access_token];
          
          NSMutableDictionary *entity = [NSMutableDictionary dictionaryWithDictionary:actorInfo];

          //프로필 사진이 업로드 된 경로를 엔티티에 저장하기
          NSMutableDictionary *profileImageEntity = [NSMutableDictionary dictionaryWithDictionary:response];
          NSString *profileImagePath = [NSString stringWithFormat:@"%@/files/%@",[client getAPIURL],[[[profileImageEntity objectForKey:@"entities"] objectAtIndex:0] objectForKey:@"path"]];
          [entity setObject:profileImagePath forKey:@"picture"];
          
          
          UGClientResponse *clientResponse = [client updateEntity:@"users" entityID:uuid entity:entity];
          NSLog(@"response.transactionID : %i", clientResponse.transactionID);
          
          [actorInfo setObject:profileImagePath forKey:@"picture"];
          [[NSUserDefaults standardUserDefaults] setObject:actorInfo forKey:@"user"];
          [[NSUserDefaults standardUserDefaults] synchronize];
          
          [picker dismissModalViewControllerAnimated:YES];
      }
      failureBlock:^(NSError *error){
          NSLog(@"error : %@, %@", error.description, error.domain);
      }
     progressBlock:^(float progress){
         
     }];
}


- (void)ugClientResponse:(UGClientResponse *)response
{
    NSDictionary *resp = (NSDictionary *)response.rawResponse;
    if (response.transactionState == kUGClientResponseFailure) {
        NSLog(@"프로필 이미지 바꾸기 실패response : %@", resp);
    } else if (response.transactionState == kUGClientResponseSuccess) {
        NSDictionary *resp = (NSDictionary *)response.rawResponse;
        NSMutableArray *response = [[NSMutableArray alloc]initWithArray:[resp objectForKey:@"entities"]];
        NSLog(@"프로필 이미지 바꾸기 성공response : \n %@", response);
    }
}

@end
