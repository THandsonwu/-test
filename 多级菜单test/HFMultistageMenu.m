//
//  HFMultistageMenu.m
//  三级菜单
//
//  Created by chinatsp on 16/7/20.
//  Copyright © 2016年 HandsonWu. All rights reserved.
//

#import "HFMultistageMenu.h"

@implementation HFIndexPath

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row
{
    if(self = [super init])
    {
        _column = column;
        _row = row;
        _item = -1;
    
    }
    return self;
}

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item
{
    self = [self initWithColumn:column row:row ];
    if(self)
    {
        _item = item;
    }
    return self;
}

+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row
{
    return [[self alloc] initWithColumn:column row:row];
}

+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item
{
    return [[self alloc] initWithColumn:column row:row item:item];
}


@end



@implementation HFMenuBackgroundView

- (void)drawRect:(CGRect)rect
{
    // 获取画布上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画一条底部线
    CGContextSetRGBStrokeColor(context, 219.0/255, 224.0/255, 228.0/255, 1);//线条颜色
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width,0);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width,rect.size.height);
    CGContextStrokePath(context);

}

@end
#pragma mark--------- HFMultistageMenu implementation

@interface HFMultistageMenu ()
{
    struct {
        unsigned int numberOfRowsInColumn         : 1;
        unsigned int numberOfItemsInRow           : 1;
        unsigned int titleForRowAtIndexPath       : 1;
        unsigned int titleForItemsInRowAtIndexPath: 1;
        unsigned int imageNameForRowAtIndexPath : 1;
        unsigned int imageNameForItemsInRowAtIndexPath : 1;
        unsigned int detailTextForRowAtIndexPath: 1;
        unsigned int detailTextForItemsInRowAtIndexPath: 1;
    
    }dataSourceStatus;
}

@property (nonatomic, assign) NSInteger currentSelectedMenuColumn;  // 当前选中列
@property (nonatomic, assign) NSInteger currentSelectedMenuRow;     // 当前选中行
@property (nonatomic, assign) NSInteger currentSelectedMenuItem;    //当前选中的二级菜单
@property (nonatomic, assign) NSInteger currentSelectedMenuSubItem; //当前选中的三级菜单

@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) NSInteger numOfMenu;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UITableView *stairTableView;   // 一级列表
@property (nonatomic, strong) UITableView *secondaryTableView;  // 二级列表

@property (nonatomic, strong) UITableView *threeLevelTableView;  // 三级列表

@property (nonatomic, strong) UIImageView *buttomImageView; // 底部imageView
@property (nonatomic, weak) UIView *bottomShadow;

//data source
@property (nonatomic, copy) NSArray *array;

//layers array
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *arrowKeys;
@property (nonatomic, copy) NSArray *bgLayers;

@end

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define kTableViewCellHeight 44
#define kTableViewHeight 300
#define kButtomImageViewHeight 21

#define HFColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 16))/255.0 blue:((float)((rgbValue & 0x0000FF) >> 16))/255.0 alpha:1] \

#define kNormalTextColor HFColorFromRGB(0x222222)

#define kDetailTextColor [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1]

#define kSeparatorColor [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1]
#define kCellBgColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]

#define kSelectTextColor HFColorFromRGB(0xFF4664)

@implementation HFMultistageMenu
{
    CGFloat _tableViewHeight;
}


#pragma mark-----lazy 加载

- (UIColor *)arrowKeyColor
{
    if(!_arrowKeyColor)
    {
        _arrowKeyColor = [UIColor blackColor];
    }
    return _arrowKeyColor;

}

- (UIColor *)normalTextColor
{
    if(!_normalTextColor)
    {
        _normalTextColor = [UIColor blackColor];
    }
    return _normalTextColor;
}

- (UIColor *)separatorColor
{
    if(!_separatorColor)
    {
        _separatorColor = [UIColor blackColor];
    }
    return _separatorColor;

}


#pragma mark-----methods

- (void)selectDefaultIndexPath
{
    [self selectIndexPath:[HFIndexPath indexPathWithColumn:0 row:0]];
}

