//
//  UMComForumTopicTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/26.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

@class UMComTopicType, UMComTopic;

@interface UMComForumTopicTableViewController : UMComRequestTableViewController

@property (nonatomic, copy) void (^completion)(UIViewController *viewController);

@property (nonatomic, assign) BOOL isShowNextButton;

@property (nonatomic, strong) UMComTopicType *topicType;

- (instancetype)initWithCompletion:(void (^)(UIViewController *viewController))completion;

- (void)showTopicPostTableViewWithTopicAtIndexPath:(NSIndexPath *)indexPath;

- (void)insertTopicToTableView:(UMComTopic *)topic;

- (void)deleteTopicFromTableView:(UMComTopic *)topic;

-(void) updateTopicFromTableView:(UMComTopic *)topic;

@end
