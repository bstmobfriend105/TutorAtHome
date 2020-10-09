//
//  TKAWSCTDocumentListView.m
//  EduClass
//
//  Created by talkcloud on 2018/10/16.
//  Copyright © 2018年 talkcloud. All rights reserved.
//

#import "TKAWSCTDocumentListView.h"
#import "TKAWSCTFileListTableViewCell.h"
#import "TKMediaDocModel.h"
#import "TKDocmentDocModel.h"
#import "UIView+TKExtension.h"
#import "TKManyViewController+Media.h"
#import "TKHUD.h"

#define ThemeKP(args) [@"TKDocumentListView." stringByAppendingString:args]
#define kMargin 10
@interface TKAWSCTDocumentListView ()<listCTProtocol>
{
    CGFloat _toolHeight;//工具条高度
    CGFloat _bottomHeight;//底部按钮高度
    NSString *_lastCourseLevel;
    NSString *_nextCourseLevel;
}

@property (nonatomic,strong)NSMutableArray *lastFileMutableArray;
@property (nonatomic,strong)NSMutableArray *nextFileMutableArray;
@property (nonatomic,retain)UIView  *nextFileView;
@property (nonatomic,retain)UIView  *lastFileFiew;
@property (nonatomic,retain)UIImageView *lastArrowImageView;
@property (nonatomic,retain)UIImageView *nextArrowImageView;
@property (nonatomic,retain)UITableView    *lastFileTableView;//展示tableview
@property (nonatomic,retain)UITableView    *nextTableView;//展示tableview
@property (nonatomic,assign)BOOL  shouldHideClassFile;
@property (nonatomic,assign)NSInteger  selCourseIndex;
@property (nonatomic,strong)UIButton*  iCurrrentButton;
@property (nonatomic,strong)UIButton*  iPreButton;

@end

@implementation TKAWSCTDocumentListView
-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.hidden = YES;
        _toolHeight = IS_PAD?CGRectGetHeight(frame)/12.0:40;
        _bottomHeight = IS_PAD ? 50:40;

        [self loadTableView:frame];
        [self newUI];
    }
    return self;
}

- (void)newUI
{
    _lastFileFiew = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.width - 20, 42)];
    _lastFileFiew.tag = 1010;
    _lastFileFiew.sakura.backgroundColor(ThemeKP(@"listFileSectionColor"));
    _lastFileFiew.sakura.alpha(ThemeKP(@"listFileSectionAlpha"));
    // 防止视图alpha对子视图的影响
    _lastFileFiew.backgroundColor = [_lastFileFiew.backgroundColor colorWithAlphaComponent:_lastFileFiew.alpha];
    _lastFileFiew.alpha = 1;
    
    _lastFileFiew.layer.cornerRadius   = 6;
    _lastFileFiew.layer.masksToBounds  = YES;
    [self addSubview:_lastFileFiew];

    UILabel *classFileLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 100, 14)];
    classFileLabel.font = TKFont(14);
    classFileLabel.text = TKMTLocalized(@"Title.LastDocuments");
    classFileLabel.textColor =UIColor.whiteColor;
    [_lastFileFiew addSubview:classFileLabel];
    
    _lastArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_lastFileFiew.width - 30, (_lastFileFiew.height - 15) / 2, 15, 15)];
    _lastArrowImageView.sakura.image(@"TKDocumentListView.icon_arrow_right");
    [_lastFileFiew addSubview:_lastArrowImageView];

    UITapGestureRecognizer *classFileG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHide:)];
    [_lastFileFiew addGestureRecognizer:classFileG];
    
    _lastFileTableView.frame = CGRectMake(0, CGRectGetMaxY(_lastFileFiew.frame), self.width - 10, self.height - CGRectGetMaxY(_lastFileFiew.frame) - _lastFileFiew.height);
    
    _nextFileView = [[UIView alloc] initWithFrame:CGRectMake(10, self.height - 42, self.width - 20, 42)];
    _nextFileView.tag = 2020;
    _nextFileView.sakura.backgroundColor(ThemeKP(@"listFileSectionColor"));
    _nextFileView.sakura.alpha(ThemeKP(@"listFileSectionAlpha"));
    // 防止视图alpha对子视图的影响
    _nextFileView.backgroundColor = [_nextFileView.backgroundColor colorWithAlphaComponent:_nextFileView.alpha];
    _nextFileView.alpha = 1;
    
    _nextFileView.layer.cornerRadius   = 6;
    _nextFileView.layer.masksToBounds  = YES;
    [self addSubview:_nextFileView];
    
    UILabel *publicFileLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 100, 14)];
    publicFileLabel.font = TKFont(14);
    publicFileLabel.text = TKMTLocalized(@"Title.NextDocuments");
    publicFileLabel.textColor = UIColor.whiteColor;
    [_nextFileView addSubview:publicFileLabel];
    
    _nextArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_nextFileView.width - 30, (_nextFileView.height - 15) / 2, 15, 15)];
    _nextArrowImageView.sakura.image(@"TKDocumentListView.icon_arrow_right");
    [_nextFileView addSubview:_nextArrowImageView];
    
    UITapGestureRecognizer *publicFileG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHide:)];
    [_nextFileView addGestureRecognizer:publicFileG];
    
    _nextTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_nextFileView.frame), self.width - 10, _lastFileTableView.height) style:UITableViewStylePlain];
    _nextTableView.backgroundColor = [UIColor clearColor];
    _nextTableView.separatorColor  = [UIColor clearColor];
    _nextTableView.showsHorizontalScrollIndicator = NO;
    _nextTableView.delegate   = self;
    _nextTableView.dataSource = self;
    _nextTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [_nextTableView registerClass:[TKAWSCTFileListTableViewCell class] forCellReuseIdentifier:@"TKAWSCTFileListTableViewCellID"];
    [self addSubview:_nextTableView];
    
    //默认都是展开状态
    _lastFileTableView.height = 0;
    _nextFileView.y = CGRectGetMaxY(_lastFileTableView.frame) + 5;
    _nextTableView.y = CGRectGetMaxY(_nextFileView.frame);
    _nextTableView.height = 0;
    
    _shouldHideClassFile = NO;
    _selCourseIndex = 0;
    
}