- (NSString *)titleForRowAtIndexPath:(HFIndexPath *)indexPath
{
    return [self.dataSource menu:self titleForRowAtIndexPath:indexPath];
}
- (void)selectIndexPath:(HFIndexPath *)indexPath triggerDelegate:(BOOL)trigger
{
    if (!_dataSource || !_delegate
        || ![_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
        return;
    }
    
    if (dataSourceStatus.numberOfRowsInColumn <= indexPath.column || [_dataSource menu:self numberOfRowsInColumn:indexPath.column] <= indexPath.row) {
        return;
    }
    CATextLayer *title = (CATextLayer *)_titles[indexPath.column];
    if(indexPath.item < 0)
    {
        if(!_isResponseSecondaryMenu && [_dataSource menu:self numberOfItemsInRow:indexPath.row column:indexPath.column] > 0)
        {
            title.string = [_dataSource menu:self titleForItemsInRowAtIndexPath:[HFIndexPath indexPathWithColumn:indexPath.column row:self.isReMainMenuTitle ? 0 : indexPath.row item:0]];
            if(trigger)
            {
                [_delegate menu:self didSelectRowAtIndexPath:[HFIndexPath indexPathWithColumn:indexPath.column row:indexPath.row item:0]];
            }
        
        }
        else
        {
            title.string = [_dataSource menu:self titleForRowAtIndexPath:[HFIndexPath indexPathWithColumn:indexPath.column row:self.isReMainMenuTitle ? 0 : indexPath.row]];
        
        }
        if(_restoreDefaultsArray.count > indexPath.column)
        {
            _restoreDefaultsArray[indexPath.column] = @(indexPath.row);
        }
        CGSize size = [self calculateTitleSizeWithString:title.string];
        CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
        title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
        
    }
    else if ([_dataSource menu:self numberOfItemsInRow:indexPath.row column:indexPath.column] > indexPath.column)
    {
        title.string = [_dataSource menu:self titleForRowAtIndexPath:indexPath];
        if(trigger)
        {
            [_delegate menu:self didSelectRowAtIndexPath:indexPath];
        }
        if(_restoreDefaultsArray.count > indexPath.column)
        {
            _restoreDefaultsArray[indexPath.column] = @(indexPath.row);
        }
        CGSize size = [self calculateTitleSizeWithString:title.string];
        CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
        title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    
    }
    


}

- (void)selectIndexPath:(HFIndexPath *)indexPath
{
    [self selectIndexPath:indexPath triggerDelegate:YES];
}

- (void)reloadData
{
    [self animateBackGroundView:_backGroundView show:NO complete:^{
        [self animateTableView:nil show:NO complete:^{
            _show = NO;
            id VC = self.dataSource;
            self.dataSource = nil;
            self.dataSource = VC;
        }];
    }];
}

#pragma mark------setter
- (void)setDataSource:(id<HFMultistageMenuDataSource>)dataSource
{
    if(_dataSource == dataSource) return;
    
    _dataSource = dataSource;
    
    //setup view
    if([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)])
    {
        _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    }
    else
    {
        _numOfMenu = 1;
    }
    
    _restoreDefaultsArray = [NSMutableArray arrayWithCapacity:_numOfMenu];
    
    for (NSInteger index = 0; index < _numOfMenu; ++index) {
        [_restoreDefaultsArray addObject:@0];
    }
    
    dataSourceStatus.numberOfRowsInColumn = [_dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)];
    dataSourceStatus.numberOfItemsInRow = [_dataSource respondsToSelector:@selector(menu:numberOfItemsInRow:column:)];
    
    dataSourceStatus.titleForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)];
    dataSourceStatus.titleForItemsInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForItemsInRowAtIndexPath:)];
    
    dataSourceStatus.imageNameForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:imageNameForRowAtIndexPath:)];
    dataSourceStatus.imageNameForItemsInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:imageNameForItemsInRowAtIndexPath:)];
    
    dataSourceStatus.detailTextForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:detailTextForRowAtIndexPath:)];
    dataSourceStatus.detailTextForItemsInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:detailTextForItemsInRowAtIndexPath:)];
    
    _bottomShadow.hidden = NO;
    CGFloat textLayerInterval = self.frame.size.width / (_numOfMenu * 2);
    CGFloat separatorLineInterval = self.frame.size.width / _numOfMenu;
    CGFloat bgLayerInterval = self.frame.size.width / _numOfMenu;
    
    NSMutableArray *tempTitles = [NSMutableArray arrayWithCapacity:_numOfMenu];
    NSMutableArray *tempArrowKeys =[NSMutableArray arrayWithCapacity:_numOfMenu];
    NSMutableArray *tempBgLayers = [NSMutableArray arrayWithCapacity:_numOfMenu];
    
    for (int i = 0; i < _numOfMenu; i++) {
        //bgLayer
        CGPoint bgLayerPosition = CGPointMake((i + 0.5)*bgLayerInterval, self.frame.size.height/2);
        CALayer *bgLayer = [self createMenuLayerWithColor:[UIColor whiteColor] andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer];
        
        //title
        CGPoint titlePosition = CGPointMake((i * 2 +1) * textLayerInterval, self.frame.size.height / 2);
        NSString *titleString;
        if(self.isResponseSecondaryMenu && dataSourceStatus.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:0 column:i] >0 )
        {
            titleString = [_dataSource menu:self titleForItemsInRowAtIndexPath:[HFIndexPath indexPathWithColumn:i row:0 item:0]];
        
        }
        else
        {
            titleString = [_dataSource menu:self titleForRowAtIndexPath:[HFIndexPath indexPathWithColumn:i row:0]];
        }
        
        CATextLayer * title = [self createTextLayerWithNSString:titleString withColor:self.normalTextColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [tempTitles addObject:title];
        
        //arrowKeys
        CGPoint arrowPosition = CGPointMake((i + 1)*separatorLineInterval - 10, self.frame.size.height / 2);
        CAShapeLayer *arrowKey = [self createArrowKeyWithColor:self.arrowKeyColor andPosition:arrowPosition];
        [self.layer addSublayer:arrowKey];
        [tempArrowKeys addObject:arrowKey];
        
        //separator
        
        if(i != _numOfMenu - 1)
        {
            CGPoint separatorPosition = CGPointMake(ceilf((i + 1) * separatorLineInterval - 1) , self.frame.size.height / 2);
            CAShapeLayer *separator = [self createSeparatorLineWithColor:self.separatorColor andPosition:separatorPosition];
            [self.layer addSublayer:separator];
            
        }
        
    }
    
    _titles = [tempTitles copy];
    _arrowKeys = [tempArrowKeys copy];
    _bgLayers = [tempBgLayers copy];

}


