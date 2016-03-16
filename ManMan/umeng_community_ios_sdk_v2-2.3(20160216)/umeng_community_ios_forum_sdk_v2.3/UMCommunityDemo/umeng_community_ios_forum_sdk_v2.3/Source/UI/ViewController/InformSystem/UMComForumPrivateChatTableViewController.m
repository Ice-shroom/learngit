//
//  UMComForumPrivateChatTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/1.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumPrivateChatTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComUser.h"
#import "UMComCommentEditView.h"
#import "UMComPushRequest.h"
#import "UMComSession.h"
#import "UMComImageView.h"
#import "UMComMutiStyleTextView.h"
#import "UMComTools.h"
#import "UMComPrivateMessage.h"
#import "UIViewController+UMComAddition.h"
#import "UMComPrivateLetter.h"
#import "UMComEditTextView.h"
#import "UMComForumUserCenterViewController.h"
#import "UMComRefreshView.h"
#import "UIViewController+UMComAddition.h"
#import "UMComImageUrl.h"
#import "UMComShowToast.h"
#import "UMComUnReadNoticeModel.h"

NSString *const kUMComMutitext = @"mutitext";
NSString *const kUMComPrivateMessage = @"privateMessage";

#define UMCom_Forum_Chat_Icon_Width 45
#define UMCom_Forum_Chat_Icon_Edge 10
#define UMCom_Forum_Chat_Message_ShortEdge  15 //聊天内容到背景图片边框的距离
#define UMCom_Forum_Chat_Message_LongEdge  47 //背景图片到Cell边框的距离
#define UMCom_Forum_Chat_DateMessage_Space  5
#define UMCom_Forum_Chat_DateLabel_Height  30
#define UMCom_Forum_Chat_Cell_Space  25
#define UMCom_Forum_Chat_DateString_Font  11
#define UMCom_Forum_Chat_Message_Font  15

#define UMCom_Forum_Chat_Date_TextColor @"#A5A5A5"
#define UMCom_Forum_Chat_Cell_BgColor  @"#F5F6FA"
#define UMCom_Forum_Chat_ReceivedMsg_TextColor @"#333333"
#define UMCom_Forum_Chat_SendFrame_LineColor  @"#DEDEDE"
#define UMCom_Forum_Chat_SendFrame_bgColor  @"#F5F6FA"
#define UMCom_Forum_Chat_SendFrame_TextColor @"#333333"
#define UMCom_Forum_Chat_SendFrame_ViewsSpace 10
#define UMCom_Forum_Chat_SendFrame_Heigt 50
#define UMCom_Forum_Chat_SendButton_Width 70
#define UMCom_Forum_Chat_SendButton_TitleFont 15
#define UMCom_Forum_Chat_SendButton_HighLightColor @"#C7C7C7"
#define UMCom_Forum_Chat_SendButton_NomalColor  @"#008BEA"

@interface UMComForumPrivateChatTableViewController ()

@property (nonatomic, strong) UMComPrivateLetter *privateLetter;

@property (nonatomic, strong) UMComEditTextView *chatEditTextView;

@property (nonatomic, strong) UIView *chatEditTextBgView;

@property (nonatomic, strong) NSMutableArray *chatDataArray;

@property (nonatomic, strong) UMComUser *chatUser;

@property (nonatomic, assign) CGRect tableViewOriginFrame;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, assign) CGRect changedFrame;

@property (nonatomic, assign) CGFloat totalHeight;

@end

@implementation UMComForumPrivateChatTableViewController