- (void)tapToHide:(UITapGestureRecognizer *)tapG
{
    [self hideTableView:(tapG.view == _lastFileFiew) ? _lastFileTableView : _nextTableView animationWithDuration:0.2f];
}

- (void)hideTableView:(UITableView *)tableView animationWithDuration:(NSTimeInterval)timeInterval
{
    BOOL shouldHidePublicFile = _nextTableView.height > 0;
    if (tableView == _lastFileTableView) {
        //收起教室文件列表
        [UIView animateWithDuration:timeInterval animations:^{
            
            // 展开教室列表时，收起公用文件列表
            if (self.nextTableView.height > 0) {
                self.nextTableView.height = 0;
                self.nextArrowImageView.sakura.image(@"TKDocumentListView.icon_arrow_right");
            }
            
            self.lastFileTableView.height = self.shouldHideClassFile ? 0 : self.lastFileMutableArray.count * 60 > (self.height - CGRectGetMaxY(self.lastFileFiew.frame) - self.lastFileFiew.height) ? (self.height - CGRectGetMaxY(self.lastFileFiew.frame) - self.lastFileFiew.height) : self.lastFileMutableArray.count * 60;

            if (self.lastFileTableView.height > 0) {
                self.nextFileView.y =  (self.height - CGRectGetMaxY(self.lastFileTableView.frame) > 5) ? CGRectGetMaxY(self.lastFileTableView.frame) : CGRectGetMaxY(self.lastFileFiew.frame) + 5;
            } else {
                self.nextFileView.y = CGRectGetMaxY(self.lastFileFiew.frame) + 5;
            }
            self.nextTableView.y = CGRectGetMaxY(self.nextFileView.frame);
            self.nextTableView.height = self.shouldHideClassFile ? (self.nextTableView.height > 0 ? self.height - CGRectGetMaxY(self.nextFileView.frame) : 0) : self.nextTableView.height;
            self.lastArrowImageView.sakura.image(self.shouldHideClassFile ? @"TKDocumentListView.icon_arrow_right" : @"TKDocumentListView.icon_arrow_down");
            self.shouldHideClassFile = !self.shouldHideClassFile;
        }];
    }
    else {
        //收起公用文件列表
        [UIView animateWithDuration:timeInterval animations:^{
            // 展开公用列表时，收起教室文件列表
            if (self.lastFileTableView.height > 0) {
                self.shouldHideClassFile = !self.shouldHideClassFile;
                self.lastFileTableView.height = 0;
                self.lastArrowImageView.sakura.image(@"TKDocumentListView.icon_arrow_right");
            }
            
            self.nextFileView.y = CGRectGetMaxY(self.lastFileFiew.frame) + 5;
            self.nextTableView.y = CGRectGetMaxY(self.nextFileView.frame);
            self.nextTableView.height = shouldHidePublicFile ? 0 : ((CGRectGetMaxY(self.nextTableView.frame) == self.height) ?  self.height - CGRectGetMaxY(self.lastFileFiew.frame) - 5 - self.nextFileView.height: self.height - CGRectGetMaxY(self.nextFileView.frame));
            self.nextArrowImageView.sakura.image(shouldHidePublicFile ? @"TKDocumentListView.icon_arrow_right" : @"TKDocumentListView.icon_arrow_down");
        }];
    }
}

