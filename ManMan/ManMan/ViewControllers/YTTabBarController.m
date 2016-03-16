//
//  YTTabBarController.m
//  ManMan
//
//  Created by 余婷 on 16/3/11.
//  Copyright © 2016年 余婷. All rights reserved.
//

#import "YTTabBarController.h"

@interface YTTabBarController ()

@end

@implementation YTTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //定制tabBarItem的选中图片
    //1.拿到所有的TabBarItem
    NSArray * items = self.tabBar.items;
    
    //取出每个item设置其选中图片
    UITabBarItem * item0 = items[0];
    [item0 setSelectedImage:[[UIImage imageNamed:@"tiaoman_d"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarItem * item1 = items[1];
    [item1 setSelectedImage:[[UIImage imageNamed:@"faxian_d"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarItem * item2 = items[2];
    [item2 setSelectedImage:[[UIImage imageNamed:@"fulishe_d"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarItem * item3 = items[3];
    [item3 setSelectedImage:[[UIImage imageNamed:@"wode_d"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //改变UITabrItem文字颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:251/255.0f green:65/255.0f blue:29/255.0f alpha:1]} forState:UIControlStateSelected];
    
    //改变NavigationBar上的文字颜色
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
   
    
    
}


//- (UIStatusBarStyle)preferredStatusBarStyle{
//
//    return UIStatusBarStyleLightContent;
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
