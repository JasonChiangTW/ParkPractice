//
//  ParkCollectionViewController.m
//  ParkPractice
//
//  Created by JasonChiang on 2018/9/1.
//  Copyright © 2018年 JasonChiang. All rights reserved.
//

#import "ParkCollectionViewController.h"
#import "ParkCollectionViewCell.h"
#import "ParkData.h"

#import <MaterialInk.h>
#import <MaterialShadowElevations.h>
#import <MaterialShadowLayer.h>
#import <MDCTypography.h>

static CGFloat kParkCollectionViewControllerAnimationDuration = 0.33f;
static CGFloat kParkCollectionViewControllerCellHeight = 44.f;
static CGFloat kParkCollectionViewControllerDefaultHeaderHeight = 180.0f;
static CGFloat kParkCollectionViewControllerInset = 5.f;
static CGFloat kParkCollectionViewControllerSmallHeaderHeight = 44.f;
static CGFloat kButtonPadding=10.0f;

static NSString * kParkApiUrlWithOffSetParamter=@"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=bf073841-c734-49bf-a97f-3757a6013812&limit=30&offset=%d";
static NSString * kParkCellIdentity= @"ParkCollectionViewCell%ld";

@interface ParkCollectionViewController ()
@property(nonatomic)BOOL isLoading;
@property(nonatomic) CGFloat logoScale;
@property(nonatomic) MDCInkTouchController *inkTouchController;
@property(nonatomic) ParkData *ParkData;
@property(nonatomic) UIView *logoSmallView;
@property(nonatomic) UIView *logoView;

@end

@implementation ParkCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.collectionView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Customize collection view settings.
    self.styler.cellStyle = MDCCollectionViewCellStyleCard;
    self.styler.cellLayoutType = MDCCollectionViewCellLayoutTypeGrid;
    self.styler.gridPadding = kParkCollectionViewControllerInset * 2;
    if (self.view.frame.size.width < self.view.frame.size.height) {
        self.styler.gridColumnCount = 1;
    } else {
        self.styler.gridColumnCount = 2;
    }
    //取得資料
    self.isLoading =YES;
    self.hasMore=NO;
    self.currentPageNo=1;
    
    [self.collectionView reloadData];
    [NSThread detachNewThreadSelector:@selector(getDataListThread) toTarget:self withObject:nil];
}

#pragma mark - getDataList method
-(void)getDataListThread{
    @autoreleasepool {
        @try {
            NSDictionary *resultDic=[self getDataList];
            if (resultDic!=nil) {
                //判斷呼叫取得資料是否成功
                if ([resultDic objectForKey:@"result"]!=nil) {
                    //解析取得之資料
                    NSDictionary * valueDic=[resultDic objectForKey:@"result"];
                    if ([valueDic objectForKey:@"results"]!=nil) {
                        NSArray* dataArray=[valueDic objectForKey:@"results"];
                        NSMutableArray *tmpDataArray=nil;
                        if (self.hasMore) {
                            tmpDataArray=[[NSMutableArray alloc]initWithArray:self.dataList];
                        }else{
                            tmpDataArray=[[NSMutableArray alloc]init];
                        }
                        for(NSDictionary *parkDic in dataArray){
                            ParkData *marketData=[ParkData genParkDataWithDataDic:parkDic];
                            [tmpDataArray addObject:marketData];
                        }
                        //取得資料總筆數
                        if ([[valueDic objectForKey:@"count"] intValue]>0) {
                            self.totalCount =[[valueDic objectForKey:@"count"] intValue];
                        }else{
                            self.totalCount =0;
                        }
                        self.dataList=tmpDataArray;
                    }
                    //IsHasMore
                    if ([valueDic objectForKey:@"offset"]!=nil){
                        NSInteger offset = [[valueDic objectForKey:@"offset"] integerValue];
                        if(offset+30<=self.totalCount){
                            self.hasMore=YES;
                        }else{
                            self.hasMore=NO;
                        }
                        
                    }
                }else{
                    [self showAlertViewWithTitle:@"失敗" andMessage:[resultDic objectForKey:@"Description"]];
                }
            }else{
                [self showAlertViewWithTitle:@"錯誤" andMessage:@"Server沒反應或網路異常"];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.reason);
        }
        @finally {
            [self performSelectorOnMainThread:@selector(reLoadTableView) withObject:nil waitUntilDone:YES];
        }
    }
}

