//
//  UMComForumUserTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

@class UMComUser;

@protocol UMComUserOperationFinishDelegate;

@interface UMComForumUserTableViewController : UMComRequestTableViewController

@property (nonatomic, strong) NSArray *userList;

//@property (nonatomic, copy) void (^focusedUserFinish)();

@property (nonatomic, assign) id<UMComUserOperationFinishDelegate> userOperationFinishDelegate;

//但第一次登录时会进入推荐用户页面， 推荐用户页面点击完成操作时会调用这个block
@property (nonatomic, copy) void (^completion)(UIViewController *viewController);

- (id)initWithCompletion:(void (^)(UIViewController *viewController))completion;

- (void)insertUserToTableView:(UMComUser *)user;

- (void)deleteUserFromTableView:(UMComUser *)user;


@end
