//
//  ParkViewController.m
//  ParkPractice
//
//  Created by JasonChiang on 2018/9/1.
//  Copyright © 2018年 JasonChiang. All rights reserved.
//

#import "ParkViewController.h"
#import "ParkData.h"
#import <MaterialAppBar.h>
#import <MaterialInk.h>
#import <MaterialShadowElevations.h>
#import <MaterialShadowLayer.h>

//static CGFloat kPestoCollectionViewControllerAnimationDuration = 0.33f;
////static CGFloat kPestoCollectionViewControllerCellHeight = 300.f;
//static CGFloat kPestoCollectionViewControllerDefaultHeaderHeight = 220.f;
////static CGFloat kPestoCollectionViewControllerInset = 5.f;
//static CGFloat kPestoCollectionViewControllerSmallHeaderHeight = 56.f;

@interface ParkViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic)BOOL isLoading;
//@property(nonatomic) CGFloat logoScale;
//@property(nonatomic) MDCInkTouchController *inkTouchController;
//@property(nonatomic) UIView *logoSmallView;
//@property(nonatomic) UIView *logoView;
@end

@implementation ParkViewController

//
//#pragma mark - PestoSideViewDelegate
//
//- (void)didSelectSettings {
//    [self dismissViewControllerAnimated:true completion:nil];
//}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"我是Navigation bar";
    // Setup the table view
  
    
    //配置UITableView
    self.tableview=[[UITableView alloc] init];
    self.tableview.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);

    //設定UITableViewDataSource
    self.tableview.delegate = self;
    self.tableview.dataSource=self;
    //設定UITableViewDelegate
    
    [self.view addSubview:self.tableview];
    
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    //取得資料
    self.isLoading =YES;
    self.hasMore=NO;
    self.currentPageNo=1;
    [self.tableview reloadData];
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
    //    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"關閉" otherButtonTitles:nil];
    //    [alertView show];
}

-(NSDictionary *)getDataList{
    NSString * ulrString=[NSString stringWithFormat:@"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=bf073841-c734-49bf-a97f-3757a6013812&limit=30&offset=%d",(self.currentPageNo-1)*30];
    NSURL *url=[NSURL URLWithString:ulrString];  // 取得WS路徑
    NSString *body=nil;
    //    NSLog(@"取得資料 :: %@?%@",url,body);
    NSString *jsonString=[[NSString alloc] initWithString:[self doHttpPostWithUrl:url andStringBody:body]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error:nil];
    
    return resultDic;
    
}

-(NSString *)doHttpPostWithUrl:(NSURL *)url andStringBody:(NSString *)body{
//    NSLog(@" 💖 call api= %@,self.currentPage=%d", url.absoluteString,self.currentPageNo);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
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

//下拉一段距離到提示鬆開和鬆開後提示都應該有變化，將狀態變更為鬆開後更新內容
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
//    self.scrollOffsetY = scrollView.contentOffset.y;
//    [self.flexHeaderContainerVC.headerViewController scrollViewDidScroll:scrollView];
//    [self centerHeaderWithSize:self.view.frame.size];
//    self.logoScale = scrollView.contentOffset.y / -kPestoCollectionViewControllerDefaultHeaderHeight;
//    NSLog(@"self.logoScale=%f",self.logoScale);
//    if (self.logoScale < 0.5f) {
//        self.logoScale = 0.5f;
//        [UIView animateWithDuration:kPestoCollectionViewControllerAnimationDuration
//                              delay:0
//                            options:UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             self.logoView.layer.opacity = 0;
//                             self.logoSmallView.layer.opacity = 1.f;
//                         }
//                         completion:^(BOOL finished){
//                         }];
//    } else {
//        [UIView animateWithDuration:kPestoCollectionViewControllerAnimationDuration
//                              delay:0
//                            options:UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             self.logoView.layer.opacity = 1.f;
//                             self.logoSmallView.layer.opacity = 0;
//                         }
//                         completion:^(BOOL finished){
//                         }];
//    }
//    self.logoView.transform =
//    CGAffineTransformScale(CGAffineTransformIdentity, self.logoScale, self.logoScale);
}
//鬆開後判斷 scrollView 是否在刷新，若再刷新則表格位置偏移，並且狀態文字變更為loading...
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

//
//#pragma mark - Private methods
//
//- (void)centerHeaderWithSize:(CGSize)size {
//    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
//    CGFloat width = size.width;
//    CGRect headerFrame = self.flexHeaderContainerVC.headerViewController.headerView.bounds;
//    self.logoView.center = CGPointMake(width / 2.f, headerFrame.size.height / 2.f);
//    self.logoSmallView.center =
//    CGPointMake(width / 2.f, (headerFrame.size.height - statusBarHeight) / 2.f + statusBarHeight);
//}
//
//- (UIView *)pestoHeaderView {
//    CGRect headerFrame = _flexHeaderContainerVC.headerViewController.headerView.bounds;
//    UIView *pestoHeaderView = [[UIView alloc] initWithFrame:headerFrame];
//    UIColor *teal = [UIColor colorWithRed:0.59 green:0.58 blue:0.99 alpha:1.0];
//    pestoHeaderView.backgroundColor = teal;
//    pestoHeaderView.layer.masksToBounds = YES;
//    pestoHeaderView.autoresizingMask =
//    (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//    
//    UIImage *image = [UIImage imageNamed:@"PestoLogoLarge"];
//    _logoView = [[UIImageView alloc] initWithImage:image];
//    _logoView.contentMode = UIViewContentModeScaleAspectFill;
//    _logoView.center =
//    CGPointMake(pestoHeaderView.frame.size.width / 2.f, pestoHeaderView.frame.size.height / 2.f);
//    [pestoHeaderView addSubview:_logoView];
//    
//    UIImage *logoSmallImage = [UIImage imageNamed:@"PestoLogoSmall"];
//    _logoSmallView = [[UIImageView alloc] initWithImage:logoSmallImage];
//    _logoSmallView.contentMode = UIViewContentModeScaleAspectFill;
//    _logoSmallView.layer.opacity = 0;
//    [pestoHeaderView addSubview:_logoSmallView];
//    
//    _inkTouchController = [[MDCInkTouchController alloc] initWithView:pestoHeaderView];
//    [_inkTouchController addInkView];
//    
//    return pestoHeaderView;
//}

