//
//  DiscoverViewController.m
//  ManMan
//
//  Created by 余婷 on 16/3/11.
//  Copyright © 2016年 余婷. All rights reserved.
//

#import "DiscoverViewController.h"
#import "ManManAPI.h"
#import "AFHTTPSessionManager.h"

@interface DiscoverViewController ()<UITableViewDataSource, UITableViewDelegate>{

    UITableView * _tableView;
    UIImageView * _imageView;
}

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //隐藏导航条
    self.navigationController.navigationBarHidden = YES;
    
    [self getDataWithPageSize:@10 startIdx:@0];
    
    [self creatTableView];
}

#pragma mark - 创建界面
- (void)creatTableView{

    //创建tableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    
    
    //创建imageView
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
    _imageView.image = [UIImage imageNamed:@"hua"];
    [self.view addSubview:_imageView];
    
    //添加毛玻璃效果
    //a.创建一个效果
//    UIBlurEffectStyleExtraLight,
//    UIBlurEffectStyleLight,
//    UIBlurEffectStyleDark
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    //2.专门用来添加效果的视图
    UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = _imageView.bounds;
    
    //设置模糊程度
    effectView.alpha = 0.8;
    
    //3.将显示效果的view添加到需要有毛玻璃效果的视图上
    [_imageView addSubview:effectView];
    
    //设置tableView的背景颜色
    _tableView.backgroundColor = [UIColor clearColor];
    
    //设置tableView的内容边距
    _tableView.contentInset = UIEdgeInsetsMake(250, 0, 0, 0);
    
    
    
    
    _tableView.dataSource = self;
    //遵守了UITableViewDelegate 就自动遵守了UIScrollViewDelegate协议
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
    
    
}

#pragma mark - UIScrollView Delegate
//滚动的时候实时调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
 
    NSLog(@"%f", scrollView.contentOffset.y);
    
    if (scrollView.contentOffset.y < -250) {
        _imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, - scrollView.contentOffset.y);
    }else{
    
        _imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 250);
    }
    
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 200;
}

- (UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    return cell;
}

#pragma mark - 网络请求-
- (void)getDataWithPageSize:(NSNumber *)pageSize startIdx:(NSNumber *)startIdx{
    //1.创建网络请求管理员
    //只能通过manager类方法创建
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    
    //2.直接发送网络请求(发送GET请求)
    //参数1:请求地址(字符串)
    //参数2:参数列表（将参数以key-value的形式存到字典）
    //参数3:请求成功后回调的block
    //参数4:请求失败后回调的block
    [manager GET:Discover_API parameters:@{@"pageSize":pageSize, @"startIdx":startIdx} success:^(NSURLSessionDataTask *task, id responseObject) {
        //一般在这儿解析数据(一般情况下，拿到的数据就是已经做完json解析后的数据)
        NSLog(@"=====:%@",responseObject);
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        NSLog(@"%@", error);
        
    }];
    
    
    //一般的post请求(除了上传文件以外的post请求)
//    [manager POST:<#(NSString *)#> parameters:<#(id)#> success:<#^(NSURLSessionDataTask *task, id responseObject)success#> failure:<#^(NSURLSessionDataTask *task, NSError *error)failure#>]
    
    
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