#pragma mark-----init method

- (instancetype)initWithMenuOrigin:(CGPoint)origin menuHeight:(CGFloat)height
{
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, SCREEN_WIDTH, height)];
    if(self)
    {
        _origin = origin;
        _currentSelectedMenuColumn = -1;
        _show = NO;
        _sytemFontSize = 14;
        _cellStyle = UITableViewCellStyleValue1;
        _separatorColor = kSeparatorColor;
        _normalTextColor = self.normalTextColor ? self.normalTextColor : kNormalTextColor;
        _selectTextColor = self.selectTextColor ? self.selectTextColor : kSelectTextColor;
        _detailTextFont = [UIFont systemFontOfSize:11];
        _detailTextColor = self.detailTextColor ? self.detailTextColor : kDetailTextColor;
        _arrowKeyColor = self.arrowKeyColor ? self.arrowKeyColor : kNormalTextColor;
        _tableViewHeight = kTableViewHeight;
        _isResponseSecondaryMenu = YES;
        //stairTableView init
        _stairTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, CGRectGetMaxY(self.frame), SCREEN_WIDTH/2, 0) style:UITableViewStylePlain];
        
        _stairTableView.rowHeight = kTableViewCellHeight;
        _stairTableView.dataSource = self;
        _stairTableView.delegate = self;
        _stairTableView.separatorColor = kSeparatorColor;
        _stairTableView.separatorInset = UIEdgeInsetsZero;
        
        //secondaryTableView init
        _secondaryTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x + self.frame.size.width / 2, CGRectGetMaxY(self.frame), SCREEN_WIDTH/2, 0) style:UITableViewStylePlain];
        
        _secondaryTableView.rowHeight = kTableViewCellHeight;
        _secondaryTableView.dataSource = self;
        _secondaryTableView.delegate = self;
        _secondaryTableView.separatorColor = kSeparatorColor;
        _secondaryTableView.separatorInset = UIEdgeInsetsZero;
        
        
        _buttomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(origin.x, CGRectGetMaxY(self.frame), SCREEN_WIDTH, kButtomImageViewHeight)];
        _buttomImageView.image = [UIImage imageNamed:@"icon_chose_bottom"];
        
        
        //self setup
        
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuClick:)];
        [self addGestureRecognizer:tapGesture];
        
        //background setup
        
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        
        UITapGestureRecognizer *backTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundClick:)];
        [self addGestureRecognizer:tapGesture];
        
        [_backGroundView addGestureRecognizer:backTapGesture];
        
        
        //bottom shadow
        
        UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height -0.5, SCREEN_WIDTH, 0.5)];
        
        bottomShadow.backgroundColor = kSeparatorColor;
        bottomShadow.hidden = YES;
        [self addSubview:bottomShadow];
        _bottomShadow = bottomShadow;
        
    }
    return self;
    
}

