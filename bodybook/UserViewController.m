//
//  UserViewController.m
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 8..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "UserViewController.h"
#import "CustomCell.h"
#import "ProfileInfoCell.h"
#import "PostMessageViewController.h"

#import "BaasClient.h"

@interface UserViewController ()

@end

@implementation UserViewController

@synthesize contentArray;

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
    NSString *uuid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"uuid"];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];    
    //Baas.io에서 개인 피드 불러오기
    BaasQuery *query = [[BaasQuery alloc] init];
    NSString *require = [NSString stringWithFormat:@"user = %@ order by created desc",uuid];
    NSLog(@"쿼리 : %@",require);
    [query addRequirement:require];
    
    BaasClient *client = [BaasClient createInstance];
    [client setDelegate:self];
    [client setAuth:access_token];
    [client getEntities:@"feed" query:query];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    contentArray = [[NSMutableArray alloc]init];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
    
    NSString *username = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"username"];
    
    self.navigationItem.title = username;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
    
    //오른쪽 버튼추가
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 29)];
    [bt setImage:[UIImage imageNamed:@"newMessage@2x.png"] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(postingPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *src = [[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.rightBarButtonItem = src;
    
}

-(void)postingPage{
    PostMessageViewController *postMessageView = [[PostMessageViewController alloc] initWithNibName:@"PostMessageViewController" bundle:nil];
    [self presentModalViewController:postMessageView animated:YES];
}

- (void)ugClientResponse:(UGClientResponse *)response
{
    NSDictionary *resp = (NSDictionary *)response.rawResponse;
    //NSLog(@"%@",resp);
    if (response.transactionState == kUGClientResponseFailure) {
        NSLog(@"실패response : %@", resp);
    } else if (response.transactionState == kUGClientResponseSuccess) {
        contentArray = [[NSMutableArray alloc]initWithArray:[response.rawResponse objectForKey:@"entities"]];
//        NSLog(@"%@",contentArray);
        NSLog(@"content갯수 : %d",contentArray.count);
        if(_reloading){
            [self performSelector:@selector(doneLoadingTableViewData) withObject:nil];
        }
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contentArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [[NSDictionary alloc]init];
    static NSString *userInfoCellIdentifier = @"ProfileInfoCell";
    ProfileInfoCell *userInfoCell = (ProfileInfoCell *)[tableView dequeueReusableCellWithIdentifier:userInfoCellIdentifier];
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    switch (indexPath.row) {
        case 0:
            if(contentArray.count>=1) {
                object = [contentArray objectAtIndex:indexPath.row];
            }
            if (userInfoCell == nil){
                NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ProfileInfoCell" owner:nil options:nil];
                userInfoCell = [nibs objectAtIndex:0];
                userInfoCell.viewController = self;
                [userInfoCell initCustomCell:object];
            }else{
                userInfoCell.viewController = self;
                [userInfoCell initCustomCell:object];
            }
            return userInfoCell;
            break;
        default:
            if(contentArray.count>=1) {
                object = [contentArray objectAtIndex:indexPath.row-1];
            }
            if (cell == nil){
                NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:nil options:nil];
                cell = [nibs objectAtIndex:0];
                if(contentArray){
                    [cell initCustomCell:object];
                }
            }else{
                if(contentArray.count>=1){
                    [cell initCustomCell:object];
                }
            }
            return cell;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)return 245;
    NSDictionary *object = [contentArray objectAtIndex:indexPath.row-1];
    NSString *contentText = [object objectForKey:@"content"];
    if([[object objectForKey:@"contentImagePath"] isEqualToString:@"-"]){
        //사진이 없는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 85;
    }else{
        //사진이 있는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 285;
    }
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    
    NSString *uuid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"uuid"];
    //    NSLog(@"uuid = %@",uuid);
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"] ;
    
    BaasQuery *query = [[BaasQuery alloc] init];
    NSString *require = [NSString stringWithFormat:@"user = %@ order by created desc",uuid];
    [query addRequirement:require];
    
    BaasClient *client = [BaasClient createInstance];
    [client setDelegate:self];
    [client setAuth:access_token];
    [client getEntities:@"feed" query:query];	
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
