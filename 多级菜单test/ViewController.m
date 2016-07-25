//
//  ViewController.m
//  多级菜单test
//
//  Created by chinatsp on 16/7/22.
//  Copyright © 2016年 HandsonWu. All rights reserved.
//

#import "ViewController.h"
#import "HFMultistageMenu.h"

@interface ViewController ()<HFMultistageMenuDataSource,HFMultistageMenuDelegate>
@property (nonatomic, strong) NSMutableArray *businessArray;
@property (nonatomic, strong) NSMutableArray *metroArray;
@property (nonatomic, strong) NSMutableArray *onelineArray;
@property (nonatomic, strong) NSMutableArray *twolineArray;
@property (nonatomic, strong) NSMutableArray *threelineArray;
@property (nonatomic, strong) NSMutableArray *fourlineArray;
@property (nonatomic, strong) NSMutableArray *finelineArray;


@property (nonatomic, strong) NSArray *sorts;
@property (nonatomic, strong) NSArray *place;
@property (nonatomic, strong) NSArray *crash;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //数据源
    self.place = @[@"位置",@"地铁",@"商圈"];
    self.crash = @[@"租金"];
    self.sorts = @[@"默认排序",@"离我最近",@"好评优先",@"人气优先",@"最新发布"];
    
    NSString * path =[[NSBundle mainBundle] pathForResource:@"shangquan" ofType:@"plist"];
    NSDictionary *business = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSArray *dataList = business[@"data"][0][@"dictionaryDataList"];
    for (NSDictionary *dict in dataList) {
        NSString *businessName = dict[@"dataName"];
        [self.businessArray addObject:businessName];
        
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"ditie" ofType:@"plist"];
    NSDictionary *metro = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSArray *lines = metro[@"data"];
    for (NSDictionary * dict in lines) {
        NSString *metroName = dict[@"dictName"];
        if([dict[@"dictType"] intValue] ==1)
        {
            
        }
        switch ([dict[@"dictType"] intValue]) {
            case 1:
                for (NSDictionary *station in dict[@"dictionaryDataList"]) {
                    NSString *stationName = station[@"dataName"];
                    [self.onelineArray addObject:stationName];
                }
                break;
            case 2:
                for (NSDictionary *station in dict[@"dictionaryDataList"]) {
                    NSString *stationName = station[@"dataName"];
                    [self.twolineArray addObject:stationName];
                }
                break;
            case 3:
                for (NSDictionary *station in dict[@"dictionaryDataList"]) {
                    NSString *stationName = station[@"dataName"];
                    [self.threelineArray addObject:stationName];
                }
                break;
            case 4:
                for (NSDictionary *station in dict[@"dictionaryDataList"]) {
                    NSString *stationName = station[@"dataName"];
                    [self.fourlineArray addObject:stationName];
                }
                break;
            case 5:
                for (NSDictionary *station in dict[@"dictionaryDataList"]) {
                    NSString *stationName = station[@"dataName"];
                    [self.finelineArray addObject:stationName];
                }
                break;
            default:
                break;
        }
        
        [self.metroArray addObject:metroName];
        
    }
    
    HFMultistageMenu *menu = [[HFMultistageMenu alloc] initWithMenuOrigin:CGPointMake(0, 20) menuHeight:44];
    menu.dataSource = self;
    menu.delegate = self;
    [self.view addSubview:menu];
    [menu selectDefaultIndexPath];

}

#pragma mark----HFMultistageMenuDataSource

- (NSInteger)numberOfColumnsInMenu:(HFMultistageMenu *)menu
{
    return 3;
}

- (NSInteger)menu:(HFMultistageMenu *)menu numberOfRowsInColumn:(NSInteger)column
{
    if(column == 0)
    {
        return self.place.count - 1;
    }
    else if (column == 1)
    {
        return self.crash.count;
    }
    else
    {
        return self.sorts.count;
    }

}

- (NSString *)menu:(HFMultistageMenu *)menu titleForRowAtIndexPath:(HFIndexPath *)indexPath
{
    if (indexPath.column == 0) {
        return self.place[indexPath.row+1];
    } else if (indexPath.column == 1){
        return self.crash[indexPath.row];
    } else {
        return self.sorts[indexPath.row];
    }
}

- (NSInteger)menu:(HFMultistageMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column
{
    if (column == 0) {
        if (row == 0) {
            return self.metroArray.count;
        } else if (row == 1){
            return self.businessArray.count;
        }
    }
    return 0;
}

- (NSString *)menu:(HFMultistageMenu *)menu titleForItemsInRowAtIndexPath:(HFIndexPath *)indexPath
{
    if (indexPath.column == 0) {
        if (indexPath.row == 0) {
            return self.metroArray[indexPath.item];
        } else if (indexPath.row == 1){
            return self.businessArray[indexPath.item];
        }
    }
    return nil;
}


#pragma mark-----HFMultistageMenuDelegate

- (void)menu:(HFMultistageMenu *)menu didSelectRowAtIndexPath:(HFIndexPath *)indexPath
{
    

}

#pragma mark---lazy 加载
- (NSMutableArray *)businessArray
{
    if(!_businessArray)
    {
        _businessArray = [NSMutableArray array];
    }
    return _businessArray;
    
}
- (NSMutableArray *)metroArray
{
    if(!_metroArray)
    {
        _metroArray = [NSMutableArray array];
    }
    return _metroArray;
    
}
- (NSMutableArray *)onelineArray
{
    if(_onelineArray)
    {
        _onelineArray = [NSMutableArray array];
    }
    return _onelineArray;
}

- (NSMutableArray *)twolineArray
{
    if(_twolineArray)
    {
        _twolineArray = [NSMutableArray array];
    }
    return _twolineArray;
}

- (NSMutableArray *)threelineArray
{
    if(_threelineArray)
    {
        _threelineArray = [NSMutableArray array];
    }
    return _threelineArray;
}

- (NSMutableArray *)fourlineArray
{
    if(_fourlineArray)
    {
        _fourlineArray = [NSMutableArray array];
    }
    return _fourlineArray;
}

- (NSMutableArray *)finelineArray
{
    if(_finelineArray)
    {
        _finelineArray = [NSMutableArray array];
    }
    return _finelineArray;
}


@end
