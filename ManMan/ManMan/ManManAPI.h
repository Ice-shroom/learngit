//
//  ManManAPI.h
//  ManMan
//
//  Created by 余婷 on 16/3/11.
//  Copyright © 2016年 余婷. All rights reserved.
//

#ifndef ManManAPI_h
#define ManManAPI_h

//=============常用工具==================
#define ColorWithRGB(R,G,B) [UIColor colorWithRed:(R)/255.0f green:(G)/255.0f blue:(B)/255.0f alpha:1]


//==============网络接口=================
#define ManManApi @"https://comic.idreamcastle.com/api/"
#define Access_Token @"?access_token=ecpzcknd9wv92hwoafgbj0r28w24h9xl"



#pragma mark =======条漫============
#define Comic_API [[ManManApi stringByAppendingString:@"getHomePage/"] stringByAppendingString:Access_Token]


#pragma mark =======发现============
#define Discover_API [[ManManApi stringByAppendingString:@"getDiscoveries/"] stringByAppendingString:Access_Token]







#endif /* ManManAPI_h */
