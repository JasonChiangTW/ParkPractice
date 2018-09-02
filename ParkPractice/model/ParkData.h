//
//  ParkData.h
//  ParkPractice
//
//  Created by JasonChiang on 2018/8/31.
//  Copyright © 2018年 JasonChiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParkData : NSObject

@property (nonatomic,retain)NSString* id;
@property (nonatomic,retain)NSString* ParkName;
@property (nonatomic,retain)NSString* Name;
@property (nonatomic,retain)NSString* YearBuilt;
@property (nonatomic,retain)NSString* OpenTime;
@property (nonatomic,retain)NSString* Image;
@property (nonatomic,retain)NSString* Introduction;

+(ParkData*)genParkDataWithDataDic:(NSDictionary*)tmpDic;

@end
