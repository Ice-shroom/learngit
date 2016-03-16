//
//  UMComTopicPostTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComTopicPostTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComTopic.h"
#import "UMComFeed.h"

@interface UMComTopicPostTableViewController ()

@end

@implementation UMComTopicPostTableViewController

- (instancetype)initWithTopic:(UMComTopic *)topic
{
    self = [super init];
    if (self) {
        self.topic = topic;
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
