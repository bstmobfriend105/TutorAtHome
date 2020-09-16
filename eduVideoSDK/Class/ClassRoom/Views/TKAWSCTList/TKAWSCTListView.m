//
//  TKAWSCTListView.m
//  EduClass
//
//  Created by talkcloud on 2018/10/15.
//  Copyright © 2018年 talkcloud. All rights reserved.
//

#import "TKAWSCTListView.h"
#import <QuartzCore/QuartzCore.h>
#import "TKAWSCTDocumentListView.h"
#import "TKEduSessionHandle.h"
#import "TKMediaDocModel.h"

#define ThemeKP(args) [@"TKListView." stringByAppendingString:args]

@interface TKAWSCTListView ()<TKAWSCTDocumentListDelegate>

@property (nonatomic, strong) UIButton * prevSelectedButton;
@property (nonatomic, strong) TKAWSCTDocumentListView *documentListView;

#define NUM_COURSEWARES 6

@end

@implementation TKAWSCTListView

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title from:(NSString *)from
{
    if (self = [super initWithFrame:frame]) {
        
        //标题空间
        self.titleText = TKMTLocalized(@"Title.DocumentList");
        
        CGFloat leftSpace = self.backImageView.width / 7;
        
        self.contentImageView.frame = CGRectMake(leftSpace, self.titleH, self.backImageView.width - leftSpace - 3, self.backImageView.height - self.titleH - 3);
        self.contentImageView.sakura.image(@"TKBaseView.base_bg_corner_4");
        
        CGFloat courseW = leftSpace - 6;
        CGFloat courseH = courseW / 2;
        CGFloat courseY = 10;//self.titleH;
        
        for (int i = 0; i < NUM_COURSEWARES; i++) {
            UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
            button.frame = CGRectMake(6, courseY+(courseH+10)*i, courseW, courseH);
            [self addSubview:button];
            button.sakura.image(ThemeKP(@"selector_point_default"), UIControlStateNormal);
            button.sakura.image(ThemeKP(@"selector_point_select"),UIControlStateSelected);
            [button setTitle:[NSString stringWithFormat:@" P%d", i+1] forState:(UIControlStateNormal)];
            [button setTitle:[NSString stringWithFormat:@" P%d", i+1] forState:(UIControlStateSelected)];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize: 12.0];
            button.sakura.backgroundImage(ThemeKP(@"selector_bg_default"),UIControlStateNormal);
            button.sakura.backgroundImage(ThemeKP(@"selector_bg_select"),UIControlStateSelected);
            button.sakura.titleColor(ThemeKP(@"coursewareButtonDefaultColor"),UIControlStateNormal);
            button.sakura.titleColor(ThemeKP(@"coursewareButtonSelectedColor"),UIControlStateSelected);
            button.tag = i+99;
            [button addTarget:self action:@selector(listButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
            
            if (button.titleLabel.text ) {
                int currentFontSize = button.frame.size.width/5;
                if (currentFontSize>14) {
                    currentFontSize = 14;
                }
                button.titleLabel.font = TKFont(currentFontSize);
            }
        }
        
        // 文件库
        _documentListView = [[TKAWSCTDocumentListView alloc]initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.contentImageView.frame), CGRectGetHeight(self.frame))];
        [self addSubview:_documentListView];
        _documentListView.documentDelegate = self;
        
        [self newUI];
    }
    return self;
}

- (void)newUI
{
    self.userInteractionEnabled = YES;
    [self.backImageView removeFromSuperview];
    [self.contentImageView removeFromSuperview];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    backView.userInteractionEnabled = YES;
    backView.backgroundColor = UIColor.clearColor;
    backView.sakura.backgroundColor(ThemeKP(@"courseware_bg_Color"));
    backView.sakura.alpha(ThemeKP(@"courseware_bg_alpha"));
    backView.backgroundColor = [backView.backgroundColor colorWithAlphaComponent:backView.alpha];
    backView.alpha = 1;
    [self addSubview:backView];
    [self sendSubviewToBack:backView];
    
    CGFloat leftSpace = self.backImageView.width / 7;
    CGFloat courseW = leftSpace - 6;
    
    UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, courseW + 12, self.height)];
    btnBackView.sakura.backgroundColor(ThemeKP(@"courseware_selectView_bg_Color"));
    btnBackView.sakura.alpha(ThemeKP(@"courseware_selectView_bg_alpha"));
    [backView addSubview:btnBackView];
    
    _documentListView.frame = CGRectMake(btnBackView.width, 0, self.width - btnBackView.width, self.height);
}

- (void)touchOutSide{
    [self dismissAlert];
}
#pragma mark - 课件库切换
- (void)listButtonClick:(UIButton *)sender{
    
    NSInteger type = sender.tag-99;
    
    _prevSelectedButton.selected = NO;
    sender.selected = YES;
    
    _documentListView.courseArray = self.courseArray;
    [_documentListView show:type+1];
    _prevSelectedButton = sender;
}

- (void)watchFile{
    [self dismissAlert];
}

- (void)show:(UIView *)view
{
    [view addSubview:self];
    CGRect rect = self.frame;
    self.frame = CGRectMake(ScreenW, rect.origin.y, rect.size.width, rect.size.height);
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = CGRectMake(ScreenW - rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
    }];
}

- (void)hidden{
    
    [self dismissAlert];
}

- (void)dismissAlert
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         CGRect rect = self.frame;
                         self.frame = CGRectMake(ScreenW, rect.origin.y, rect.size.width, rect.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         
                         [self removeFromSuperview];
                         if (self.dismissBlock) {
                             self.dismissBlock();
                         }
                     }];
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
- (void)removeFromSuperview
{
    [super removeFromSuperview];
}
@end


