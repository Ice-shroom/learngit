//
//  UMComForumUserTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumUserTableViewController.h"
#import "UMComUser.h"
#import "UMComForumUserTableViewCell.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComClickActionDelegate.h"
#import "UMComForumUserCenterViewController.h"
#import "UMComPushRequest.h"
#import "UMComAction.h"
#import "UMComShowToast.h"
#import "UMComBarButtonItem.h"
#import "UIViewController+UMComAddition.h"
#import "UMComUserOperationFinishDelegate.h"

#define UMCom_Forum_User_Cell_height 65

@interface UMComForumUserTableViewController ()<UMComClickActionDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation UMComForumUserTableViewController

- (id)initWithCompletion:(void (^)(UIViewController *viewController))completion
{
    self = [super init];
    if (self) {
        self.completion = completion;
        UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"FinishStep",@"完成") target:self action:@selector(onClickNext)];
        [self.navigationItem setRightBarButtonItem:rightButtonItem];
    }
    return self;
}

- (void)onClickNext
{
    if (self.completion) {
        self.completion(self);
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UMCom_Forum_User_Cell_height;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (self.userList) {
        self.dataArray = self.userList;
        [self.tableView reloadData];
    }
    
    if (self.title) {
        [self setForumUITitle:self.title];
    }else{
        [self setForumUITitle:@"用户列表"];
    }
    // Do any additional setup after loading the view.
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UMComForumUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComForumUserTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId cellSize:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    UMComUser *user = self.dataArray[indexPath.row];
    [cell reloadCellWithUser:user];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(id responseObject, NSError *error) {
        UMComForumUserCenterViewController *userCenter = [[UMComForumUserCenterViewController alloc]initWithUser:self.dataArray[indexPath.row]];
        userCenter.userOperationFinishDelegate = weakSelf.userOperationFinishDelegate;
        [self.navigationController pushViewController:userCenter animated:YES];
    }];
}

- (void)customObj:(id)obj clickOnFollowUser:(UMComUser *)user
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(id responseObject, NSError *error) {
        [UMComPushRequest followerWithUser:user isFollow:![user.has_followed boolValue] completion:^(NSError *error) {
            if (error) {
                [UMComShowToast showFetchResultTipWithError:error];
            }
            [weakSelf.tableView reloadData];
            if (weakSelf.userOperationFinishDelegate && [self.userOperationFinishDelegate respondsToSelector:@selector(focusedUserOperationFinish:)]) {
                [weakSelf.userOperationFinishDelegate focusedUserOperationFinish:user];
            }
        }];
    }];
}

- (void)insertUserToTableView:(UMComUser *)user
{
    if (!user) {
        return;
    }
    if ([user isKindOfClass:[UMComUser class]]) {
        NSMutableArray *userList = nil;
        if (self.dataArray.count > 0) {
            userList = [NSMutableArray arrayWithArray:self.dataArray];
            if (![userList containsObject:user]) {
                [userList insertObject:user atIndex:0];  
            }
        }else{
            userList = [NSMutableArray arrayWithObject:user];
        }
        self.dataArray = userList;
        [self insertCellAtRow:0 section:0];
    }
}

- (void)deleteUserFromTableView:(UMComUser *)deleteUser
{
    if (!deleteUser) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    if ([deleteUser isKindOfClass:[UMComUser class]]) {
        NSMutableArray *userList = [NSMutableArray arrayWithArray:self.dataArray];
        [userList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UMComUser *user = (UMComUser *)obj;
            if ([user.uid isEqualToString:deleteUser.uid]) {
                *stop = YES;
                [userList removeObject:user];
                weakSelf.dataArray = userList;
                [weakSelf deleteCellAtRow:idx section:0];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
