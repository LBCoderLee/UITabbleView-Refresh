//
//  ViewController.m
//  RefreshTest
//
//  Created by li  bo on 16/6/5.
//  Copyright © 2016年 li  bo. All rights reserved.
//

#import "ViewController.h"
#import "Kobe.h"
#import "KBCell.h"
#import "UIView+LBExtension.h"

@interface ViewController ()

/** 存放模型的数组 */
@property (nonatomic, strong) NSMutableArray *modelsArray;


/** 用来下拉加载新数据的header */
@property (nonatomic, strong) UIButton *headerBtn;
/** 是否正在加载新数据... */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;

/** 菊花 */
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

/** 是否已经向下旋转 */
@property(nonatomic, assign, getter=isRotationDonwn) BOOL rotationDonwn;

/** 是否已经向上旋转 */
@property(nonatomic, assign, getter=isRotationUp) BOOL rotationUp;

@end

@implementation ViewController

#pragma mark - Lazy

//懒加载模型数组
- (NSMutableArray *)modelsArray
{
    if (!_modelsArray) {

       NSString *path  = [[NSBundle mainBundle] pathForResource:@"data.plist" ofType:nil];
       NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];

        NSMutableArray *tempArray = [NSMutableArray array];

        for (NSDictionary *dict in dictArray) {
            Kobe *kb = [Kobe KobeWithDict:dict];
            [tempArray addObject:kb];
        }
        _modelsArray = tempArray;

    }
    return _modelsArray;
}

//懒加载下拉刷新控件
- (UIButton *)headerBtn
{
    if (!_headerBtn) {

        CGFloat height = 50;
        // 下拉加载新数据的控件
        UIButton *hearBtn = [[UIButton alloc] init];

        [hearBtn setTitle:@"下拉刷新" forState:UIControlStateNormal];

        [hearBtn setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];

        [hearBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];


        hearBtn.lb_width = self.tableView.lb_width;
        hearBtn.lb_height = height;
        hearBtn.lb_y = - hearBtn.lb_height;

        hearBtn.alpha = 0.0;

        hearBtn.imageView.autoresizingMask = UIViewAutoresizingNone;

        hearBtn.titleEdgeInsets = UIEdgeInsetsMake(0, height, 0, 0);
        _headerBtn = hearBtn;

        [self.tableView addSubview:hearBtn];


    }
    return _headerBtn;
}

//懒加载刷新菊花控件
- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.hidesWhenStopped = YES;

        _loadingView = loadingView;
        _loadingView.lb_centerX= self.headerBtn.imageView.lb_centerX-10;
        _loadingView.lb_centerY= self.headerBtn.imageView.lb_centerY-10;
        self.loadingView.lb_width= 40;
        self.loadingView.lb_height= 40;

        [self.headerBtn addSubview:_loadingView ];
    }
    return _loadingView;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTableView];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSLog(@"一开始下拉刷新控件的frame=%@",NSStringFromCGRect(self.headerBtn.frame));
    NSLog(@"一开始tableView的内边距=%@",NSStringFromUIEdgeInsets(self.tableView.contentInset));
    NSLog(@"一开始tableView的偏移量Y值=%f",self.tableView.contentOffset.y);
}



#pragma mark - 初始化TableView

- (void)setupTableView
{
    //设置行高
    self.tableView.rowHeight = 70;
    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([KBCell class]) bundle:nil] forCellReuseIdentifier:[KBCell reuseName]];

}


/**
 *  停止拖拽
 */

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 如果正在刷新, 直接返回
    if (self.isHeaderRefreshing) return;

    // 当偏移量 <= offsetY时(注意正负值), 刷新header就完全出现
    CGFloat offsetY = - (self.tableView.contentInset.top + self.headerBtn.lb_height);
    [self.loadingView stopAnimating];
    self.headerBtn.imageView.hidden = NO;
    if (self.tableView.contentOffset.y <= offsetY) { // 刷新header完全出现了
        // 进入刷新状态
        [self headerBeginRefresh];
    }
}