#pragma mark------init support

- (CALayer *)createMenuLayerWithColor:(UIColor *)color andPosition:(CGPoint)position
{
    CALayer *layer = [CALayer layer];
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, self.frame.size.width/self.numOfMenu, self.frame.size.height-1);
    layer.backgroundColor = color.CGColor;
    
    return layer;

}

- (CAShapeLayer *)createArrowKeyWithColor:(UIColor *)color andPosition:(CGPoint)point
{
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 0.8;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    
    return layer;
}

- (CAShapeLayer *)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(160,0)];
    [path addLineToPoint:CGPointMake(160, 20)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point {
    
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = _sytemFontSize;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.truncationMode = kCATruncationEnd;
    layer.foregroundColor = color.CGColor;
    
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = point;
    
    return layer;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:_sytemFontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

#pragma mark-----tap action

- (void)menuClick:(UITapGestureRecognizer *)sender
{
    if(!_dataSource) return;
    
    CGPoint touchPoint = [sender locationInView:self];
    
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / _numOfMenu);
    
    for (int i = 0; i < _numOfMenu; i++) {
        if(i != tapIndex)
        {
            [self animationArrowKey:_arrowKeys[i] forward:NO complete:^{
                [self animateTitle:_titles[i] show:NO complete:^{
                }];
            }];
        }
    }
    
    if(tapIndex == _currentSelectedMenuColumn && _show)
    {
        [self animateArrowKey:_arrowKeys[_currentSelectedMenuColumn] background:_backGroundView tableView:_stairTableView title:_titles[_currentSelectedMenuColumn] forward:NO complecte:^{
            _currentSelectedMenuColumn = tapIndex;
            _show = NO;
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(menu:didTouched:)])
            {
                [self.delegate menu:self didTouched:_show];
            }
        }];
    
    }
    else
    {
        _currentSelectedMenuColumn = tapIndex;
        [_stairTableView reloadData];
        if(_dataSource && dataSourceStatus.numberOfItemsInRow)
        {
            [_secondaryTableView reloadData];
        }
      
        [self animateArrowKey:_arrowKeys[tapIndex] background:_backGroundView tableView:_stairTableView title:_titles[tapIndex] forward:YES complecte:^{
            _show = YES;
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(menu:didTouched:)])
            {
                [self.delegate menu:self didTouched:_show];
            }
        }];
    
    }

}

- (void)backgroundClick:(UITapGestureRecognizer *)sender
{
    [self animateArrowKey:_arrowKeys[_currentSelectedMenuColumn] background:_backGroundView tableView:_stairTableView title:_titles[_currentSelectedMenuColumn] forward:NO complecte:^{
        _show = NO;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(menu:didTouched:)])
        {
            [self.delegate menu:self didTouched:_show];
        }
    }];
    [(CALayer *)self.bgLayers[_currentSelectedMenuColumn] setBackgroundColor:[UIColor whiteColor].CGColor];
    
}

#pragma mark-----animations method

