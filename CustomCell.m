//
//  CustomCell.m
//  customTableview
//
//  Created by gyuchan jeon on 12. 10. 9..
//  Copyright (c) 2012년 gyuchan jeon. All rights reserved.
//

#import "CustomCell.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaasClient.h"

@implementation CustomCell

@synthesize name, contentText, bottomView, background, likeLabel, imageView, profileImage, badLabel, dateLabel;

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

- (IBAction)likeTouched:(id)sender{
    if(!firstLike){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"좋아요!를 눌렀습니다."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        [alert show];
        likeNumber++;

        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        NSMutableDictionary *entity = [[NSMutableDictionary alloc]init];
        NSString * outputLikeNumber = [NSString stringWithFormat:@"%d", likeNumber];
        [entity setObject:outputLikeNumber forKey:@"like"];
        
        BaasClient *client = [BaasClient createInstance];
        [client setLogging:NO];
        [client setDelegate:self];
        [client setAuth:access_token];
        [client updateEntity:@"feed" entityID:contentUUID entity:entity];

        firstLike = TRUE;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"이미 했습니다."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        [alert show];
    }
}

- (IBAction)badTouched:(id)sender{
    if(!firstBad){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"싫어요!를 눌렀습니다."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        [alert show];
        
        badNumber++;
        
        NSMutableDictionary *entity = [[NSMutableDictionary alloc]init];
        NSString * outputLikeNumber = [NSString stringWithFormat:@"%d", badNumber];
        [entity setObject:outputLikeNumber forKey:@"bad"];
        
        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        BaasClient *client = [BaasClient createInstance];
        [client setLogging:NO];
        [client setDelegate:self];
        [client setAuth:access_token];
        [client updateEntity:@"feed" entityID:contentUUID entity:entity];
        
        firstBad = TRUE;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"이미 했습니다."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        [alert show];
    }
}



- (void)ugClientResponse:(UGClientResponse *)response
{
    NSDictionary *resp = (NSDictionary *)response.rawResponse;
    if (response.transactionState == kUGClientResponseFailure) {
        NSLog(@"실패\n response : %@", resp);
    } else if (response.transactionState == kUGClientResponseSuccess) {
        if(likeNumber>0){
            [likeLabel setText:[NSString stringWithFormat:@"%d",likeNumber]];
        }
        if(badNumber>0){
            [badLabel setText:[NSString stringWithFormat:@"%d",badNumber]];
        }
        NSLog(@"성공\n response : %@", resp);
    }
}

- (void)initCustomCell:(NSDictionary*)contentDic{
    firstLike = FALSE;
    firstBad = FALSE;
    
    userInfo = contentDic;
    contentUUID = [userInfo objectForKey:@"uuid"];

    [profileImage setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"picture"]] placeholderImage:nil];
    [contentText setText:[userInfo objectForKey:@"content"]];
    [name setText:[userInfo objectForKey:@"username"]];
    
    //시간 계산    
    long long timeStamp = [[userInfo objectForKey:@"created"] longLongValue];
    NSTimeInterval timeInterval = (double)(timeStamp/1000);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy년 MM월 dd일 HH시 mm분 ss초-에 작성됨"];
    [dateLabel setText:[[dateFormat stringFromDate:date]uppercaseString]];
    if([[userInfo objectForKey:@"like"] isEqualToString:@"0"]){
        likeNumber = 0;
        [likeLabel setText:@"-"];
    }else{
        likeNumber = [[userInfo objectForKey:@"like"] intValue];
        [likeLabel setText:[userInfo objectForKey:@"like"]];
    }
    
    if([[userInfo objectForKey:@"bad"] isEqualToString:@"0"]){
        badNumber = 0;
        [badLabel setText:@"-"];
    }else{
        badNumber = [[userInfo objectForKey:@"bad"] intValue];
        [badLabel setText:[userInfo objectForKey:@"bad"]];
    }
    CGSize size = [[userInfo objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(285, 9000)];
    CGFloat labelHeight = MAX(size.height, 10.0);
    [self.contentText setFont:[UIFont systemFontOfSize:13.0]];
    [self.contentText setLineBreakMode:UILineBreakModeCharacterWrap];
    [self.contentText setNumberOfLines:0];
    [self.contentText setFrame:CGRectMake(self.contentText.frame.origin.x, self.contentText.frame.origin.y, self.contentText.frame.size.width, labelHeight+5.0)];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.4];
    
    if([[userInfo objectForKey:@"contentImagePath"] isEqualToString:@"-"]){
        //사진이 없는경우
        self.imageView.hidden = YES;
        [self.bottomView setFrame:CGRectMake(self.bottomView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
        [self.background setFrame:CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.contentText.frame.origin.y + self.contentText.frame.size.height)];
    }else{
        //사진이 있는경우
        BaasClient *client = [BaasClient createInstance];
        
        /////////////////// 이미지파일이 있는 URL주소///////////////////////////
        NSString *contentImagePath = [NSString stringWithFormat:@"%@/files/%@",[client getAPIURL],[userInfo objectForKey:@"contentImagePath"]];
        //////////////////////////////////////////////////////////////////
        
        self.imageView.hidden = NO;
        [self.imageView setImageWithURL:[NSURL URLWithString:contentImagePath]];
        [self.imageView setClipsToBounds:YES];
        [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height, self.imageView.frame.size.width, 200)];
        [self.bottomView setFrame:CGRectMake(self.bottomView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height + self.imageView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
        
        [self.background setFrame:CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.contentText.frame.origin.y + self.contentText.frame.size.height + self.imageView.frame.size.height)];
    }
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.background.bounds];
    self.background.layer.masksToBounds = NO;
    self.background.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.background.layer.shadowOpacity = 1.0;
    self.background.layer.shadowRadius = 1.5;
    self.background.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.background.layer.shadowPath = shadowPath.CGPath;
    self.background.layer.shouldRasterize = YES;
}

@end
