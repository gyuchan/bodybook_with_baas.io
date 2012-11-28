//
//  UserViewController.h
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 8..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface UserViewController : UITableViewController <EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    
    NSMutableArray *contentArray;
}

@property (nonatomic, retain)NSMutableArray *contentArray;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