-(void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{

}

-(NSDictionary *)getDataList{
    NSString * ulrString=[NSString stringWithFormat:kParkApiUrlWithOffSetParamter,(self.currentPageNo-1)*30];
    NSURL *url=[NSURL URLWithString:ulrString];
    NSString *body=nil;
    NSString *jsonString=[[NSString alloc] initWithString:[self doHttpPostWithUrl:url andStringBody:body]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error:nil];
    
    return resultDic;
    
}

-(NSString *)doHttpPostWithUrl:(NSURL *)url andStringBody:(NSString *)body{
    NSData *oResponseData = [self requestSynchronousDataWithURLString: url.absoluteString ];
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

#pragma mark -EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    self.isLoading = YES;
    self.hasMore=NO;
    self.currentPageNo=1;
    [NSThread detachNewThreadSelector:@selector(getDataListThread) toTarget:self withObject:nil];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return self.isLoading; // should return if data source model is reloading
    
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    self.scrollOffsetY = scrollView.contentOffset.y;
    [self.flexHeaderContainerVC.headerViewController scrollViewDidScroll:scrollView];
    [self centerHeaderWithSize:self.view.frame.size];
    self.logoScale = scrollView.contentOffset.y / -kParkCollectionViewControllerDefaultHeaderHeight;
    if (self.logoScale < 0.5f) {
        self.logoScale = 0.5f;
        [UIView animateWithDuration:kParkCollectionViewControllerAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.logoView.layer.opacity = 0;
                             self.logoSmallView.layer.opacity = 1.f;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:kParkCollectionViewControllerAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.logoView.layer.opacity = 1.f;
                             self.logoSmallView.layer.opacity = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    }
    self.logoView.transform =
    CGAffineTransformScale(CGAffineTransformIdentity, self.logoScale, self.logoScale);
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - Private methods

- (void)centerHeaderWithSize:(CGSize)size {
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat width = size.width;
    CGRect headerFrame = self.flexHeaderContainerVC.headerViewController.headerView.bounds;
    self.logoView.center = CGPointMake(width / 2.f, headerFrame.size.height / 2.f);
    self.logoSmallView.center =
    CGPointMake(width / 2.f, (headerFrame.size.height - statusBarHeight) / 2.f + statusBarHeight);
}

- (UIView *)pestoHeaderView {
    CGRect headerFrame = _flexHeaderContainerVC.headerViewController.headerView.bounds;
    UIView *pestoHeaderView = [[UIView alloc] initWithFrame:headerFrame];
    UIColor *teal = [UIColor colorWithRed:0.59 green:0.58 blue:0.99 alpha:1.0];
    pestoHeaderView.backgroundColor = teal;
    pestoHeaderView.layer.masksToBounds = YES;
    pestoHeaderView.autoresizingMask =
    (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.frame = CGRectMake(0,[[UIApplication sharedApplication] statusBarFrame].size.height,pestoHeaderView.frame.size.width,kParkCollectionViewControllerCellHeight);
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont fontWithName:@"Arial" size:20.0f]];
    titleLabel.text=@"我是 Navigation bar";
    [pestoHeaderView addSubview:titleLabel];
    
    int functionCount=3;
    CGFloat funcBtnWidth=(self.view.frame.size.width-kButtonPadding*(functionCount+1))/functionCount;

    UIButton *funcA=[[UIButton alloc]initWithFrame:CGRectMake(kButtonPadding,titleLabel.frame.origin.y+titleLabel.frame.size.height+ kButtonPadding, funcBtnWidth, 100)];
    funcA.backgroundColor=[UIColor colorWithRed:0.63 green:0.63 blue:0.98 alpha:1.0];
    [funcA setTitle:@"功能Ａ" forState:UIControlStateNormal];
    funcA.titleLabel.textColor=[UIColor whiteColor];
    [pestoHeaderView addSubview:funcA];
    
    UIButton *funcB=[[UIButton alloc]initWithFrame:CGRectMake(funcBtnWidth+kButtonPadding*2,titleLabel.frame.origin.y+titleLabel.frame.size.height+ kButtonPadding, funcBtnWidth, 100)];
    funcB.backgroundColor=[UIColor colorWithRed:0.63 green:0.63 blue:0.98 alpha:1.0];
    [funcB setTitle:@"功能Ｂ" forState:UIControlStateNormal];
    funcB.titleLabel.textColor=[UIColor whiteColor];
    [pestoHeaderView addSubview:funcB];
    
    UIButton *funcC=[[UIButton alloc]initWithFrame:CGRectMake(funcBtnWidth*2+kButtonPadding*3,titleLabel.frame.origin.y+titleLabel.frame.size.height+ kButtonPadding, funcBtnWidth, 100)];
    funcC.backgroundColor=[UIColor colorWithRed:0.63 green:0.63 blue:0.98 alpha:1.0];
    [funcC setTitle:@"功能Ｃ" forState:UIControlStateNormal];
    funcC.titleLabel.textColor=[UIColor whiteColor];
    [pestoHeaderView addSubview:funcC];
    
    
    _inkTouchController = [[MDCInkTouchController alloc] initWithView:pestoHeaderView];
    [_inkTouchController addInkView];
    
    return pestoHeaderView;
}

- (void)setFlexHeaderContainerVC:(MDCFlexibleHeaderContainerViewController *)flexHeaderContainerVC {
    _flexHeaderContainerVC = flexHeaderContainerVC;
    MDCFlexibleHeaderView *headerView = _flexHeaderContainerVC.headerViewController.headerView;
    headerView.trackingScrollView = self.collectionView;
    headerView.maximumHeight = kParkCollectionViewControllerDefaultHeaderHeight;
    headerView.minimumHeight = kParkCollectionViewControllerSmallHeaderHeight;
    headerView.minMaxHeightIncludesSafeArea = NO;
    [headerView addSubview:[self pestoHeaderView]];
    
    MDCShadowLayer *shadowLayer = [MDCShadowLayer layer];
    [headerView setShadowLayer:shadowLayer
       intensityDidChangeBlock:^(CALayer *layer, CGFloat intensity) {
           CGFloat elevation = MDCShadowElevationAppBar * intensity;
           [(MDCShadowLayer *)layer setElevation:elevation];
       }];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (size.width < size.height) {
        self.styler.gridColumnCount = 1;
    } else {
        self.styler.gridColumnCount = 2;
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self centerHeaderWithSize:size];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self centerHeaderWithSize:self.view.frame.size];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.dataList count] ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString * stringID = [NSString stringWithFormat:kParkCellIdentity,indexPath.row];
    ParkCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringID forIndexPath:indexPath];
    ParkData* itemData=[self.dataList objectAtIndex:indexPath.row];
    [cell populateContentWithName:itemData.ParkName introduction:itemData.Introduction];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    ParkCollectionViewCell *cell =
    (ParkCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.delegate didSelectCell:cell
                      completion:^{
                          
                      }];
}