- (void)animationArrowKey:(CAShapeLayer *)arrowKey forward:(BOOL)forward complete:(void(^)())complete
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [arrowKey addAnimation:anim forKey:anim.keyPath];
    } else {
        [arrowKey addAnimation:anim forKey:anim.keyPath];
        [arrowKey setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    if (forward) {
        // 展开菜单
        arrowKey.fillColor = _selectTextColor.CGColor;
    } else {
        // 收起菜单
        arrowKey.fillColor = _normalTextColor.CGColor;
    }
    
    complete();

}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show)
    {
        CGRect frame = [self convertRect:self.bounds toView:self.superview ];
        CGRect frame2 = view.frame;
        frame2.origin.y = frame.origin.y;
        view.frame = frame2;
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateTableView:(UITableView *)tableView show:(BOOL)show complete:(void(^)())complete {
    
    BOOL haveItems = NO;
    
    if (_dataSource) {
        NSInteger num = [_stairTableView numberOfRowsInSection:0];
        
        for (NSInteger i = 0; i<num;++i) {
            if (dataSourceStatus.numberOfItemsInRow
                && [_dataSource menu:self numberOfItemsInRow:i column:_currentSelectedMenuColumn] > 0) {
                haveItems = YES;
                break;
            }
        }
    }
  
    if (show)
    {
        if (haveItems) {
            _stairTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width/2, 0);
            _secondaryTableView.frame = CGRectMake(self.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height, self.frame.size.width/2, 0);
            [self.superview addSubview:_stairTableView];
            [self.superview addSubview:_secondaryTableView];
        } else {
            _stairTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            _secondaryTableView.frame = CGRectMake(self.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height, self.frame.size.width/2, 0);
            [self.superview addSubview:_stairTableView];
            
        }
        _buttomImageView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, kButtomImageViewHeight);
        [self.superview addSubview:_buttomImageView];
        
        NSInteger num =  MAX([_stairTableView numberOfRowsInSection:0], [_secondaryTableView numberOfRowsInSection:0]) ;
        CGFloat tableViewHeight = num * kTableViewCellHeight > kTableViewHeight+1 ? kTableViewHeight:num*kTableViewCellHeight+1;
        
        [UIView animateWithDuration:0.2 animations:^{
         if (haveItems)
            {
                _stairTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width/2, tableViewHeight);
                
                _secondaryTableView.frame = CGRectMake(self.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height, self.frame.size.width/2, tableViewHeight);
            } else {
                _stairTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, tableViewHeight);
            }
            _buttomImageView.frame = CGRectMake(self.origin.x, CGRectGetMaxY(_stairTableView.frame)-2, self.frame.size.width, kButtomImageViewHeight);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
          if (haveItems)
            {
                _stairTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width/2, 0);
                
                _secondaryTableView.frame = CGRectMake(self.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height, self.frame.size.width/2, 0);
            }
            else
            {
                _stairTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            }
            _buttomImageView.frame = CGRectMake(self.origin.x, CGRectGetMaxY(_stairTableView.frame)-2, self.frame.size.width, kButtomImageViewHeight);
        } completion:^(BOOL finished) {
            if (_secondaryTableView.superview) {
                [_secondaryTableView removeFromSuperview];
            }
            [_stairTableView removeFromSuperview];
            [_buttomImageView removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(void(^)())complete
{
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    if (!show) {
        title.foregroundColor = _normalTextColor.CGColor;
    } else {
        title.foregroundColor = _selectTextColor.CGColor;
    }
    complete();
}

- (void)animateArrowKey:(CAShapeLayer *)arrowKey background:(UIView *)background tableView:(UITableView *)tableView title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{
    
    [self animationArrowKey:arrowKey forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateTableView:tableView show:forward complete:^{
                }];
            }];
        }];
    }];
    complete();
}

