//
//  ComicCell.h
//  ManMan
//
//  Created by 余婷 on 16/3/11.
//  Copyright © 2016年 余婷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComicModel.h"

@interface ComicCell : UITableViewCell

//1.创建一个属性来接收需要显示的数据
@property(nonatomic, strong)ComicModel * model;

@end
