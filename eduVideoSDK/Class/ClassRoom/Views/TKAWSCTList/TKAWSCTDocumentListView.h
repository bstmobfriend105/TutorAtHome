//
//  TKAWSCTDocumentListView.h
//  EduClass
//
//  Created by talkcloud on 2018/10/16.
//  Copyright © 2018年 talkcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TKEduSessionHandle.h"
@class TKOneToMoreRoomController;

@protocol TKAWSCTDocumentListDelegate <NSObject>
- (void)watchFile;
@end

@interface TKAWSCTDocumentListView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id<TKAWSCTDocumentListDelegate> documentDelegate;

@property (nonatomic,weak)TKOneToMoreRoomController*  delegate;

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic,strong) NSArray *courseArray;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)show:(NSInteger)courseIndex;

-(void)hide;

- (void)reloadData;

@end


