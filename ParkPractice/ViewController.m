//
//  ViewController.m
//  ParkPractice
//
//  Created by JasonChiang on 2018/8/31.
//  Copyright © 2018年 JasonChiang. All rights reserved.
//

#import "ViewController.h"
#import "ParkCollectionViewController.h"
#import <MDCAppBar.h>

//static CGFloat kPestoAnimationDuration = 0.33f;
static CGFloat kPestoInset = 5.f;

@interface ViewController ()<UINavigationControllerDelegate,ParkCollectionViewControllerDelegate,UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>
@property(nonatomic, strong) MDCAppBar *appBar;
@property(nonatomic, strong) ParkCollectionViewController *collectionViewController;
@property(nonatomic, strong) UIImageView *zoomableView;
@property(nonatomic, strong) UIView *zoomableCardView;
@end

@implementation ViewController

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    CGFloat sectionInset = kPestoInset * 2.f;
    [layout setSectionInset:UIEdgeInsetsMake(sectionInset, sectionInset, sectionInset, sectionInset)];
    ParkCollectionViewController *collectionVC= [[ParkCollectionViewController alloc]init];
    self = [super initWithContentViewController:collectionVC];
    if (self) {
        _collectionViewController = collectionVC;
        _collectionViewController.flexHeaderContainerVC = self;
        _collectionViewController.delegate = self;
        
        _appBar = [[MDCAppBar alloc] init];
        [self addChildViewController:_appBar.headerViewController];
        
        _appBar.headerViewController.headerView.backgroundColor = [UIColor clearColor];
        _appBar.navigationBar.tintColor = [UIColor whiteColor];

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.appBar addSubviewsToParent];
    self.zoomableCardView = [[UIView alloc] initWithFrame:CGRectZero];
    self.zoomableCardView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.zoomableCardView];
    self.zoomableView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.zoomableView.backgroundColor = [UIColor lightGrayColor];
    self.zoomableView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.zoomableView];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id<UIViewControllerAnimatedTransitioning>)
animationControllerForPresentedController:(UIViewController *)presented
presentingController:(UIViewController *)presenting
sourceController:(UIViewController *)source {
    return nil;
}

- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:
(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *const fromController =
    [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *const toController =
    [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if ([fromController isKindOfClass:[ParkCollectionViewController class]] &&
        [toController isKindOfClass:self.class]) {
        CGRect detailFrame = fromController.view.frame;
        detailFrame.origin.y = self.view.frame.size.height;
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             fromController.view.frame = detailFrame;
                         }
                         completion:^(BOOL finished) {
                             [fromController.view removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)didSelectCell:(ParkCollectionViewCell *)cell completion:(void (^)(void))completionBlock {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
