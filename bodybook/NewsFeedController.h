//
//  NewsFeedController.h
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 8..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface NewsFeedController : UITableViewController <EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    
    int step;
    NSMutableArray *userFriendArray;
    NSMutableArray *contentArray;
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
