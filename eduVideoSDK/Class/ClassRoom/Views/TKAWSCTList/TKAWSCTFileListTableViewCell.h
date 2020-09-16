//
//  TKAWSCTFileListTableViewCell.h
//  EduClass
//
//  Created by talkcloud on 2018/10/16.
//  Copyright © 2018年 talkcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol listCTProtocol <NSObject>
- (void)watchFile:(UIButton *)aButton courseware:(NSString*)sCourseWare level:(NSString*)sLevel;

@end

@interface TKAWSCTFileListTableViewCell : UITableViewCell

@property (weak, nonatomic) id<listCTProtocol> delegate;

@property (strong, nonatomic) UIButton *watchBtn;
@property (nonatomic, strong) NSString *text;
@property (strong, nonatomic) NSIndexPath *iIndexPath;

@property (nonatomic, assign) BOOL hiddenDeleteBtn;

-(void)configaration:(NSString*)courseware level:(NSString*)courseLevel;

@end

