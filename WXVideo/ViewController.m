

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong) CAShapeLayer *pullToRefreshShape;
@property (strong) CAShapeLayer *pullToRefreshShape2;

@property (strong) UIView *loadingIndicator;
@property (assign) BOOL isLoading;
@property (strong) NSMutableArray *primes;

@property(nonatomic,strong)dispatch_source_t timer;


@end

@implementation ViewController{

    CGMutablePathRef path1;
    UIImageView *imgview;
    UIImageView *sonImage;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.primes = [[NSMutableArray alloc]init];
    
    self.loadingIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, -70, 414, 70)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    imgview = [[UIImageView alloc]initWithFrame:CGRectMake(75, 0, 70, 70)];
    sonImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    sonImage.image = [UIImage imageNamed:@"圆环"];
    sonImage.hidden = YES;
    [imgview addSubview:sonImage];
    [self.loadingIndicator addSubview:imgview];

    self.isLoading = YES;
    [self setupLoadingIndicator];
    
    [self.pullToRefreshShape addAnimation:[self pullDownAnimation]
                                   forKey:@"Write 'Load' as you drag down"];
    [self.pullToRefreshShape2 addAnimation:[self pullDownAnimation]
                                    forKey:@"Write 'Load' as you drag down"];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    _loadingIndicator.backgroundColor = [UIColor lightGrayColor];
    [self.tableView addSubview:_loadingIndicator];
    
    [self loadData];

}
- (void)setupLoadingIndicator{
    self.pullToRefreshShape = [CAShapeLayer layer];
    self.pullToRefreshShape.path = [self loadPath2];
    
    self.pullToRefreshShape2 = [CAShapeLayer layer];
    self.pullToRefreshShape2.path = [self loadPath];
    
    NSArray *arr = @[_pullToRefreshShape,_pullToRefreshShape2];
    for (CAShapeLayer *layer in arr) {
        layer.strokeColor = [self colorWithHexString:@"#ffba00" alpha:1].CGColor;
        layer.fillColor   = [UIColor clearColor].CGColor;
        layer.lineCap   = kCALineCapRound;
        layer.lineJoin  = kCALineJoinRound;
        layer.lineWidth = 1.5;
        layer.position = CGPointMake(0, 0);
        layer.strokeEnd = .0;
        [imgview.layer addSublayer:layer];
        layer.speed = 0;

    }
}

/** 16进制色值转换 */
- (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}


- (CGPathRef)loadPath2{
    //正方形
    CGMutablePathRef path2 = CGPathCreateMutable();
    CGPathMoveToPoint(path2, NULL, 27, 27);
    CGPathAddLineToPoint(path2, NULL, 43, 27);
    
    CGPathAddLineToPoint(path2, NULL, 43, 43);
    
    CGPathAddLineToPoint(path2, NULL, 27, 43);
    CGPathAddLineToPoint(path2, NULL, 27, 27);

    
    CGAffineTransform t = CGAffineTransformMakeScale(1, 1);
    return CGPathCreateCopyByTransformingPath(path2, &t);

}
- (CGPathRef)loadPath{
    path1 = CGPathCreateMutable();
    //半圆
    CGPathAddArc(path1, NULL, 35, 35, 30, 1.4 * M_PI, 1.2 * M_PI, NO);
    //拐点
    CGPathMoveToPoint(path1, NULL, 10, 17);
    CGPathAddLineToPoint(path1, NULL, 18, 16);
    CGPathAddLineToPoint(path1, NULL, 19, 12);
    CGPathAddLineToPoint(path1, NULL, 24, 12);
    CGPathAddLineToPoint(path1, NULL, 26, 6);
    
    CGAffineTransform t = CGAffineTransformMakeScale(1, 1);
    return CGPathCreateCopyByTransformingPath(path1, &t);
}


- (void)animation2{
    
    sonImage.hidden = NO;
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    basic.beginTime = 0;
    basic.toValue = @(M_PI *2);
    basic.duration = 1;
    basic.autoreverses = NO;
    basic.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *basic1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    basic1.beginTime = basic.beginTime + basic.duration;
    basic1.fromValue = @(0);
    basic1.toValue = @(M_PI *2);
    basic1.repeatCount = 4;
    basic1.duration = 1;
    basic1.autoreverses = NO;
    basic1.fillMode = kCAFillModeForwards;
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 2;
    group.repeatCount = 2;
    group.animations = @[basic,basic1];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [sonImage.layer addAnimation:group forKey:nil];
    
   }

#pragma mark - Animation setup
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.primes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = self.primes[indexPath.row];
    return cell;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y+scrollView.contentInset.top;
    CGFloat startLoadingThreshold = 80.0;
    CGFloat fractionDragged       = -offset/startLoadingThreshold;
    
    if (offset <= 0.0 && !self.isLoading && [self isViewLoaded]) {
        self.pullToRefreshShape.timeOffset = MIN(1.0, fractionDragged);
        self.pullToRefreshShape2.timeOffset = MIN(1.0, fractionDragged);

        if (fractionDragged > 1.0) {
            [self startLoading];
           
        }
    }
}
- (void)startLoading
{
    [self animation2];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(delayMethod) userInfo:nil repeats:NO];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.isLoading = YES;
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    } completion:^(BOOL finished) {
        [self loadData];
    }];
}

- (void)loadData{
    //环绕的动画
    for (int i = 0;i <= 2 ;i ++) {
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [self.primes addObject:str];
    }
     _isLoading = NO;
    sonImage.hidden = YES;
    [self.tableView reloadData];
    
}

- (void)delayMethod{
    [UIView animateWithDuration: 0.5 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
     }];
}

- (CAAnimation *)pullDownAnimation
{
    CABasicAnimation *writeText = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    writeText.fromValue = @0;
    writeText.toValue = @1;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.0;
    group.animations = @[writeText];
    
    return group;
}





@end