-(void)loadTableView:(CGRect)frame{
    
    //文档、媒体头部视图
    _lastFileTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _toolHeight, CGRectGetWidth(frame), CGRectGetHeight(frame)-_toolHeight-40) style:UITableViewStylePlain];
    _lastFileTableView.backgroundColor = [UIColor clearColor];
    _lastFileTableView.separatorColor  = [UIColor clearColor];
    _lastFileTableView.showsHorizontalScrollIndicator = NO;
    _lastFileTableView.delegate   = self;
    _lastFileTableView.dataSource = self;
    _lastFileTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [_lastFileTableView registerClass:[TKAWSCTFileListTableViewCell class] forCellReuseIdentifier:@"TKAWSCTFileListTableViewCellID"];
    [self addSubview:_lastFileTableView];
}

- (UIButton *)createCommonButtonWithFrame:(CGRect)frame title:(NSString *)title selector:(SEL)selector
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:CGRectGetHeight(btn.frame)/9 + 10];
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.sakura.backgroundImage(ThemeKP(@"choose_photo_button_click"),UIControlStateNormal);
    [TKUtil setCornerForView:btn];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.hidden = YES;
    return btn;
}

- (void)reloadData {
    
    [self refreshData:_selCourseIndex];
}

#pragma mark tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _lastFileTableView) {
        return _lastFileMutableArray.count;
    } else {
        return _nextFileMutableArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *tCell;
    NSMutableArray *tmpArray;
    NSString *courseLevel;
    if (tableView == _lastFileTableView) {
        tmpArray = _lastFileMutableArray;
        courseLevel = _lastCourseLevel;
    } else {
        tmpArray = _nextFileMutableArray;
        courseLevel = _nextCourseLevel;
    }
    
    TKAWSCTFileListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TKAWSCTFileListTableViewCellID" forIndexPath:indexPath];
    cell.delegate = self;
    cell.iIndexPath = indexPath;
    tCell = cell;

 //   NSString *sCourseware = [tmpArray objectAtIndex:indexPath.row];
   // NSString *sCourse = [tmpArray objectAtIndex:indexPath.row];
    NSDictionary *data = [tmpArray objectAtIndex:indexPath.row];
    NSString *sCourseware = [data objectForKey:@"name"];
    NSString *sTotalPage = [data objectForKey:@"totalpage"];
    int totalPage = [sTotalPage intValue];
    [cell configaration:sCourseware level:courseLevel totalpage:totalPage];
    
    tCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return tCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([TKEduClassRoom shareInstance].roomJson.roomrole == TKUserType_Patrol) {
        return;
    }
    
    TKAWSCTFileListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *aButton = cell.watchBtn;
    
    NSMutableArray *tmpArray;
    NSString *courseLevel;
    if (tableView == _lastFileTableView) {
        tmpArray = _lastFileMutableArray;
        courseLevel = _lastCourseLevel;
    } else {
        tmpArray = _nextFileMutableArray;
        courseLevel = _nextCourseLevel;
    }
    
    NSDictionary *data = [tmpArray objectAtIndex:indexPath.row];
    NSString *sCourseware = [data objectForKey:@"name"];
    NSString *sTotalPage = [data objectForKey:@"totalpage"];
    
    int totalPage = [sTotalPage intValue];
    //[self watchFile:aButton courseware:tmpArray[indexPath.row] level:courseLevel];
    [self watchFile:aButton courseware:sCourseware level:courseLevel totalpage:totalPage];}

-(void)show:(NSInteger)courseIndex{
    
    self.hidden = NO;
    
    _selCourseIndex = courseIndex;
    [self refreshData:courseIndex];
    
    [self updateData];
}

-(void)hide{
    
    self.hidden = YES;
}

