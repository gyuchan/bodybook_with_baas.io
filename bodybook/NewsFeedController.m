//
//  NewsFeedController.m
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 8..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "NewsFeedController.h"
#import "CustomCell.h"
#import "PostMessageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "BaasClient.h"

@interface NewsFeedController ()

@end

@implementation NewsFeedController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0.0, 0.0)];
    _reloading = YES;
    
    NSString *username = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"username"];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    
    //step1. 유저의 친구들 목록 가져오기.
    step = 1;
    BaasClient *client = [BaasClient createInstance];
    [client setDelegate:self];
    [client setAuth:access_token];
    [client getEntities:[NSString stringWithFormat:@"users/%@/following/user/",username] query:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"뉴스피드";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
    
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 29)];
    [bt setImage:[UIImage imageNamed:@"newMessage@2x.png"] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(postingPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *src = [[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.rightBarButtonItem = src;
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
}

-(void)postingPage{
    PostMessageViewController *postMessageView = [[PostMessageViewController alloc] initWithNibName:@"PostMessageViewController" bundle:nil];
    [self presentModalViewController:postMessageView animated:YES];
}

- (void)ugClientResponse:(UGClientResponse *)response
{
    NSDictionary *resp = (NSDictionary *)response.rawResponse;
    if (response.transactionState == kUGClientResponseFailure) {
        NSLog(@"실패response : %@", resp);
    } else if (response.transactionState == kUGClientResponseSuccess) {
        if(step==1){
            userFriendArray = [[NSMutableArray alloc]initWithArray:[response.rawResponse objectForKey:@"entities"]];
//            NSLog(@"친구의 숫자 :\n %d",userFriendArray.count);
//            NSLog(@"userFriends :\n %@",userFriendArray);
            
            //NSMutableArray를 NSDictionary로 변환
            NSDictionary *object = [[NSDictionary alloc]init];
            
            //Baas.io에서 친구를 포함한 피드 불러오기
            NSString *uuid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"uuid"];
            NSString *username = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"username"];
            NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
            
            BaasQuery *query = [[BaasQuery alloc] init];
            NSString *require = [[NSString alloc]initWithString:[NSString stringWithFormat:@"username = '%@' ",username]];
            
            for(int i=0;i<userFriendArray.count;i++){
                object = [userFriendArray objectAtIndex:i];
                require = [require stringByAppendingString:[NSString stringWithFormat:@"or username = '%@' ",[object objectForKey:@"username"]]];
                //NSLog(@"친구UUID추가 : %@",[object objectForKey:@"username"]);
            }
            require = [require stringByAppendingString:@"order by created desc "];
            require = [require stringByAppendingString:@"limit = 30 "];
            NSLog(@"쿼리 : %@",require);
            [query addRequirement:require];
            
            BaasClient *client = [BaasClient createInstance];
            [client setDelegate:self];
            [client setAuth:access_token];
            [client getEntities:@"feed" query:query];
            step=2;
        }else if(step==2){
            contentArray = [[NSMutableArray alloc]initWithArray:[response.rawResponse objectForKey:@"entities"]];
            //NSLog(@"contentArray : %@",contentArray);
            NSLog(@"content갯수 : %d",contentArray.count);
            step=1;
            if(_reloading){
                [self performSelector:@selector(doneLoadingTableViewData) withObject:nil];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [[NSDictionary alloc]init];
    if(contentArray.count>=1) {
        object = [contentArray objectAtIndex:indexPath.row];
    }
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:nil options:nil];
        cell = [nibs objectAtIndex:0];
    }
    [cell initCustomCell:object];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [contentArray objectAtIndex:indexPath.row];
    NSString *contentText = [object objectForKey:@"content"];
    if([[object objectForKey:@"contentImagePath"] isEqualToString:@"-"]){
        //사진이 없는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13]
                              constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 85;
    }else{
        //사진이 있는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13]
                              constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 285;
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    NSString *username = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"username"];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    
    //step1. 유저의 친구들 목록 가져오기.
    step = 1;
    BaasClient *client = [BaasClient createInstance];
    [client setDelegate:self];
    [client setAuth:access_token];
    [client getEntities:[NSString stringWithFormat:@"users/%@/following/user/",username] query:nil];
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	_reloading = NO;
    [self.tableView reloadData];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
	return [NSDate date]; // should return date data source was last changed
    
}

@end
