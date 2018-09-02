//
//  ParkCollectionViewController.h
//  ParkPractice
//
//  Created by JasonChiang on 2018/9/1.
//  Copyright © 2018年 JasonChiang. All rights reserved.
//

#import <MDCCollectionViewController.h>
#import <MaterialCollections.h>
#import <MaterialFlexibleHeader.h>
#import "ParkCollectionViewCell.h"
#import "EGORefreshTableHeaderView/EGORefreshTableHeaderView.h"


@protocol ParkCollectionViewControllerDelegate <NSObject>

@optional

- (void)didSelectCell:(ParkCollectionViewCell *)cell completion:(void (^)(void))completionBlock;

@end

@interface ParkCollectionViewController : MDCCollectionViewController

@property(weak, nonatomic) id<ParkCollectionViewControllerDelegate> delegate;
@property(nonatomic) CGFloat scrollOffsetY;
@property(nonatomic) MDCFlexibleHeaderContainerViewController *flexHeaderContainerVC;
@property (nonatomic,assign)int totalCount;
@property (nonatomic,retain)NSString* desc;
@property (nonatomic,assign)BOOL hasMore;
@property (nonatomic,retain)NSMutableArray *dataList;
@property (nonatomic,assign)int currentPageNo;
@property (nonatomic,retain)EGORefreshTableHeaderView *refreshHeaderView;
@end
