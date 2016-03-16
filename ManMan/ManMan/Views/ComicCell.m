//
//  ComicCell.m
//  ManMan
//
//  Created by 余婷 on 16/3/11.
//  Copyright © 2016年 余婷. All rights reserved.
//

#import "ComicCell.h"
#import "UIImageView+AFNetworking.h"
#import "ManManAPI.h"

//1.系列名称
//2.标题
//3.封面
//4.头像
//5.作者名字
//6.赞的图标
//7.赞的数量
@implementation ComicCell{

    //1.系列名称
    UILabel * _seriesLabel;
    //2.标题
    UILabel * _titleLabel;
    //3.封面
    UIImageView * _coverImageView;
    //4.头像
    UIImageView * _iconImageView;
    //5.作者名字
    UILabel * _authorLabel;
    //6.赞的图标
    //7.赞的数量
    UIButton * _likeButton;
}

//2.实例化子控件
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //1.系列名称
        _seriesLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_seriesLabel];
        //2.标题
        _titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLabel];
        //3.封面
        _coverImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_coverImageView];
        //4.头像
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
        //5.作者名字
        _authorLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_authorLabel];
        //6.赞的图标
        //7.赞的数量
        
        _likeButton = [[UIButton alloc] init];
        [_likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        [_likeButton setTitleColor:ColorWithRGB(128, 128, 128) forState:UIControlStateNormal];
        [self.contentView addSubview:_likeButton];
        
    }
    return self;
}

//3.计算frame
- (void)layoutSubviews{
    //间距
    CGFloat margin = 8;
    CGFloat bottom = 45;
    //1.系列名称
    CGFloat seriesX = margin;
    CGFloat seriesY = margin;
    CGFloat seriesW = self.frame.size.width - 150;
    CGFloat seriesH = 20;
    _seriesLabel.frame = CGRectMake(seriesX, seriesY, seriesW, seriesH);
    //2.标题
    CGFloat titleX = margin;
    CGFloat titleY = seriesY + seriesH + margin;
    CGFloat titleW = seriesW;
    CGFloat titleH = 23;
    _titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    //3.封面
    CGFloat coverX = margin;
    CGFloat coverY = titleY + titleH + margin;
    CGFloat coverW = self.frame.size.width - margin * 2;
    CGFloat coverH = self.frame.size.height - coverY - bottom;
    _coverImageView.frame = CGRectMake(coverX, coverY, coverW, coverH);
    //4.头像
    CGFloat iconX = 20;
    CGFloat iconH = 50;
    CGFloat iconY = coverY + coverH - iconH/3.0f;
    CGFloat iconW = iconH;
    _iconImageView.frame = CGRectMake(iconX, iconY, iconW, iconH);
    //5.作者名字
    CGFloat authorX = iconX + iconW + margin;
    CGFloat authorY = coverY + coverH;
    CGFloat authorW = self.frame.size.width/2.0f - authorX;
    CGFloat authorH = bottom;
    _authorLabel.frame = CGRectMake(authorX, authorY, authorW, authorH);
    //6.赞的图标
    //7.赞的数量
    CGFloat likeW = 100;
    CGFloat likeX = self.frame.size.width - margin - likeW;
    CGFloat likeY = authorY;
    CGFloat likeH = bottom;
    _likeButton.frame = CGRectMake(likeX, likeY, likeW, likeH);
    
    //如果想要正确的显示分割线，需要调用父类的layoutSubviews方法
    [super layoutSubviews];
}

//4.给属性赋值
- (void)setModel:(ComicModel *)model{

    _model = model;
    
    //1.系列名称
    _seriesLabel.text = model.series_title;
    //2.标题
    _titleLabel.text = model.post_title;
    //3.封面
    [_coverImageView setImageWithURL:[NSURL URLWithString:model.file] placeholderImage:[UIImage imageNamed:@"hua"]];
    //4.头像
    [_iconImageView setImageWithURL:[NSURL URLWithString:model.author_avatar] placeholderImage:[UIImage imageNamed:@"hua"]];
    //5.作者名字
    _authorLabel.text = model.author;
    //6.赞的图标
    //7.赞的数量
    [_likeButton setTitle:[NSString stringWithFormat:@"%@", model.likes] forState:UIControlStateNormal];
    
    
    
    
}

@end
