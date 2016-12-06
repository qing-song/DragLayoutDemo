//
//  ViewController.m
//  DragLayoutDemo
//
//  Created by qs's MacAir on 16/12/6.
//  Copyright © 2016年 qingsong. All rights reserved.
//

#import "ViewController.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
<UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
{
    CGFloat _maxContentOffSet_Y;
}

@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UILabel       *headLab;
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) UIWebView     *webView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"仿淘宝上拉进入详情页交互的实现";
    
    _maxContentOffSet_Y = 40;
    
    [self loadContentView];
}

- (void)loadContentView
{
    self.contentView = [[UIView alloc] init];
    self.contentView.frame = self.view.bounds;
    [self.view addSubview:self.contentView];
    
    // first view
    [self.contentView addSubview:self.tableView];
    
    // second view
    [self.contentView addSubview:self.webView];
    
    UILabel *hv = self.headLab;
    // headLab
    [self.webView addSubview:hv];
    [self.headLab bringSubviewToFront:self.contentView];
    
    // 开始监听_webView.scrollView的偏移量
    [self.webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}



#pragma mark ---- scrollView delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if([scrollView isKindOfClass:[UITableView class]]) // tableView界面上的滚动
    {
        // 能触发翻页的理想值:tableView整体的高度减去屏幕本省的高度
        CGFloat valueNum = _tableView.contentSize.height -ScreenHeight;
        if ((offsetY - valueNum) > _maxContentOffSet_Y)
        {
            [self goToDetailAnimation]; // 进入图文详情的动画
        }
    }
    
    else // webView页面上的滚动
    {
        NSLog(@"-----webView-------");
        if(offsetY<0 && -offsetY>_maxContentOffSet_Y)
        {
            [self backToFirstPageAnimation]; // 返回基本详情界面的动画
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if(object == _webView.scrollView && [keyPath isEqualToString:@"contentOffset"])
    {
        [self headLabAnimation:[change[@"new"] CGPointValue].y];
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 头部提示文本动画
- (void)headLabAnimation:(CGFloat)offsetY
{
    _headLab.alpha = -offsetY/60;
    _headLab.center = CGPointMake(ScreenWidth/2, -offsetY/2.f);
    // 图标翻转，表示已超过临界值，松手就会返回上页
    if(-offsetY>_maxContentOffSet_Y){
        _headLab.textColor = [UIColor redColor];
        _headLab.text = @"释放，返回详情";
    }else{
        _headLab.textColor = [UIColor blueColor];
        _headLab.text = @"上拉，返回详情";
    }
}

// 进入详情的动画
- (void)goToDetailAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _webView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _tableView.frame = CGRectMake(0, -self.contentView.bounds.size.height, ScreenWidth, self.contentView.bounds.size.height);
    } completion:^(BOOL finished) {
        
    }];
}


// 返回第一个界面的动画
- (void)backToFirstPageAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _tableView.frame = CGRectMake(0, 0, ScreenWidth, self.contentView.bounds.size.height);
        _webView.frame = CGRectMake(0, _tableView.contentSize.height, ScreenWidth, ScreenHeight);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (UILabel *)headLab
{
    if(!_headLab){
        _headLab = [[UILabel alloc] init];
        _headLab.text = @"上拉，返回详情";
        _headLab.textAlignment = NSTextAlignmentCenter;
    }
    
    _headLab.frame = CGRectMake(0, 0, ScreenWidth, 40.f);
    _headLab.alpha = 0.f;
    
    return _headLab;
}


- (UITableView *)tableView
{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.contentView.bounds.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 40.f;
        UILabel *tabFootLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
        tabFootLab.text = @"继续拖动，查看图文详情";
        tabFootLab.textAlignment = NSTextAlignmentCenter;
        _tableView.tableFooterView = tabFootLab;
    }
    return _tableView;
}

- (UIWebView *)webView
{
    if(!_webView){
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _tableView.contentSize.height, ScreenWidth, ScreenHeight)];
        _webView.delegate = self;
        _webView.scrollView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.jianshu.com/p/876a9b8fd6ac"]]];
    }
    
    return _webView;
}

#pragma mark - UITaleViewDelegate and UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%zd", indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