- (instancetype)initWithUser:(UMComUser *)user
{
    self = [super init];
    if (self) {
        _chatUser = user;
    }
    return self;
}
- (instancetype)initWithPrivateLetter:(UMComPrivateLetter *)privateLetter
{
    self = [self initWithUser:privateLetter.user];
    if (self) {
        _privateLetter = privateLetter;
        self.fetchRequest = [[UMComPrivateMessageRequest alloc] initWithCount:BatchSize toUid:privateLetter.user.uid private_letter_id:privateLetter.letter_id];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.totalHeight = [UIApplication sharedApplication].keyWindow.frame.size.height;
    [self setForumUITitle:self.chatUser.name];
    
    self.tableView.tableFooterView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_Chat_Cell_BgColor);
    
    [self setTitleViewWithTitle:self.privateLetter.user.name];
    self.chatDataArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    if (self.privateLetter) {
        [self loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [UMComSession sharedInstance].unReadNoticeModel.notiByPriMessageCount -= [weakSelf.privateLetter.unread_count integerValue];
            weakSelf.privateLetter.unread_count = @0;
        }];
    }else{
        [UMComPushRequest initChartBoxWithToUser:self.chatUser responese:^(id responseObject, NSError *error) {
            weakSelf.privateLetter = (UMComPrivateLetter *)responseObject;
            if (error) {
                [UMComShowToast showFetchResultTipWithError:error];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else{
                weakSelf.fetchRequest = [[UMComPrivateMessageRequest alloc] initWithCount:BatchSize toUid: weakSelf.privateLetter.user.uid private_letter_id:weakSelf.privateLetter.letter_id];
                [weakSelf loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                    [UMComSession sharedInstance].unReadNoticeModel.notiByPriMessageCount -= [weakSelf.privateLetter.unread_count integerValue];
                    weakSelf.privateLetter.unread_count = @0;                }];
            }
        }];
    }
    
    //创建发送编辑框
    [self creatSenderEditFrameViews];
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.origin.y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    tableViewFrame.size.height = self.tableView.frame.size.height - UMCom_Forum_Chat_SendFrame_Heigt - tableViewFrame.origin.y + [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.tableViewOriginFrame = tableViewFrame;
    _changedFrame = tableViewFrame;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyBoard:)];
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (self.chatEditTextBgView.superview != self.navigationController.view) {
//        [self.w.view addSubview:self.chatEditTextBgView];
//    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hiddenKeyBoard:nil];
    [self.chatEditTextBgView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)creatSenderEditFrameViews
{
    CGFloat chatEditTextBgViewHeight = UMCom_Forum_Chat_SendFrame_Heigt;
    CGFloat itemSpace = UMCom_Forum_Chat_SendFrame_ViewsSpace;
    CGFloat  buttonWidth = UMCom_Forum_Chat_SendButton_Width;
    
    _chatEditTextBgView = [[UIView alloc]initWithFrame:CGRectMake(0, self.totalHeight-chatEditTextBgViewHeight, self.view.frame.size.width, chatEditTextBgViewHeight)];
    _chatEditTextBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    _chatEditTextBgView.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_Chat_Cell_BgColor);
    topLine.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_Chat_SendFrame_LineColor);
    [_chatEditTextBgView addSubview:topLine];
    _chatEditTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(itemSpace, itemSpace, self.view.frame.size.width-buttonWidth-itemSpace*3, chatEditTextBgViewHeight-itemSpace*2)];
    _chatEditTextView.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_Chat_Message_Font);
    _chatEditTextView.layer.cornerRadius = 5;
