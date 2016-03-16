//
//  ComicViewController.m
//  ManMan
//
//  Created by 余婷 on 16/3/11.
//  Copyright © 2016年 余婷. All rights reserved.
//

#import "ComicViewController.h"
#import "ManManAPI.h"
#import "ComicModel.h"
#import "UIImageView+AFNetworking.h"
#import "ComicCell.h"

#import "MJRefresh.h"

@interface ComicViewController ()

//数据源数组
@property(nonatomic, strong)NSMutableArray * dataArray;

@end

@implementation ComicViewController


#pragma mark - 懒加载
- (NSMutableArray *)dataArray{

    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    
    return _dataArray;
}

#pragma mark - 网络请求数据
- (void)getData:(int)pagesize startIdx:(int)startIdx{

    //1.创建会话模式
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //2.创建session
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    
    
    //3.创建URL
    NSString * urlStr = [Comic_API stringByAppendingFormat:@"&pageSize=%d&startIdx=%d",pagesize, startIdx];
    
    NSURL * url = [NSURL URLWithString:urlStr];
    
    //4.创建请求对象
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    //5.创建任务
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //======网络请求结束======
        //1.处理数组(下拉刷新的时候需要将数组中的数据清空)
        
        //isRefreshing --判断header或footer是否正在刷新
        if ([self.tableView.mj_header isRefreshing]) {
            
            [self.dataArray removeAllObjects];
            [self.tableView.mj_header endRefreshing];
        }
        
        //3.解析数据，放到数组中
        NSArray * array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        //遍历数组拿到所有的字典
        for (NSDictionary * dict in array) {
            
            //根据字典去创建模型
            
            ComicModel * model = [[ComicModel alloc] initWithDict:dict];
        
            [self.dataArray addObject:model];
        }
        
        //2.停止刷新
        
        [self.tableView.mj_footer endRefreshing];
        //一定要在这儿去刷新界面
        //再次去调用dataSource里面所有的协议方法（重新设置组数、行数和cell）
        [self.tableView reloadData];
        
        
        
        
        
        
        
    }];
    
    //6.启动任务
    [task resume];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 350;
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSLog(@"%ld", self.dataArray.count);
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    ComicCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        
        cell = [[ComicCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    //刷新数据
    ComicModel * model = self.dataArray[indexPath.row];
    
//    cell.textLabel.text = model.series_title;
//    cell.detailTextLabel.text = model.post_title;
//    //加载网络图片不可以同步加载
//    //也不要去自己写异步下载（用SDWebImage或者AFNetWorking）
//    [cell.imageView setImageWithURL:[NSURL URLWithString:model.file] placeholderImage:[UIImage imageNamed:@"hua"]];
    cell.model = model;
    
    
    return cell;
    
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    //1.请求数据
    //pagesize：限制每次从服务器返回的数据的条数
    //startIdx：从第几条数据开始返回数据
    [self getData:10 startIdx:0];
    
    //2.下拉刷新和上拉加载更多支持几乎所有继承自UIScrollView的类
    //添加下拉刷新控件
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        //====重新请求第一页的数据=====
        //注意:如果是下拉刷新，在重新获取新的数据的时候必须将数据源中的数据清空
        [self getData:10 startIdx:0];
        
        
    }];
    
    //添加上拉加载更多
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        //====请求更多的数据，从上次结束的位置继续请求=====
        //注意:需要保留之前的数据
        [self getData:10 startIdx:(int)self.dataArray.count];
    }];
    
    /*
    MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    NSMutableArray * refreshingImages = [[NSMutableArray alloc] init];
    for (int i = 0; i < 4; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"image%d", i]];
        [refreshingImages addObject:image];
    }
    // 设置刷新图片
    [footer setImages:refreshingImages forState:MJRefreshStateRefreshing];
    // 设置尾部
    self.tableView.mj_footer = footer;
    */

    
    
}

- (void)loadMoreData{

    
}








@end
