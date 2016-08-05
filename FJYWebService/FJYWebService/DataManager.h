//
//  DataManager.h
//  新能源汽车基础知识测评系统
//
//  Created by 冯佳玉 on 16/7/5.
//  Copyright © 2016年 方磊. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DataBlock)(NSDictionary *dict,NSError *error);

@interface DataManager : NSObject
- (void)getDataFromWebserviceWithMethod:(NSString *)method andParameter:(NSDictionary *)dict andKeyArr:(NSArray *)array handle:(DataBlock)block;
@end
