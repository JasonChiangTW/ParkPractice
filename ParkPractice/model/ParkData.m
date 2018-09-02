//
//  ParkData.m
//  ParkPractice
//
//  Created by JasonChiang on 2018/8/31.
//  Copyright © 2018年 JasonChiang. All rights reserved.
//

#import "ParkData.h"

@implementation ParkData

-(id)init{
    self=[super init];
    if (self) {
        self.id=@"";
        self.ParkName=@"";
        self.Name=@"";
        self.YearBuilt=@"";
        self.OpenTime=@"";
        self.Image=@"";
        self.Introduction=@"";
    }
    return self;
}
+(ParkData*)genParkDataWithDataDic:(NSDictionary*)tmpDic{
    ParkData *parkData= [ParkData new];
    
    if ([[tmpDic objectForKey:@"id"] isKindOfClass:[NSString class]]) {
        parkData.id=[tmpDic objectForKey:@"_id"];
    }
    if ([[tmpDic objectForKey:@"ParkName"] isKindOfClass:[NSString class]]) {
        parkData.ParkName=[tmpDic objectForKey:@"ParkName"];
    }
    if ([[tmpDic objectForKey:@"Name"] isKindOfClass:[NSString class]]) {
        parkData.Name=[tmpDic objectForKey:@"Name"];
    }
    if ([[tmpDic objectForKey:@"YearBuilt"] isKindOfClass:[NSString class]]) {
        parkData.YearBuilt=[tmpDic objectForKey:@"YearBuilt"];
    }
    if ([[tmpDic objectForKey:@"OpenTime"] isKindOfClass:[NSString class]]) {
        parkData.OpenTime=[tmpDic objectForKey:@"OpenTime"];
    }
    if ([[tmpDic objectForKey:@"Image"] isKindOfClass:[NSString class]]) {
        parkData.Image=[tmpDic objectForKey:@"Image"];
    }
    if ([[tmpDic objectForKey:@"Introduction"] isKindOfClass:[NSString class]]) {
        parkData.Introduction=[tmpDic objectForKey:@"Introduction"];
    }
    
    
    return parkData;
}

@end

