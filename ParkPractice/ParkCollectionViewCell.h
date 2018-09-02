//
//  ParkCollectionViewCell.h
//  ParkPractice
//
//  Created by JasonChiang on 2018/9/1.
//  Copyright © 2018年 JasonChiang. All rights reserved.
//

#import "MDCCollectionViewCell.h"



@interface ParkCollectionViewCell : MDCCollectionViewCell
@property(nonatomic, copy) NSString *ParkName;
@property(nonatomic, copy) NSString *Introduction;
@property(nonatomic) UITextView *introductionLabel;
@property(nonatomic) UILabel *parkNameLabel;


- (void)populateContentWithName:(NSString *)ParkName introduction:(NSString *)Introduction;
@end