#pragma mark - 滚动tabbleview，实时处理header状态
/**
 * 只要滚动tabbleview就会调用
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 实时更新Header的状态
    [self updateHeader:scrollView];


}

- (void)updateHeader:(UIScrollView *)sc
{
    // header还没有被创建, 直接返回
    if (self.headerBtn == nil) return;

    // 如果正在刷新, 直接返回
    if (self.isHeaderRefreshing) return;
    [UIView animateWithDuration:.25f animations:^{

        //这里刷新控件一开始是透明度为0的，随着用户向下拖拽，偏移量的绝对值慢慢变大
        //偏移量一开始就是64，随着它的绝对值与64的差值越来越大，刷新控件的透明度也越来越大
        //这里的40只是一个比较值，你可以随意指定，定的太大，刷新控件需要使劲向下拖，那么透明度才会慢慢变大，如果定的比较小，那么刚一向下拖，刷新控件透明度就会很明显
        self.headerBtn.alpha = ((ABS(sc.contentOffset.y) - 64) / 40);
    }];
    // 当偏移量 <= offsetY时, 刷新header就完全出现
    CGFloat offsetY = - (self.tableView.contentInset.top + self.headerBtn.lb_height);

    if (self.tableView.contentOffset.y <= offsetY) { // 刷新header完全出现了，改变文字，箭头旋转

        [self.headerBtn setTitle:@"释放更新" forState:UIControlStateNormal];
        if (self.isRotationDonwn == YES && self.isRotationUp == NO) {//这个判断是防止箭头一直不停旋转

            [UIView animateWithDuration:.25f animations:^{

                //需要注意，这里之所以用(0.000001 - M_PI),是因为transform动画旋转会选择最近的路径进行旋转，默认是顺时针，如果直接选择- M_PI，那么箭头只会顺时针选择，不会逆时针选择
                // 使用了(0.000001 - M_PI)，那么它会选择近的路径旋转，就不会顺时针旋转了
                //大部分APP的下拉刷新基本都是箭头逆时针回旋，并不是一直顺时针旋转
                CGFloat angle = 0.000001 - M_PI  ;
                self.headerBtn.imageView.transform=CGAffineTransformMakeRotation(angle);


            }];
        }

        self.rotationDonwn = NO;
        self.rotationUp =YES;

    } else {// 刷新header没有完全出现，箭头恢复默认方向

        if (self.isRotationDonwn == NO && self.isRotationUp == YES) {//这个判断是防止箭头一直不停旋转

            [UIView animateWithDuration:.25f animations:^{
                self.headerBtn.imageView.transform = CGAffineTransformIdentity;

            }];
        }
        self.rotationDonwn = YES;
        self.rotationUp = NO;
        [self.headerBtn setTitle:@"下拉刷新" forState:UIControlStateNormal];
        //  self.headerBtn.backgroundColor = [UIColor redColor];
    }
}

#pragma mark - 开始刷新
- (void)headerBeginRefresh
{
    //如果当前正在刷新，那么不往下继续执行
    if (self.isHeaderRefreshing) return;
    //否则，进入刷新状态
    self.headerRefreshing = YES;

    //显示菊花
    self.loadingView.alpha = 1.0;
    [self.loadingView startAnimating];

    [self.headerBtn setTitle:@"加载中..." forState:UIControlStateNormal];

    self.headerBtn.imageView.transform = CGAffineTransformIdentity;
    self.headerBtn.imageView.hidden = YES;

    // 显示加载中...，这个时候这个刷新控件是会自己悬浮在导航栏下面，不需要人为拽着不松手
    //这个效果，我们可以通过增大tabbleview的内边距来达到这个效果
    [UIView animateWithDuration:0.25f animations:^{

        //因为刷新控件的y值就是-50，它自己高度也是50，所以只需要让tabbleview内边距向下走50，那么刷新控件就会完全显示了
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top += self.headerBtn.lb_height;

        self.tableView.contentInset = inset;

        
    }];
    //由于是模拟发送网络请求，所以延迟1.5秒后再去加载数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        // 发送请求给服务器
        [self loadNewData];
    });
}

#pragma mark - 发送请求给服务器，请求成功加载新的数据
- (void)loadNewData
{
    Kobe *kbOne = [[Kobe alloc] init];
    kbOne.name = @"科比";
    kbOne.imageName = @"Snip20160515_89";
    kbOne.index = 0;

    Kobe *kbTwo = [[Kobe alloc] init];
    kbTwo.name = @"库里";
    kbTwo.imageName = @"Snip20160515_87";
    kbTwo.index = 1;

    //我们这里是模拟发送请求，添加的是假数据哦，不过添加方式都是按照企业开发的步骤来的
    NSArray *addModel = @[kbOne,kbTwo];
    NSRange range=NSMakeRange(0, addModel.count);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.modelsArray insertObjects:addModel atIndexes:indexSet];

    //给模型添加数据后，一定要重新刷新表格，这样tabbleview才会重新调用数据源的方法，才会把新添加的数据显示出来
    [self.tableView reloadData];

    //添加完毕结束刷新
    [self headerEndRefresh];


}

#pragma mark - 结束刷新
- (void)headerEndRefresh
{
    self.headerRefreshing = NO;
    self.headerBtn.hidden = YES;

    // 减小内边距
    // 刷新已经停止，不需要刷新控件显示在用户能看到的范围，所以需要减少tabbleview的内边距
    [UIView animateWithDuration:0.25 animations:^{

        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top -= self.headerBtn.lb_height;
        self.tableView.contentInset = inset;

    }completion:^(BOOL finished) {//刷新控件缩回到用户看不到的位置后，更新刷新控件以及内部子控件的状态
        self.headerBtn.hidden = NO;
        self.loadingView.alpha = 0.0;
        [self.loadingView stopAnimating];
    }];


}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.modelsArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    KBCell *cell = [tableView dequeueReusableCellWithIdentifier:[KBCell reuseName]];


    Kobe *kbModel = self.modelsArray[indexPath.row];
    kbModel.index = indexPath.row;

    cell.kbModel = kbModel;

    return cell;
}

#pragma mark - Set Tableview's Separator
//设置tableview的分割线没有开头的间距
- (void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }

    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
@end