//    _chatEditTextView.returnKeyType = UIReturnKeySend;

    _chatEditTextView.backgroundColor = [UIColor whiteColor];
    
    [_chatEditTextBgView addSubview:_chatEditTextView];
    [[UIApplication sharedApplication].keyWindow addSubview:_chatEditTextBgView];
    
    UIButton *senderBt = [UIButton buttonWithType:UIButtonTypeCustom];
    senderBt.frame = CGRectMake(self.view.frame.size.width - buttonWidth - itemSpace, itemSpace, buttonWidth, chatEditTextBgViewHeight-itemSpace*2);
    senderBt.layer.cornerRadius = 5;
    senderBt.clipsToBounds = YES;
    [senderBt setTitleColor:UMComColorWithColorValueString(@"#FFFFFF") forState:UIControlStateNormal];
    [senderBt setTitle:@"发送" forState:UIControlStateNormal];
    senderBt.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_Chat_SendButton_NomalColor);
    [senderBt addTarget:self action:@selector(didClickOnSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [_chatEditTextBgView addSubview:senderBt];
}

#pragma mark -

- (void)hiddenKeyBoard:(id)sender
{
    [self.chatEditTextView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endheight = keybordFrame.size.height;
    CGRect editFrame = self.chatEditTextBgView.frame;
    editFrame.origin.y = self.totalHeight - endheight - editFrame.size.height;
    self.chatEditTextBgView.frame = editFrame;

    CGRect frame = self.tableView.frame;
    frame.size.height = self.tableViewOriginFrame.size.height - endheight;
    self.changedFrame = frame;
    self.tableView.frame = frame;
    [self resetTableViewContentOffset];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect editFrame = weakSelf.chatEditTextBgView.frame;
        editFrame.origin.y = self.totalHeight - editFrame.size.height;
        weakSelf.chatEditTextBgView.frame = editFrame;
        CGRect tableFrame = weakSelf.tableView.frame;
        tableFrame.size.height = weakSelf.tableViewOriginFrame.size.height;
        weakSelf.changedFrame = tableFrame;
        self.tableView.frame = tableFrame;
        [weakSelf resetTableViewContentOffset];
    }];
}

- (void)resetTableViewContentOffset
{
    if (self.chatDataArray.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatDataArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }else{
        if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x,  self.tableView.contentSize.height - self.tableView.frame.size.height)];
        }
    }
}

#pragma mark - UITableViewDeleagte
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComMutiText *mutiText = [self.chatDataArray[indexPath.row] valueForKey:kUMComMutitext];
    return mutiText.textSize.height + UMCom_Forum_Chat_DateMessage_Space*2 + UMCom_Forum_Chat_Message_ShortEdge *2 + UMCom_Forum_Chat_DateLabel_Height + UMCom_Forum_Chat_Cell_Space;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComPrivateMessage *privateMessage = [self.chatDataArray[indexPath.row] valueForKey:kUMComPrivateMessage];
    UMComChatRecodTableViewCell *cell = nil;
    if (![privateMessage.creator.uid isEqualToString:[UMComSession sharedInstance].uid]) {//!
        static NSString *leftcellID = @"leftcellID";
        cell = [tableView dequeueReusableCellWithIdentifier:leftcellID];
        if (!cell) {
            cell = [[UMComChatReceivedTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftcellID];
        }
    }else{
        static NSString *rightCellID = @"rightCellID";
        cell = [tableView dequeueReusableCellWithIdentifier:rightCellID];
        if (!cell) {
            cell = [[UMComChatSendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rightCellID];
        }
    }
    UMComMutiText *mutiText = [self.chatDataArray[indexPath.row] valueForKey:kUMComMutitext];
    __weak typeof(self) weakSelf = self;
    cell.clickOnUser = ^(){
        UMComForumUserCenterViewController *userCenter = [[UMComForumUserCenterViewController alloc]initWithUser:privateMessage.creator];
        [weakSelf.navigationController pushViewController:userCenter animated:YES];
    };
    if (indexPath.row < self.chatDataArray.count) {
        [cell reloadTabelViewCellWithMessage:privateMessage mutiText:mutiText cellSize:CGSizeMake(tableView.frame.size.width, mutiText.textSize.height+40)];
    }
    return cell;
}



- (void)refreshScrollViewDidEndDragging:(UIScrollView *)refreshScrollView haveNextPage:(BOOL)haveNextPage
{
    
    self.loadMoreStatusView.haveNextPage = YES;
    //上拉刷新
    if ([self isScrollToBottom:refreshScrollView] && self.loadMoreStatusView.loadStatus != UMComLoading &&  self.refreshControl.refreshing != YES) {
        //执行代理方法
        [self.loadMoreStatusView setLoadStatus:UMComLoading];
        [self loadMoreData];
        
    }else if (refreshScrollView.contentSize.height > refreshScrollView.frame.size.height && self.loadMoreStatusView.loadStatus != UMComLoading && [self isScrollToBottom:refreshScrollView]){
        [self.loadMoreStatusView setLoadStatus:UMComFinish];
    }
}
//
- (void)refreshScrollViewDidScroll:(UIScrollView *)refreshScrollView haveNextPage:(BOOL)haveNextPage
{
    if (self.haveNextPage) {
        if (refreshScrollView.contentOffset.y < -150) {
            [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"松手即可加载"]];
        }else if (refreshScrollView.contentOffset.y < 0){
            [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"下拉可以加载历史聊天记录"]];
        }
    }else{
           [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"已经是最后一页了"]];
    }
    self.loadMoreStatusView.haveNextPage = YES;
    //上拉
    if ([self isBeginScrollBottom:refreshScrollView] && [refreshScrollView isDragging] && self.loadMoreStatusView.loadStatus != UMComLoading  && self.refreshControl.refreshing != YES) {//
        [self.loadMoreStatusView setLoadStatus:UMComNoLoad];
        if ([self isScrollToBottom:refreshScrollView]){
            [self.loadMoreStatusView setLoadStatus:UMComPreLoad];
        }
    }
    else if (self.loadMoreStatusView.loadStatus != UMComLoading && self.loadMoreStatusView.loadStatus != UMComFinish && self.refreshControl.refreshing != YES){
        if ([self isScrollToBottom:refreshScrollView]){
            [self.loadMoreStatusView setLoadStatus:UMComPreLoad];
            self.loadMoreStatusView.indicateImageView.transform = CGAffineTransformIdentity;
        }
    }else if (refreshScrollView.contentOffset.y <= 0){
        [self.loadMoreStatusView hidenVews];
    }
}

