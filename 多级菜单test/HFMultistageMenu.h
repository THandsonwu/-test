//
//  HFMultistageMenu.h
//  三级菜单
//
//  Created by chinatsp on 16/7/20.
//  Copyright © 2016年 HandsonWu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HFIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger item;



- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item;

+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row;

+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item;


@end

@interface HFMenuBackgroundView : UIView

@end

#pragma mark--------dataSource protocol

@class HFMultistageMenu;
@protocol HFMultistageMenuDataSource <NSObject>

@required
/**
 *  返回有多少选择菜单
 *
 *  @param menu HFMultistageMenu
 *
 *  @return 有几列
 */
- (NSInteger)numberOfColumnsInMenu:(HFMultistageMenu *)menu;
/**
 *  返回每列有多少行
 *
 *  @param menu   HFMultistageMenu
 *  @param column 当前列
 *
 *  @return 当前列下有多少行
 */
- (NSInteger)menu:(HFMultistageMenu *)menu numberOfRowsInColumn:(NSInteger)column;
/**
 *  返回每行的标题
 *
 *  @param menu      HFMultistageMenu
 *  @param indexPath 目标坐标
 *
 *  @return 目标行的标题
 */
- (NSString *)menu:(HFMultistageMenu *)menu titleForRowAtIndexPath:(HFIndexPath *)indexPath;

@optional


/**
 *  返回目标行的icon字符串
 *
 *  @param menu      HFMultistageMenu
 *  @param indexPath 目标坐标
 *
 *  @return icon字符串
 */
- (NSString *)menu:(HFMultistageMenu *)menu imageNameForRowAtIndexPath:(HFIndexPath *)indexPath;
/**
 *  返回小标题
 *
 *  @param menu      HFMultistageMenu
 *  @param indexPath 目标坐标
 *
 *  @return 小标题
 */
- (NSString *)menu:(HFMultistageMenu *)menu detailTextForRowAtIndexPath:(HFIndexPath *)indexPath;
/**
 *  是否有二级菜单,返回二级菜单的行数
 *
 *  @param menu   HFMultistageMenu
 *  @param row    当前行
 *  @param column 当前列
 *
 *  @return 当前列,当前行下的二级子菜单个数
 */
- (NSInteger)menu:(HFMultistageMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column;

/**
 *  二级子菜单每行的标题
 *
 *  @param menu      HFMultistageMenu
 *  @param indexPath 二级菜单的目标坐标
 *
 *  @return 二级菜单每行子标题
 */
- (NSString *)menu:(HFMultistageMenu *)menu titleForItemsInRowAtIndexPath:(HFIndexPath *)indexPath;
/**
 *  二级菜单每行的icon名称
 *
 *  @param menu      HFMultistageMenu
 *  @param indexPath 二级菜单的目标坐标
 *
 *  @return 二级菜单每行的icon名称
 */
- (NSString *)menu:(HFMultistageMenu *)menu imageNameForItemsInRowAtIndexPath:(HFIndexPath *)indexPath;
/**
 *  二级菜单每行的子标题
 *
 *  @param menu      HFMultistageMenu
 *  @param indexPath 二级菜单的目标坐标
 *
 *  @return 二级菜单每行的子标题
 */
- (NSString *)menu:(HFMultistageMenu *)menu detailTextForItemsInRowAtIndexPath:(HFIndexPath *)indexPath;



@end

#pragma mark--------HFMultistageMenuDelegate

@protocol HFMultistageMenuDelegate <NSObject>
@optional
/**
 *  点击代理,点击了第column列,第row行,如果有二级,则第item行
 *
 *  @param menu      HFMultistageMenu
 *  @param indexPath 点击的定位坐标
 */
- (void)menu:(HFMultistageMenu *)menu didSelectRowAtIndexPath:(HFIndexPath *)indexPath;

- (NSIndexPath *)menu:(HFMultistageMenu *)menu undesiredSelectRowAtIndexPath:(HFIndexPath *)indexPath;
/**
 *  菜单目录点击代理
 *
 *  @param menu   HFMultistageMenu
 *  @param isShow 是否显示
 */
- (void)menu:(HFMultistageMenu *)menu didTouched:(BOOL)isShow;

@end




@interface HFMultistageMenu : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<HFMultistageMenuDataSource> dataSource;

@property (nonatomic, weak) id<HFMultistageMenuDelegate> delegate;

@property (nonatomic, assign) UITableViewCellStyle  cellStyle;
/**
 *  箭头颜色
 */
@property (nonatomic, strong) UIColor *arrowKeyColor;
/**
 *  正常文字颜色
 */
@property (nonatomic, strong) UIColor *normalTextColor;
/**
 *  点击选中文字颜色
 */
@property (nonatomic, strong) UIColor *selectTextColor;
/**
 *  子标题文字颜色
 */
@property (nonatomic, strong) UIColor *detailTextColor;
/**
 *  子标题字体
 */
@property (nonatomic, strong) UIFont *detailTextFont;
/**
 *  菜单字体大小
 */
@property (nonatomic, assign) CGFloat sytemFontSize;
/**
 *  分割线颜色
 */
@property (nonatomic, strong) UIColor *separatorColor;
/**
 *  是否响应二级菜单item的点击代理方法
 */
@property (nonatomic, assign) BOOL isResponseSecondaryMenu;
/**
 *  切换条件时是否更改menu标题
 */
@property (nonatomic, assign,getter=isReMainMenuTitle) BOOL ReMainMenuTitle;

/**
 *  恢复默认选项
 */
@property (nonatomic, strong) NSMutableArray *restoreDefaultsArray;

/**
 *  多级菜单初始化方法
 *
 *  @param origin 起点
 *  @param height 菜单高度
 *
 *  @return menu
 */
- (instancetype)initWithMenuOrigin:(CGPoint)origin menuHeight:(CGFloat)height;

/**
 *  获取目标坐标的标题
 *
 *  @param indexPath 目标坐标
 *
 *  @return 目标坐标的标题
 */
- (NSString *)titleForRowAtIndexPath:(HFIndexPath *)indexPath;
/**
 *  第一次创建menu手动调初始设置
 */
- (void)selectDefaultIndexPath;
/**
 *  点击事件
 *
 *  @param indexPath 点击的坐标
 */
- (void)selectIndexPath:(HFIndexPath *)indexPath;
/**
 *  点击事件,调用代理
 *
 *  @param indexPath 点击当前坐标
 *  @param trigger   是否启用代理
 */
- (void)selectIndexPath:(HFIndexPath *)indexPath triggerDelegate:(BOOL)trigger;
/**
 *  刷新数据
 */
- (void)reloadData;


@end
