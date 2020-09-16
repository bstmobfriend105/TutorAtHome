//
//  TKAWSCTListView.h
//  EduClass
//
//  Created by talkcloud on 2018/10/15.
//  Copyright © 2018年 talkcloud. All rights reserved.
//

#import "TKCTBaseView.h"

@interface TKAWSCTListView : TKCTBaseView

@property (nonatomic,strong) NSArray *courseArray;

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title from:(NSString *)from;

- (void)show:(UIView *)view;
- (void)hidden;
- (void)dismissAlert;

@end