//请求下一页
- (void)refreshData
{
    if (self.fetchRequest == nil || self.haveNextPage == NO) {
        [self.refreshControl endRefreshing];
        return;
    }
    [self loadNextPageDataFromServer:nil];
}

//上拉刷新
- (void)loadMoreData
{
    if (self.isLoadFinish == NO) {
        return;
    }
    if (self.fetchRequest == nil) {
        [self.refreshControl endRefreshing];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [weakSelf.loadMoreStatusView setLoadStatus:UMComFinish];
    }];
}

#pragma mark - data handle
- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        for (UMComPrivateMessage *privateMessage in data) {
            [self insertCellWithPrivateMessage:privateMessage isMore:NO];
        }
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.chatDataArray removeAllObjects];
        [self.tableView reloadData];
        
        for (UMComPrivateMessage *privateMessage in data) {
            [self insertCellWithPrivateMessage:privateMessage isMore:NO];
        }
    }
    [self resetTableViewContentOffset];

}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        [tempArray addObjectsFromArray:data];
        for (UMComPrivateMessage *privateMessage in data) {
            [self insertCellWithPrivateMessage:privateMessage isMore:YES];
        }
    }
}

- (void)insertCellWithPrivateMessage:(UMComPrivateMessage *)privateMessage isMore:(BOOL)isMore
{
    CGFloat textWidth = self.view.frame.size.width-(UMCom_Forum_Chat_Icon_Edge*2+UMCom_Forum_Chat_Icon_Width + UMCom_Forum_Chat_Message_ShortEdge*2 + UMCom_Forum_Chat_Message_LongEdge);
    UMComMutiText *mutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(textWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(UMCom_Forum_Chat_Message_Font) string:privateMessage.content lineSpace:2 checkWords:nil textColor:UMComColorWithColorValueString(UMCom_Forum_Chat_ReceivedMsg_TextColor)];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:privateMessage forKey:kUMComPrivateMessage];
    [dataDict setValue:mutiText forKey:kUMComMutitext];
    CGFloat index = 0;
    if (!isMore) {
        [self.chatDataArray addObject:dataDict];
        index = self.chatDataArray.count - 1;
    }else{
        [self.chatDataArray insertObject:dataDict atIndex:0];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}