//- (void)setFlexHeaderContainerVC:(MDCFlexibleHeaderContainerViewController *)flexHeaderContainerVC {
//    _flexHeaderContainerVC = flexHeaderContainerVC;
//    MDCFlexibleHeaderView *headerView = _flexHeaderContainerVC.headerViewController.headerView;
//    headerView.trackingScrollView = self.collectionView;
//    headerView.maximumHeight = kPestoCollectionViewControllerDefaultHeaderHeight;
//    headerView.minimumHeight = kPestoCollectionViewControllerSmallHeaderHeight;
//    headerView.minMaxHeightIncludesSafeArea = NO;
//    [headerView addSubview:[self pestoHeaderView]];
//    
//    // Use a custom shadow under the flexible header.
//    MDCShadowLayer *shadowLayer = [MDCShadowLayer layer];
//    [headerView setShadowLayer:shadowLayer
//       intensityDidChangeBlock:^(CALayer *layer, CGFloat intensity) {
//           CGFloat elevation = MDCShadowElevationAppBar * intensity;
//           [(MDCShadowLayer *)layer setElevation:elevation];
//       }];
//}


#pragma mark - UITableViewDataSource

//設定 tableView DataSource 資料數量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return self.dataList.count;
        default:
            if (self.isLoading || self.dataList.count==0) {
                return 1;
            }
            break;
            
    }
    return 0;
}
//回傳 tableView 中包含多少個 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

//設定 tableView 樣式
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ParkData* itemData=[self.dataList objectAtIndex:indexPath.row];
    static NSString *CellIdentifier=@"Cell";
    static NSString *LoadingIdentifier=@"LoadingCell";
    UITableViewCell *cell=nil;
    switch (indexPath.section) {
        case 0:{
            cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.text=[NSString stringWithFormat:@"%@",itemData.ParkName];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",itemData.Introduction];
            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textColor=[UIColor grayColor];
        }
            break;
        default:{
            cell=[tableView dequeueReusableCellWithIdentifier:LoadingIdentifier];
            if (cell == nil) {
                cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadingIdentifier];
                UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, 4.0f, tableView.bounds.size.width-20.0f, 34.0f)];
                titleLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
                titleLabel.backgroundColor=[UIColor clearColor];
                titleLabel.tag=99;
                titleLabel.textColor=[UIColor colorWithWhite:55.0f/255.0f alpha:1.0f];
                titleLabel.font=[UIFont boldSystemFontOfSize:18.0f];
                titleLabel.textAlignment=NSTextAlignmentCenter;
                [cell.contentView addSubview:titleLabel];
                
                UIActivityIndicatorView *activityIndicatorView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                cell.accessoryView=activityIndicatorView;
                activityIndicatorView.hidesWhenStopped=YES;
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            UILabel *titleLabel=(UILabel *)[cell.contentView viewWithTag:99];
            UIActivityIndicatorView *activityIndicatorView=(UIActivityIndicatorView *)cell.accessoryView;
            if (self.isLoading) {
                titleLabel.text=@"載入中";
                [activityIndicatorView startAnimating];
            }else{
                titleLabel.text=@"查無資料";
                [activityIndicatorView stopAnimating];
            }
        }
            break;
    }
    return cell;
}

#pragma mark - LoadMore Template method
//手指離開屏幕後ScrollView還會繼續滾動一段時間只到停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    /*
     * @ 在這裡觸發計算是否捲到頂端或底部
     */
    CGPoint _scrollViewContentOffset     = scrollView.contentOffset;
    CGRect _scrollViewBounds             = scrollView.bounds;
    CGSize _scrollViewContentSize        = scrollView.contentSize;
    UIEdgeInsets _scrollViewContentInset = scrollView.contentInset;
    float y = _scrollViewContentOffset.y + _scrollViewBounds.size.height - _scrollViewContentInset.top;
    
    float h = _scrollViewContentSize.height;
    float _loadDistance = 0.0f;
    
    //捲動到了頂端 ( Scroll to Top )
    if( _scrollViewContentOffset.y <= 0.0f )
    {
        
    }
    //捲動到了底部 ( Scroll to Bottom )
    if( y >= h + _loadDistance && _scrollViewContentOffset.y > 0.0f )
    {
        if (self.hasMore) {
            //產生 載入中 的暫存 cell
            self.currentPageNo++;
            self.isLoading=YES;
            [self.tableview reloadData];
            [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            [NSThread detachNewThreadSelector:@selector(getDataListThread) toTarget:self withObject:nil];
        }
    }
    
}

-(void)reLoadTableView{
    self.isLoading=NO;
    [self.tableview reloadData];
    //    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableview];
}










- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
