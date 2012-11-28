//
//  PostMessageViewController.m
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 8..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "PostMessageViewController.h"
#import "UIImage+Utilities.h"

#import "BaasClient.h"

#define IMAGE_WIDTH 612.0f
#define IMAGE_HEIGHT 612.0f

@interface PostMessageViewController ()

@end

@implementation PostMessageViewController

@synthesize messageTextField, profileImage, imageAddButton, postButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)flag {
    [super viewWillAppear:flag];
    [messageTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    step = 1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    step = 1;
    imageSelected = 0;
    dictionary = [[NSMutableDictionary alloc]init];
    _uploadFileList = [NSMutableArray array];
    NSString *picture = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"picture"];
    [profileImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:picture]]]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//이미지 추가 관련 소스
-(IBAction)imageAddTouched:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    //    inputProfileImage.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //    [picker dismissModalViewControllerAnimated:YES];
    //imagePostThread = [[NSThread alloc]initWithTarget:self selector:@selector(imagePostFunction) object:nil];
    
    imageSelected = 1;

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
        //resizedImage = [croppedImage resizedImage:CGSizeMake(croppedImage.size.width, croppedImage.size.height) imageOrientation:originalImage.imageOrientation];
        resizedImage = croppedImage;
    }
    
    [imageAddButton setBackgroundImage:resizedImage forState:UIControlStateNormal];
    
    NSURL *url = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:url
                  resultBlock:^(ALAsset *asset){
                      ALAssetRepresentation *rep = [asset defaultRepresentation];
                      dictionary = [NSMutableDictionary dictionaryWithDictionary:info];
                      [dictionary setObject:rep.filename forKey:@"filename"];
                  }
                 failureBlock:^(NSError *err) {
                     NSLog(@"Error: %@",[err localizedDescription]);
                 }];
    [picker dismissModalViewControllerAnimated:YES];
}

- (IBAction)postMessage:(id)sender {
    if (![messageTextField.text isEqualToString:@""]) {
        [postButton setEnabled:NO];
        NSString *uuid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"uuid"];
        NSString *username = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"username"];
        NSString *email = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"email"];
        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        NSString *picture = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"picture"];
        
        if(imageSelected == 1){
            //이미지를 선택했을 경우.
            int index = [_uploadFileList count];
            [_uploadFileList insertObject:dictionary atIndex:index];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            UIImage *contentImage = [imageAddButton backgroundImageForState:UIControlStateNormal];
            NSData *contentImageData = UIImageJPEGRepresentation(contentImage, 1.0);
            
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
                  [actorInfo setObject:picture forKey:@"picture"];
                  BaasClient *client = [BaasClient createInstance];
                  [client setLogging:NO];
                  [client setAuth:access_token];
                  
                  NSMutableDictionary *entity = [NSMutableDictionary dictionaryWithDictionary:actorInfo];
                  [entity setObject:[messageTextField text] forKey:@"content"];
                  [entity setObject:uuid forKey:@"user"];
                  [entity setObject:picture forKey:@"picture"];
                  [entity setObject:@"0" forKey:@"like"];
                  [entity setObject:@"0" forKey:@"bad"];
                  
                  //사진이 업로드 된 경로를 엔티티에 저장하기
                  NSMutableDictionary *contentImageEntity = [NSMutableDictionary dictionaryWithDictionary:response];
                  [entity setObject:[[[contentImageEntity objectForKey:@"entities"] objectAtIndex:0] objectForKey:@"path"] forKey:@"contentImagePath"];
                  
                  UGClientResponse *clientResponse = [client createEntity:@"feed" entity:entity];
                  NSLog(@"response.transactionID : %i", clientResponse.transactionID);
                  [self dismissModalViewControllerAnimated:YES];
                  imageSelected = 0;
              }
              failureBlock:^(NSError *error){
                  NSLog(@"error : %@, %@", error.description, error.domain);
              }
             progressBlock:^(float progress){
                 
             }];
        }else{
            //insert directories Collection
            NSMutableDictionary *actorInfo = [[NSMutableDictionary alloc] init];
            // User Params
            [actorInfo setObject:uuid forKey:@"uuid"];
            [actorInfo setObject:email forKey:@"email"];
            [actorInfo setObject:username forKey:@"username"];
            [actorInfo setObject:picture forKey:@"picture"];
            
            BaasClient *client = [BaasClient createInstance];
            [client setLogging:NO];
            [client setDelegate:self];
            [client setAuth:access_token];
            
            NSMutableDictionary *entity = [NSMutableDictionary dictionaryWithDictionary:actorInfo];
            [entity setObject:[messageTextField text] forKey:@"content"];
            [entity setObject:uuid forKey:@"user"];
            [entity setObject:picture forKey:@"picture"];
            [entity setObject:@"0" forKey:@"like"];
            [entity setObject:@"0" forKey:@"bad"];
            [entity setObject:@"-" forKey:@"contentImagePath"];
            
            UGClientResponse *clientResponse = [client createEntity:@"feed" entity:entity];
            //NSLog(@"response.transactionID : %i", clientResponse.transactionID);
        }
        [dictionary setValue:nil forKey:@"uploadedInfo"];

    } else {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:@"업로드 실패"
                              message:@"다시 시도하세요"
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)closeMessage:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UGClient delegate
- (void)ugClientResponse:(UGClientResponse *)response
{
    NSDictionary *resp = (NSDictionary *)response.rawResponse;
    if (response.transactionState == kUGClientResponseFailure) {
        NSLog(@"실패response : %@", resp);
    } else if (response.transactionState == kUGClientResponseSuccess) {
        [self dismissModalViewControllerAnimated:YES];
    }
}



@end
