//
//  ParkCollectionViewCell.m
//  ParkPractice
//
//  Created by JasonChiang on 2018/9/1.
//  Copyright © 2018年 JasonChiang. All rights reserved.
//

#import "ParkCollectionViewCell.h"
#import <MDCShadowLayer.h>
#import <MDCTypography.h>

static CGFloat wordingPadding = 20.0f;
@interface ParkCollectionViewCell ()
@property(nonatomic) UIView *cellView;

@end

@implementation ParkCollectionViewCell



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    NSLog(@"commonInit_commonInit_commonInit_");
    _cellView = [[UIView alloc] initWithFrame:self.bounds];
    _cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _cellView.backgroundColor = [UIColor whiteColor];
    _cellView.clipsToBounds = YES;
    [self addSubview:_cellView];

    MDCShadowLayer *shadowLayer = (MDCShadowLayer *)self.layer;
    shadowLayer.shadowMaskEnabled = NO;
    [shadowLayer setElevation:MDCShadowElevationNone];
    
    _parkNameLabel = [[UILabel alloc] init];
    _parkNameLabel.font = [MDCTypography headlineFont];
    _parkNameLabel.alpha = [MDCTypography headlineFontOpacity];
    _parkNameLabel.textColor = [UIColor colorWithWhite:0 alpha:0.87f];
    _parkNameLabel.frame = CGRectMake(wordingPadding,0,_cellView.bounds.size.width-wordingPadding*2,[MDCTypography headlineFont].pointSize);
    _parkNameLabel.textAlignment=NSTextAlignmentCenter;
    [_cellView addSubview:_parkNameLabel];
    
    
    _introductionLabel = [[UITextView alloc] init];
    _introductionLabel.font = [MDCTypography captionFont];
    _introductionLabel.alpha = [MDCTypography captionFontOpacity];
    _introductionLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1.f];
   _introductionLabel.frame = CGRectMake(wordingPadding,[MDCTypography headlineFont].pointSize+wordingPadding,_cellView.bounds.size.width-wordingPadding*2,_cellView.bounds.size.height- [MDCTypography headlineFont].pointSize-wordingPadding);
    _introductionLabel.textAlignment=NSTextAlignmentLeft;
    
    [_cellView addSubview:_introductionLabel];
}


- (void)prepareForReuse {
    [super prepareForReuse];
    self.ParkName=nil;
    self.Introduction=nil;
}



+ (Class)layerClass {
    return [MDCShadowLayer class];
}
- (void)populateContentWithName:(NSString *)ParkName introduction:(NSString *)Introduction{
    self.parkNameLabel.text = ParkName;
    self.introductionLabel.text = Introduction;
}
@end