- (CGFloat)getTextHeight:(NSString*)text andSize:(CGFloat)fontSize andFrameSize:(CGFloat)frameSize
{
    CGSize constraint = CGSizeMake(frameSize, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                                  context:context].size;

    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));

    return size.height;
}

#pragma mark - <MDCCollectionViewStylingDelegate>
static CGFloat wordingPadding = 20.0f;
- (CGFloat)collectionView:(UICollectionView *)collectionView cellHeightAtIndexPath:(NSIndexPath *)indexPath {

    ParkData* itemData=[self.dataList objectAtIndex:indexPath.row];
    double height=[self getTextHeight:itemData.ParkName andSize:[MDCTypography headlineFont].pointSize andFrameSize:collectionView.bounds.size.width-wordingPadding*2]
    +[self getTextHeight:itemData.Introduction andSize:[MDCTypography captionFont].pointSize andFrameSize:collectionView.bounds.size.width-wordingPadding*2]
    +wordingPadding*3;
    
//    ParkCollectionViewCell *cell = [collectionView
//                                    dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ParkCollectionViewCell class])
//                                    forIndexPath:indexPath];
    
//    cell.introductionLabel.frame=CGRectMake(0, 0, cell.frame.size.width,100 );
    
    NSLog(@"indexPath=%@ , height=%@", [NSNumber numberWithFloat:indexPath.row], [NSNumber numberWithDouble:height]);
    return height;
}

#pragma mark - LoadMore Template method
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint _scrollViewContentOffset     = scrollView.contentOffset;
    CGRect _scrollViewBounds             = scrollView.bounds;
    CGSize _scrollViewContentSize        = scrollView.contentSize;
    UIEdgeInsets _scrollViewContentInset = scrollView.contentInset;
    float y = _scrollViewContentOffset.y + _scrollViewBounds.size.height - _scrollViewContentInset.top;
    
    float h = _scrollViewContentSize.height;
    float _loadDistance = 0.0f;
    
    //Scroll to Top
    if( _scrollViewContentOffset.y <= 0.0f )
    {
        
    }
    //Scroll to Bottom
    if( y >= h + _loadDistance - kParkCollectionViewControllerDefaultHeaderHeight && _scrollViewContentOffset.y > 0.0f )
    {
        if (self.hasMore) {
            self.currentPageNo++;
            self.isLoading=YES;
            [self.collectionView reloadData];
            [NSThread detachNewThreadSelector:@selector(getDataListThread) toTarget:self withObject:nil];
        }
    }
    
}

-(void)reLoadTableView{
    
    for (NSInteger i = 0; i < [self.dataList count] ; i++) {
        NSString * stringID = [NSString stringWithFormat:kParkCellIdentity,i];
        [self.collectionView registerClass:[ParkCollectionViewCell class] forCellWithReuseIdentifier:stringID];
    }
    self.isLoading=NO;
    [self.collectionView reloadData];
}

#pragma NSURL

-(NSData *)requestSynchronousData:(NSURLRequest *)request
{
    __block NSData *data = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
        data = taskData;
        if (!data) {
            NSLog(@"%@", error);
        }
        dispatch_semaphore_signal(semaphore);
        
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return data;
}

-(NSData *)requestSynchronousDataWithURLString:(NSString *)requestString
{
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return [self requestSynchronousData:request];
}

-(NSDictionary *)requestSynchronousJSON:(NSURLRequest *)request
{
    NSData *data = [self requestSynchronousData:request];
    NSError *e = nil;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    return jsonData;
}

-(NSDictionary *)requestSynchronousJSONWithURLString:(NSString *)requestString
{
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:50];
    theRequest.HTTPMethod = @"GET";
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return [self requestSynchronousJSON:theRequest];
}


@end
