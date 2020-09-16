//
//  TKDrawView.h
//  TKWhiteBoard
//
//  Created by Yibo on 2019/4/1.
//  Copyright © 2019 MAC-MiNi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKWhiteBoardEnum.h"
/*
DrawView工作模式：
切换mode，TKWorkController模式下可以绘制，TKWorkViewer模式下不可绘制

实时绘制逻辑：
TKDrawView画布由两层DrawView构成，非橡皮擦功能时上层_rtDrawView用来实时涂鸦并往外发送涂鸦信令，下层_drawView收到涂鸦信令时添加涂鸦并清除上层_rtDrawView刚才残留的那一笔涂鸦。
橡皮擦功能时上层_rtDrawView隐藏，直接在_drawView上涂鸦并发送涂鸦信令，当信令返回时删除刚才残留的那一笔橡皮擦。
实时绘制层总是只绘制当前这一笔，避免所有笔记同时重绘计算量太大导致touchMove采样率变低，touchMove采样率变低的结果就是绘制的曲线采样点不够画出来不平滑。

DrawView上数据储存逻辑：
drawBackArray用来储存所有绘制数据,包括线，字，形,eraser以及clean，本数组只增不减。使用operationPointer指向当前drawBackArray的操作步骤。
undo消息导致operationPointer左移一位，redo消息导致operationPointer右移一位，接收新绘制消息operationPointer右移一位。
drawArray用来储存需要展示的绘制，数据源为drawBackArray的operationPointer位置到operationPointer左侧第一个clean位置之间的所有绘制元素。
每次undo，redo或者收到绘制消息直接修改operationPointer位置，然后按照上面方式从drawBackArray取出数据存入drawArray，根据drawArray刷新绘制。
如果undo，redo之后operationPointer指向一条clean消息则直接清空drawArray并刷新绘制。
为保证上面取数据源操作的统一性在创建drawBackArray的时候先在其下标0的位置插入一条clean。

DrawView翻页逻辑：
DrawView使用drawDictionary来充当总数据源，一页数据的形式为{@"fileid###pageid" : @[drawArray,
drawBackArray]}. 每次添加绘制前先调用switchFileID进行翻页，然后addDraw往当前页添加绘制。
翻页操作步骤为先以当前页的fileid和pageid组合成的key存下当前页的drawArray和drawBackArray。然后根据翻页信息取出需要写入的drawArray和drawBackArray。随后往里写入。
按照翻页信息取出drawArray和drawBackArray后要根据元素信息计算好operationPointer才能保证翻页后的undo，redo逻辑。

DrawView进教室数据恢复逻辑：
whiteBoardOnRoomConnectedUserlist中拿到恢复数据后按照seq排序，然后遍历执行addDraw即可完成数据恢复

*/




@class DrawView;

NS_ASSUME_NONNULL_BEGIN

@protocol TKDrawViewDelegate <NSObject>


/**
 涂鸦数据回调
 
 @param fileid 所属文件id
 @param shapeID 涂鸦id
 @param shapeData 涂鸦数据
 */
- (void)addSharpWithFileID:(NSString *)fileid shapeID:(NSString *)shapeID shapeData:(NSData *)shapeData;

- (void)addFingerWithFileID:(NSString *)fileid shapeID:(NSString *)shapeID shapeData:(NSData *)shapeData;

@end

@interface TKDrawView : UIView
@property (nonatomic, strong) DrawView *drawView;                       //涂鸦显示层
@property (nonatomic, strong) DrawView *rtDrawView;                     //实时绘制层
@property (nonatomic, copy) NSString *fileid;                           //涂鸦所属文件id
@property (nonatomic, assign) int pageid;                               //涂鸦所属文件页码
@property (nonatomic, assign) float scale;                         //涂鸦比例，当前涂鸦frame.width / 960
@property (nonatomic, weak) id <TKDrawViewDelegate>delegate;

- (instancetype)initWithDelegate:(nullable id<TKDrawViewDelegate>)delegate;


/**
 是否已经设置了画笔
 
 @return 画笔状态
 */
- (BOOL)hasDraw;

/**
 设置画笔
 
 @param drawType 画笔类型
 @param hexColor 16进制画笔颜色
 @param progress 画笔粗细，0.05f~1.0f
 */
- (void)setDrawType:(TKDrawType)drawType
           hexColor:(NSString *)hexColor
           progress:(float)progress;



/**
 翻到涂鸦所属文件及页码
 
 @param fileID 文件id
 @param pageID 页码数
 @param refresh 是否立即刷新
 */
- (void)switchToFileID:(NSString *)fileID
                pageID:(int)pageID
    refreshImmediately:(BOOL)refresh;


/**
 添加一笔涂鸦
 
 @param data 涂鸦数据字典
 @param refresh 是否立即刷新
 */
- (void)addDrawData:(NSDictionary *)data
 refreshImmediately:(BOOL)refresh;


/**
 撤销一笔涂鸦
 */
- (void)undoDraw;


/**
 清空涂鸦
 
 @param clearID 清空id
 */
- (void)clearDraw:(NSString *)clearID;


/**
 清理一页数据
 
 @param fileID 文件id
 @param pageNum 页码
 */
- (void)clearOnePageWithFileID:(NSString *)fileID pageNum:(int)pageNum;

- (void)clearTemporaryData;

/**
 设置画布工作模式
 
 @param mode 模式枚举：工作模式or观察模式
 */
- (void)setWorkMode:(TKWorkMode)mode;


/**
 下课清理数据
 */
- (void)clearDataAfterClass;

@end

NS_ASSUME_NONNULL_END