#pragma mark------ tableView  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSAssert(_dataSource != nil, @"menu's dataSource shouldn't be nil");
    if(_stairTableView == tableView)
    {
        if(dataSourceStatus.numberOfRowsInColumn)
        {
            return [_dataSource menu:self numberOfRowsInColumn:_currentSelectedMenuColumn];
        }
        else
        {
            NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
            return 0;
        }
    }
    else
    {
        if(dataSourceStatus.numberOfItemsInRow)
        {
            return [_dataSource menu:self numberOfItemsInRow:_currentSelectedMenuRow column:_currentSelectedMenuColumn];
        
        }
        else
        {
            NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
            return 0;
        }
    
    }
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"HFCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        HFMenuBackgroundView *bg = [[HFMenuBackgroundView alloc] init];
        bg.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = bg;
        cell.textLabel.highlightedTextColor = kSelectTextColor;
        cell.textLabel.textColor = kNormalTextColor;
    }
    NSAssert(_dataSource != nil, @"menu's datasource shouldn't be nil");
    if(tableView == _stairTableView)
    {
        if(dataSourceStatus.titleForRowAtIndexPath)
        {
            cell.textLabel.text = [_dataSource menu:self titleForRowAtIndexPath:[HFIndexPath indexPathWithColumn:_currentSelectedMenuColumn row:indexPath.row]];
        }
        else
        {
            NSAssert(0 == 1, @"dataSource method needs to be implemented");
        }
        
        if([cell.textLabel.text isEqualToString:[(CATextLayer *)[_titles objectAtIndex:_currentSelectedMenuColumn] string]])
        {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        
        if(dataSourceStatus.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:indexPath.row column:_currentSelectedMenuColumn] > 0)
        {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_chose_arrow_nor"] highlightedImage:[UIImage imageNamed:@"icon_chose_arrow_sel"]];
        }
        else
        {
            cell.accessoryView = nil;
        }
        cell.backgroundColor = kCellBgColor;
    
    }
    else
    {
        if(dataSourceStatus.titleForItemsInRowAtIndexPath)
        {
            cell.textLabel.text = [_dataSource menu:self titleForItemsInRowAtIndexPath:[HFIndexPath indexPathWithColumn:_currentSelectedMenuColumn row:_currentSelectedMenuRow item:indexPath.row]];
        }
        else
        {
            NSAssert(0 == 1, @"dataSource method needs to be implemented");
        }
        
        if ([cell.textLabel.text isEqualToString:[(CATextLayer *)[_titles objectAtIndex:_currentSelectedMenuColumn] string]]) {
            [_stairTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectedMenuRow inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            [_secondaryTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectedMenuItem inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];

        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryView = nil;
    
    }
    cell.textLabel.font = [UIFont systemFontOfSize:_sytemFontSize];

    return cell;
}


#pragma mark------ tableView  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _stairTableView)
    {
        BOOL haveItems = [self confiMenuWithSelectRow:indexPath.row];
        BOOL isResponseSecondaryMenu = self.isResponseSecondaryMenu ? YES: haveItems;
        if(isResponseSecondaryMenu && _delegate &&[_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)])
        {
            [self.delegate menu:self didSelectRowAtIndexPath:[HFIndexPath indexPathWithColumn:_currentSelectedMenuColumn row:indexPath.row]];
        }
    }
    else
    {
        [self confiMenuWithSelectItem:indexPath.item];
        if(self.delegate && [_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)])
        {
            [self.delegate menu:self didSelectRowAtIndexPath:[HFIndexPath indexPathWithColumn:_currentSelectedMenuColumn row:_currentSelectedMenuRow item:indexPath.row]];
        }
    }
  
    _show = NO;
    if(self.delegate && [self.delegate respondsToSelector:@selector(menu:didTouched:)])
    {
        [self.delegate menu:self didTouched:_show];
    }
    
}

- (BOOL )confiMenuWithSelectRow:(NSInteger)row
{
    _currentSelectedMenuRow = row;
    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedMenuColumn];
    
    if(dataSourceStatus.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:_currentSelectedMenuRow column:_currentSelectedMenuColumn] > 0)
    {
        if(self.isResponseSecondaryMenu)
        {
            title.string = [_dataSource menu:self titleForRowAtIndexPath:[HFIndexPath indexPathWithColumn:_currentSelectedMenuColumn row:row]];
            [self animateTitle:title show:YES complete:^{
                [_secondaryTableView reloadData];
            }];
        }
        else
        {
            [_secondaryTableView reloadData];
        }
        return NO;
    }
    else
    {
        title.string = [_dataSource menu:self titleForRowAtIndexPath:[HFIndexPath indexPathWithColumn:_currentSelectedMenuColumn row:row]];
        [self animateArrowKey:_arrowKeys[_currentSelectedMenuColumn] background:_backGroundView tableView:_stairTableView title:_titles[_currentSelectedMenuColumn] forward:NO complecte:^{
            _show = NO;
        }];
        return YES;
    }
   
}

- (void)confiMenuWithSelectItem:(NSInteger)item
{
    _currentSelectedMenuItem = item;
    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedMenuColumn];
    
    title.string = [_dataSource menu:self titleForItemsInRowAtIndexPath:[HFIndexPath indexPathWithColumn:_currentSelectedMenuColumn row:_currentSelectedMenuRow item:item]];
      
    [self animateArrowKey:_arrowKeys[_currentSelectedMenuColumn] background:_backGroundView tableView:_stairTableView title:_titles[_currentSelectedMenuColumn] forward:NO complecte:^{
            _show = NO;
    }];
    
    
}

@end
