//
//  TKAWSCTFileListTableViewCell.m
//  EduClass
//
//  Created by talkcloud on 2018/10/16.
//  Copyright © 2018年 talkcloud. All rights reserved.
//

#import "TKAWSCTFileListTableViewCell.h"
#import "TKDocmentDocModel.h"
#import "TKMediaDocModel.h"
#import "TKEduSessionHandle.h"


#define ThemeKP(args) [@"TKDocumentListView." stringByAppendingString:args]

@interface TKAWSCTFileListTableViewCell()

@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *nameLabel;

@end

@implementation TKAWSCTFileListTableViewCell
{
    NSString *_sCourseware;
    NSString *_sCourseLevel;
    int _TotalPage;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];

        self.backView = [[UIView alloc] init];
        self.backView.backgroundColor = UIColor.clearColor;
        self.backView.layer.masksToBounds = YES;
        self.backView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.backView];
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        self.watchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.watchBtn addTarget:self action:@selector(watchClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.watchBtn];
        [self.watchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-20);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.size.equalTo([NSValue valueWithCGSize:CGSizeMake(40, 40)]);
        }];
        
        self.iconImageView = [[UIImageView alloc] init];
        [self addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(20);
            make.centerY.equalTo(self.mas_centerY);
            make.size.equalTo([NSValue valueWithCGSize:CGSizeMake(34, 34)]);
        }];

        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.sakura.textColor(@"TKUserListTableView.coursewareButtonWhiteColor");
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(15);
            make.centerY.equalTo(self.iconImageView.mas_centerY);
            make.right.equalTo(self.watchBtn.mas_left).offset(-10);
        }];
        
        self.hiddenDeleteBtn = NO;
        [[TKEduSessionHandle shareInstance] addObserver:self forKeyPath:@"iIsPlaying" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

- (IBAction)watchClick:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(watchFile:courseware:level:)]) {
        [self.delegate watchFile:sender courseware:_sCourseware level:_sCourseLevel totalpage: _TotalPage];
    }
}

-(void)configaration:(NSString*)courseware level:(NSString*)courseLevel totalpage:(int)totalPage{
    
    _watchBtn.sakura.image(ThemeKP(@"close_eyes"),UIControlStateNormal);
    _watchBtn.sakura.image(ThemeKP(@"open_eyes"),UIControlStateSelected);
       
    BOOL tIsCurrentDocment = false;
    NSString *coursewarePath = [NSString stringWithFormat:@"%@/%@", courseLevel, courseware];
    
    NSString *selCoursewarePath;
    if ([TKEduSessionHandle shareInstance].iSelCoursewareMutableDic != nil &&
        [TKEduSessionHandle shareInstance].iSelWhiteBoardFileId != nil) {
        selCoursewarePath = [[TKEduSessionHandle shareInstance].iSelCoursewareMutableDic objectForKey:[TKEduSessionHandle shareInstance].iSelWhiteBoardFileId];
    } else {
        selCoursewarePath = [TKEduSessionHandle shareInstance].iSelCoursewarePath;
    }
    
    if ([coursewarePath isEqual:selCoursewarePath]) {
        tIsCurrentDocment = true;
    }
    _sCourseware = courseware;
    _sCourseLevel = courseLevel;
    _TotalPage = totalPage;
    _watchBtn.selected = tIsCurrentDocment;
    _nameLabel.text = courseware;
    _iconImageView.image = [UIImage imageNamed:@"icon_weizhi"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    @try {
        [[TKEduSessionHandle shareInstance] removeObserver:self forKeyPath:@"iIsPlaying"];

    } @catch (NSException *exception) {
    }
}
@end