-(void)updateData{
    
    if (_lastFileTableView.height > 0) {
        
        [self refreshTableHeight:_lastFileTableView];
    }
    if (_nextTableView.height > 0) {
        
        [self refreshTableHeight:_nextTableView];
    }
}

- (void)refreshTableHeight:(UITableView *)tableView {
    
    if (tableView == _lastFileTableView) {
        //收起教室文件列表
        [UIView animateWithDuration:0.2 animations:^{
                        
            self.lastFileTableView.height = self.lastFileMutableArray.count * 60 > (self.height - CGRectGetMaxY(self.lastFileFiew.frame) - self.lastFileFiew.height) ? (self.height - CGRectGetMaxY(self.lastFileFiew.frame) - self.lastFileFiew.height) : self.lastFileMutableArray.count * 60;

            self.nextFileView.y = CGRectGetMaxY(self.lastFileFiew.frame) + 5;
            self.nextTableView.y = CGRectGetMaxY(self.nextFileView.frame);
        }];
    }
    else {
        self.nextTableView.height =  ((CGRectGetMaxY(_nextTableView.frame) == self.height)
                                    ?  self.height - CGRectGetMaxY(_lastFileFiew.frame) - 5 - _nextFileView.height
                                    : self.height - CGRectGetMaxY(_nextFileView.frame));
        
    }
}

-(void)refreshData:(NSInteger)courseIndex{
    
    _lastFileMutableArray = [[NSMutableArray alloc] init];
    _nextFileMutableArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary* courseDict in _courseArray) {
        NSString *level = [courseDict objectForKey:@"level"];
        NSString *levelId = [NSString stringWithFormat:@"P%d", (int)courseIndex];
        if ([level containsString:levelId]) {
            if ([level containsString:@"上"]) {
                NSArray *coursewareArray = [courseDict objectForKey:@"courseware"];
                _lastCourseLevel = level;
                _lastFileMutableArray = [coursewareArray mutableCopy];
            } else if ([level containsString:@"下"]) {
                NSArray *coursewareArray = [courseDict objectForKey:@"courseware"];
                _nextCourseLevel = level;
                _nextFileMutableArray = [coursewareArray mutableCopy];
            }
        }
    }
    
    [_lastFileTableView reloadData];
    [_nextTableView reloadData];
}

#pragma mark - 课件切换
- (void)watchFile:(UIButton *)aButton courseware:(NSString*)sCourseWare level:(NSString*)sLevel totalpage:(int)totalPage
{

    if (self.documentDelegate && [self.documentDelegate respondsToSelector:@selector(watchFile)]) {
    }

    [aButton setSelected:YES];
        
    [TKEduSessionHandle shareInstance].iSelCoursewarePath = [NSString stringWithFormat:@"%@/%@", sLevel, sCourseWare];
    [TKEduSessionHandle shareInstance].iSelCoursewareTotalpage = totalPage;
    
    if ([TKEduSessionHandle shareInstance].iSelCoursewareMutableDic == nil) {
        [TKEduSessionHandle shareInstance].iSelCoursewareMutableDic = [[NSMutableDictionary alloc] init];
    }
    
    if ([TKEduSessionHandle shareInstance].iSelWhiteBoardFileId != nil) {
        [[TKEduSessionHandle shareInstance].iSelCoursewareMutableDic setObject:[TKEduSessionHandle shareInstance].iSelCoursewarePath
                                                                        forKey:[TKEduSessionHandle shareInstance].iSelWhiteBoardFileId];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:sLoadAWSCourseware object:nil];
    
    /*TKDocmentDocModel *tDocmentDocModel = model;//[tmpArray objectAtIndex:aIndexPath.row];
    
    if ([TKEduSessionHandle shareInstance].isClassBegin) {
        [[TKEduSessionHandle shareInstance] publishtDocMentDocModel:tDocmentDocModel To:sTellAllExpectSender aTellLocal:YES];
        
    }else{
        
        [[TKEduSessionHandle shareInstance].whiteBoardManager showDocumentWithFile:(TKFileModel *)tDocmentDocModel isPubMsg:NO];

        [TKEduSessionHandle shareInstance].iCurrentDocmentModel = tDocmentDocModel;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:sShowPageBeforeClass object:nil];
    }*/

    _iCurrrentButton = aButton;
    if (_iPreButton) {
        [_iPreButton setSelected:NO];
    }
    
    _iPreButton = _iCurrrentButton;
    
    [self reloadData];
}

-(void)dealloc{
    
}

@end

