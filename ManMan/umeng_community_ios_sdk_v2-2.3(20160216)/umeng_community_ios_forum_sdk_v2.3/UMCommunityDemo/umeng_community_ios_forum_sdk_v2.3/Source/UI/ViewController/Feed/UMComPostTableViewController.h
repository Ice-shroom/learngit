//
//  UMComPostViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/17.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

#define UMCom_Forum_Post_Cell_Top_Edge 8

static NSString * UMComPostTableViewCellIdentifier = @"UMComPostTableViewCellIdentifier";

@class UMComFeed;
@interface UMComPostTableViewController : UMComRequestTableViewController

@property (nonatomic, assign) BOOL showTopMark;

@property (nonatomic, assign) CGFloat cell_top_edge;

- (void)inserNewFeedInTabelView:(UMComFeed *)feed;

- (void)deleteNewFeedInTabelView:(UMComFeed *)feed;

@end