#pragma mark - sender chat message

- (void)didClickOnSendButton:(UIButton *)sender
{
    [sender setBackgroundColor:UMComColorWithColorValueString(UMCom_Forum_Chat_SendButton_HighLightColor)];
    __weak typeof(self) weakSelf = self;
    if (!self.chatEditTextView.text || self.chatEditTextView.text.length == 0) {
           [sender setBackgroundColor:UMComColorWithColorValueString(UMCom_Forum_Chat_SendButton_NomalColor)];
        return;
    }else{
        [UMComPushRequest sendPrivateMessageWithContent:self.chatEditTextView.text toUser:weakSelf.privateLetter.user responese:^(UMComPrivateMessage *responseObject, NSError *error) {
            [sender setBackgroundColor:UMComColorWithColorValueString(UMCom_Forum_Chat_SendButton_NomalColor)];
            if (!error) {
                weakSelf.chatEditTextView.text = nil;
                [weakSelf insertCellWithPrivateMessage:responseObject isMore:NO];
            }else{
                [weakSelf.chatEditTextView resignFirstResponder];
                [UMComShowToast showFetchResultTipWithError:error];
            }
        }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


@implementation UMComChatRecodTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.bgImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.bgImageView];
        
        self.iconImaeView = [[[UMComImageView imageViewClassName] alloc]init];
        self.iconImaeView.userInteractionEnabled = YES;
        self.iconImaeView.clipsToBounds = YES;
        [self.contentView addSubview:self.iconImaeView];

        self.chatContentView = [[UMComMutiStyleTextView alloc]init];
        self.chatContentView.backgroundColor = [UIColor clearColor];
        [self.bgImageView addSubview:self.chatContentView];
        
        self.dateLabel = [[UILabel alloc]init];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_Chat_DateString_Font);
        self.dateLabel.textColor = UMComColorWithColorValueString(UMCom_Forum_Chat_Date_TextColor);
        [self.contentView addSubview:self.dateLabel];
        self.contentView.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_Chat_Cell_BgColor);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOnUser:)];
        [self.iconImaeView addGestureRecognizer:tap];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)clickOnUser:(id)sender
{
    if (_clickOnUser) {
        _clickOnUser();
    }
}

//- (void)clickOnCell:()

- (void)reloadTabelViewCellWithMessage:(UMComPrivateMessage *)privateMessage mutiText:(UMComMutiText *)mutiText cellSize:(CGSize)size
{
    [self.iconImaeView setImageURL:privateMessage.creator.icon_url.small_url_string placeHolderImage:UMComImageWithImageName(@"um_forum_user_smile_gray")];
    if (privateMessage.create_time) {
        self.dateLabel.text = createTimeString(privateMessage.create_time);
    }else{
        self.dateLabel.text = [[NSDate date] description];
    }
    [self.chatContentView setMutiStyleTextViewWithMutiText:mutiText];
    
}

@end


@implementation UMComChatReceivedTableViewCell
{
    CGFloat imageLeft;
    CGFloat imageWidth;
    CGFloat dateLabelHeight;
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageLeft = UMCom_Forum_Chat_Icon_Edge;
        imageWidth = UMCom_Forum_Chat_Icon_Width;
        dateLabelHeight = UMCom_Forum_Chat_DateLabel_Height;
        UIImage *resizableImage = [UMComImageWithImageName(@"um_forum_chat_bg_white") resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 5, 20) resizingMode:UIImageResizingModeStretch];
        self.bgImageView.image = resizableImage;
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

