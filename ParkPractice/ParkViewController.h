//
//  ParkViewController.h
//  ParkPractice
//
//  Created by JasonChiang on 2018/9/1.
//  Copyright © 2018年 JasonChiang. All rights reserved.
//

#import "ViewController.h"
#import "EGORefreshTableHeaderView/EGORefreshTableHeaderView.h"



@interface ParkViewController : UIViewController

@property (nonatomic,assign)int totalCount;
@property (nonatomic,retain)NSString* desc;
@property (nonatomic,assign)BOOL hasMore;
@property (nonatomic,retain)NSMutableArray *dataList;
@property (nonatomic,retain)UITableView *tableview;
@property (nonatomic,assign)int currentPageNo;
@property (nonatomic,retain)EGORefreshTableHeaderView *refreshHeaderView;

@end
