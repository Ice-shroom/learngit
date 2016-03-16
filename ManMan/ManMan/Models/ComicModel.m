//
//  ComicModel.m
//  ManMan
//
//  Created by 余婷 on 16/3/11.
//  Copyright © 2016年 余婷. All rights reserved.
//

#import "ComicModel.h"

@implementation ComicModel

- (instancetype)initWithDict:(NSDictionary *)dict{

    if (self = [super init]) {
        
        //封面(NULL)
        NSString * str = dict[@"cover"];
        
        //如何判断服务器返回的数据是否是空？
        //!!!解决方案:[str isKindOfClass:[NSNull class]],如果是空返回YES,否则返回NO
        if (![str isKindOfClass:[NSNull class]]) {
            
            self.file = str;
        }else{
        
            self.file = dict[@"attachment"][@"file"];
        }
        
        

        
        //作者名
        self.author = dict[@"author"];
        //头像
        self.author_avatar = dict[@"author_avatar_thumb"];
        //标题
        self.post_title = dict[@"post_title"];
        
        //系列名称
        self.series_title = dict[@"series_title"];
        //点赞数
        self.likes = dict[@"likes"];
        
        //评论数
        self.comments_num = dict[@"comments_num"];
        
        //第几话
        self.part = dict[@"part"];
        
    }
    
    return self;
}

@end