- (void)reloadTabelViewCellWithMessage:(UMComPrivateMessage *)privateMessage mutiText:(UMComMutiText *)mutiText cellSize:(CGSize)size
{
    [super reloadTabelViewCellWithMessage:privateMessage mutiText:mutiText cellSize:size];
    self.iconImaeView.frame = CGRectMake(imageLeft, imageLeft, imageWidth, imageWidth);
    self.iconImaeView.layer.cornerRadius = self.iconImaeView.bounds.size.height/2;
    CGFloat commonOriginX = imageLeft + imageLeft/2 + imageWidth;
    CGFloat bgChatImageWidth = mutiText.textSize.width + UMCom_Forum_Chat_Message_ShortEdge * 2 + 2;
    CGFloat bgImageHeight = mutiText.textSize.height + UMCom_Forum_Chat_Message_ShortEdge * 2;
    self.bgImageView.frame = CGRectMake(commonOriginX, imageLeft, bgChatImageWidth, bgImageHeight);
    self.chatContentView.frame = CGRectMake(UMCom_Forum_Chat_Message_ShortEdge+3, UMCom_Forum_Chat_Message_ShortEdge, mutiText.textSize.width, mutiText.textSize.height);
    self.dateLabel.frame = CGRectMake(self.bgImageView.frame.origin.x + UMCom_Forum_Chat_Message_ShortEdge, self.bgImageView.frame.origin.y + bgImageHeight + UMCom_Forum_Chat_DateMessage_Space, size.width-commonOriginX, dateLabelHeight);
}

@end


@implementation UMComChatSendTableViewCell
{
    CGFloat imageRight;
    CGFloat imageWidth;
    CGFloat dateLabelHeight;
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageRight = UMCom_Forum_Chat_Icon_Edge;
        imageWidth = UMCom_Forum_Chat_Icon_Width;
        dateLabelHeight = UMCom_Forum_Chat_DateLabel_Height;
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        UIImage *resizableImage = [UMComImageWithImageName(@"um_forum_chat_bg_blue") resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 5, 20) resizingMode:UIImageResizingModeStretch];
        self.bgImageView.image = resizableImage;
        self.dateLabel.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void)reloadTabelViewCellWithMessage:(UMComPrivateMessage *)privateMessage mutiText:(UMComMutiText *)mutiText cellSize:(CGSize)size
{
    [super reloadTabelViewCellWithMessage:privateMessage mutiText:mutiText cellSize:size];
    self.iconImaeView.frame = CGRectMake(size.width-imageRight-imageWidth, imageRight, imageWidth, imageWidth);
    self.iconImaeView.layer.cornerRadius = self.iconImaeView.bounds.size.height/2;
    CGFloat bgChatImageWidth = mutiText.textSize.width + UMCom_Forum_Chat_Message_ShortEdge*2 + 2;
    CGFloat bgImageHeight = mutiText.textSize.height + UMCom_Forum_Chat_Message_ShortEdge * 2;
    CGFloat bgImageRigtEdge = imageRight+ imageRight/2 + imageWidth;
    self.bgImageView.frame = CGRectMake(size.width - bgChatImageWidth - bgImageRigtEdge, UMCom_Forum_Chat_Icon_Edge, bgChatImageWidth, bgImageHeight);
    self.chatContentView.frame = CGRectMake(UMCom_Forum_Chat_Message_ShortEdge, UMCom_Forum_Chat_Message_ShortEdge, mutiText.textSize.width, mutiText.textSize.height);
    
    CGRect dateFrame = self.dateLabel.frame;
    CGFloat rightEdge = UMCom_Forum_Chat_Message_ShortEdge + self.iconImaeView.frame.size.width + imageRight*2;
    dateFrame.size.width = size.width - UMCom_Forum_Chat_Message_LongEdge - rightEdge;
    dateFrame.origin.x = size.width - rightEdge - dateFrame.size.width;
    dateFrame.size.height = UMCom_Forum_Chat_DateLabel_Height;
    dateFrame.origin.y = self.bgImageView.frame.origin.y + bgImageHeight + UMCom_Forum_Chat_DateMessage_Space;
    self.dateLabel.frame = dateFrame;
}
@end