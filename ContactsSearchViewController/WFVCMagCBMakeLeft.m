//
//  WFMagCVMakeLeftViewController.m
//  WonderFie
//
//  Created by Leo on 15/2/10.
//  Copyright (c) 2015年 Heimavista. All rights reserved.
//

#import "WFVCMagCBMakeLeft.h"
#import "WFMagPageShower.h"
#import "WFVCMagCBMakeCenter.h"
#import "WFMGMagazineMake.h"
#import "WFBookNameAlertView.h"

#define WFSpringboardCellIdentifier     @"WFSpringboardCellIdentifier"

static const NSInteger kTagOfSaveAlert = 32;

typedef NS_ENUM(NSInteger, LeftSlideState)
{
    LeftSlideStateNormal = 0,
    LeftSlideStateEditing = 1
};

@interface WFVCMagCBMakeLeft ()<HVSpringboardDataSource,HVSpringboardDelegate,HVSpringboardDelegateFlowLayout,HVSpringboardCellDelegate,CustomIOS7AlertViewDelegate>
{
    
}

@property (nonatomic,strong) UIView * mainContainer;
@property (nonatomic,assign) LeftSlideState viewState;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UIButton * navSaveBtn;
@property (nonatomic,strong) UIButton * navCloseBtn;
@property (nonatomic,strong) UIButton * addButton;
@property (nonatomic,strong) NSMutableArray * editPageList;
@property (nonatomic,strong) UICollectionView * collectionView;


@end

@implementation WFVCMagCBMakeLeft
@synthesize viewState = _viewState;
@synthesize titleLabel = _titleLabel;
@synthesize navSaveBtn = _navSaveBtn;
@synthesize addButton = _addButton;
//@synthesize gridView = _gridView;
@synthesize editPageList = _editPageList;

WF_STATUSBAR_STYLE_GLOBAL

- (void) viewDidLoad
{
    [super viewDidLoad];
    //ga
    WFGAConfig * ga = [WFGAConfig gaConfigByKey:GAKey_A_Mag_Begin];
    self.screenName = ga.screenName;
    //google 分析
    WFGAConfig * gaConfig = [WFGAConfig gaConfigByKey:GAKey_A_Mag_Begin];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:gaConfig.category
                                                          action:gaConfig.action
                                                           label:@""
                                                           value:nil] build]];
    [self p_buildViews];
    [self p_buildButtons];
    [self viewDidLayoutSubviews];
    
    WF_RESET_STATUSBAR
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self p_setUpDataSource];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;
    CGRect f1 = bounds;
    f1.size.width = [self.parentVC leftSlideWidth];
    self.mainContainer.frame = f1;
    
    CGRect f2 = CGRectMake(10, 40, 40, 40);
    self.navCloseBtn.frame = f2;
    
    CGRect f3 = CGRectMake(0, 0, 110, f2.size.height);
    f3.origin.x = (f1.size.width - f3.size.width) * 0.5;
    f3.origin.y = CGRectGetMinY(f2);
    self.titleLabel.frame = f3;
    
    CGRect f4 = f2;
    f4.size.width = 50;
    f4.origin.x = f1.size.width - f4.size.width;
    self.navSaveBtn.frame = f4;
    
    CGRect f5 = CGRectMake(0, 0, 80, 44);
    f5.origin.x = (f1.size.width - f5.size.width) * 0.5;
    f5.origin.y = f1.size.height - 46;
    self.addButton.frame = f5;
    
    CGRect f6 = self.mainContainer.bounds;
    f6.size.width = f6.size.width - 10;
    f6.size.height = f6.size.height - 160;
    f6.origin.x = (f1.size.width - f6.size.width) * 0.5;
    f6.origin.y = (f1.size.height - f6.size.height) * 0.5 + 20;
    self.collectionView.frame = f6;
    
}

#pragma mark - build methods

- (void) p_buildViews
{
    self.mainContainer = [[UIView alloc] init];
    self.mainContainer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.mainContainer];
    
    self.navCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navCloseBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    [self.navCloseBtn setImage:UILocalizedIcon_WFBook(@"mgz_ic_title_close.png", nil) forState:UIControlStateNormal];
    [self.navCloseBtn setBackgroundColor:[UIColor clearColor]];
    [self.navCloseBtn addTarget:self action:@selector(p_closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.mainContainer addSubview:self.navCloseBtn];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.mainContainer addSubview:self.titleLabel];
    [self p_refreshTitle];
    
    self.navSaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.navSaveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [self.navSaveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navSaveBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.navSaveBtn setTitle:NSLocalizedString_WFBook(@"wf_basic_finish", nil) forState:UIControlStateNormal];
    [self.navSaveBtn addTarget:self action:@selector(p_saveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.mainContainer addSubview:self.navSaveBtn];
    
    //add button
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addButton setImageEdgeInsets:UIEdgeInsetsMake(8, 22, 8, 22)];
    self.addButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.addButton setImage:UILocalizedIcon_WFBook(@"book_menu_add.png", nil) forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(p_addAction) forControlEvents:UIControlEventTouchUpInside];
    [self.mainContainer addSubview:self.addButton];
    
    
    HVSpringboardLayout * layout = [[HVSpringboardLayout alloc] initWithType:HVSB_LayoutTypeScroll];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[WFMagSBViewCell class] forCellWithReuseIdentifier:WFSpringboardCellIdentifier];
    [self.mainContainer addSubview:self.collectionView];
    
}

- (void) p_buildButtons
{
    
}

- (void) p_setUpDataSource
{
    self.editPageList = [[NSMutableArray alloc] initWithArray:self.parentVC.pageList];
    self.viewState = LeftSlideStateNormal;
    self.collectionView.hvEditing = NO;
    [self.collectionView reloadData];
    [self p_refreshTitle];
}

- (void) reset
{
    [self p_cancelSortView];
    [self p_setUpDataSource];
}

#pragma mark - action methods

- (void) p_closeAction
{
    if (self.viewState == LeftSlideStateNormal)
    {
        [self.parentVC.navigationController popViewControllerAnimated:YES];
    }
    else if (self.viewState == LeftSlideStateEditing)
    {
        [self p_cancelSortView];
        [self p_setUpDataSource];
    }
}

- (void) p_saveAction
{
    if (self.viewState == LeftSlideStateEditing)
    {
        [self p_cancelSortView];
        [self p_refreshTitle];
        NSUInteger cellCount = [self.editPageList count];
        for (int i = 0; i < cellCount; i++) {
            NSIndexPath * cellIndex = [NSIndexPath indexPathForItem:i inSection:0];
            WFMagSBViewCell * cell = (WFMagSBViewCell *)[self.collectionView cellForItemAtIndexPath:cellIndex];
            cell.sbEditing = NO;
        }
        [self.parentVC.pageList removeAllObjects];
        [self.parentVC.pageList addObjectsFromArray:self.editPageList];
        WFVCMagCBMakeCenter * centerView = (WFVCMagCBMakeCenter *)self.parentVC.centerViewController;
        [centerView reloadData];
    }
    else if (self.viewState == LeftSlideStateNormal)
    {
        
        WFBookNameAlertView * saveAlert = [[WFBookNameAlertView alloc] init];
        saveAlert.tag = kTagOfSaveAlert;
        saveAlert.delegate = self;
        [saveAlert wf_show];
        saveAlert.textField.text = NSLocalizedString_WFBook(@"wf_book_default_name", nil);
        
    }
}

- (void) p_addAction
{
    WFGAConfig * gaConfig = [WFGAConfig gaConfigByKey:GAKey_A_Mag_Add];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:gaConfig.category
                                                          action:gaConfig.action
                                                           label:@""
                                                           value:nil] build]];

    WFModelMagTemplateDetail * templateDetail = [WFModelMagTemplateDetail magCBRandomDetailAll];
    WFDBModelMagPage * page = [[WFDBModelMagPage alloc] initWithTemplateDetail:templateDetail];
    
    __weak typeof(self) selfWR = self;
    NSInteger listCount = [self.editPageList count];
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDAddedTo:self.view];
    hud.removeFromSuperViewOnHide = YES;
    [[WFMGMagazineMake sharedInstance] updatePageThumb:page complete:^(WFDBModelMagPage *pageN) {
        [hud hide:YES];
        [selfWR.editPageList addObject:pageN];
        [selfWR.parentVC.pageList addObject:page];
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:listCount inSection:0];
        [selfWR.collectionView hv_insertItemAtIndexPath:indexPath];
        WFVCMagCBMakeCenter * centerView = (WFVCMagCBMakeCenter *)selfWR.parentVC.centerViewController;
        [centerView selectItemAtIndex:listCount];
    }];
}

#pragma mark - private methods

- (void) p_refreshTitle
{
    NSUInteger pageCount = [self.parentVC.pageList count];
    NSString * titleStr = [NSString stringWithFormat:@"%@(%d)",NSLocalizedString_WFBook(@"wf_book_make_page_all", nil),(int)pageCount];
    [self.titleLabel setText:titleStr];
}

- (void) p_cancelSortView
{
    self.viewState = LeftSlideStateNormal;
    [self.navSaveBtn setTitle:NSLocalizedString_WFBook(@"wf_basic_save", nil) forState:UIControlStateNormal];
    self.addButton.hidden = NO;
    self.collectionView.hvEditing = NO;
}

#pragma mark - HVSpringboardDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.editPageList count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WFDBModelMagPage * page = (WFDBModelMagPage *)[self.editPageList objectAtIndex:indexPath.row];
    WFMagSBViewCell * cell = (WFMagSBViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:WFSpringboardCellIdentifier forIndexPath:indexPath];
    
    [cell bindPage:page];
    cell.delegate = self;
    if (self.viewState == LeftSlideStateEditing)
    {
        cell.sbEditing = YES;
    }
    else
    {
        cell.sbEditing = NO;
    }
    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect collFrame = collectionView.frame;
    CGFloat cellWidth = collFrame.size.width / 3.0;
    CGFloat cellHeight = cellWidth * 1.5;
    CGSize sizeOfItem = CGSizeMake(cellWidth , cellHeight);
    return sizeOfItem;
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    return inset;
}

- (void) hvsb_collectionView:(UICollectionView *)collectionView editStateDidChanged:(BOOL)editing
{
    if (editing)
    {
        self.viewState = LeftSlideStateEditing;
        self.addButton.hidden = YES;
        [self.navSaveBtn setTitle:NSLocalizedString_WFBook(@"wf_basic_confirm", nil) forState:UIControlStateNormal];
        [self.titleLabel setText:NSLocalizedString_WFBook(@"wf_book_make_sort_delete", nil)];
        NSUInteger cellCount = [self.editPageList count];
        for (int i = 0; i < cellCount; i++) {
            NSIndexPath * cellIndex = [NSIndexPath indexPathForItem:i inSection:0];
            WFMagSBViewCell * cell = (WFMagSBViewCell *)[collectionView cellForItemAtIndexPath:cellIndex];
            cell.sbEditing = YES;
        }
    }
}

- (void) hvsb_collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    //google分析
    WFGAConfig * gaConfig = [WFGAConfig gaConfigByKey:GAKey_A_Mag_Sort];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:gaConfig.category
                                                          action:gaConfig.action
                                                           label:@""
                                                           value:nil] build]];

    WFDBModelMagPage * pageModel = (WFDBModelMagPage *)[self.editPageList objectAtIndex:fromIndexPath.row];
    [self.editPageList removeObjectAtIndex:fromIndexPath.row];
    [self.editPageList insertObject:pageModel atIndex:toIndexPath.row];
}

#pragma mark - HVSpringboardDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) selfWR = self;
    [self.drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        WFVCMagCBMakeCenter * centerView = (WFVCMagCBMakeCenter *)selfWR.parentVC.centerViewController;
        [centerView selectItemAtIndex:indexPath.row];
    }];
}

#pragma mark - HVSpringboardDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - HVSpringboardCellDelegate

- (void) hvsb_cellDidDeleted:(HVSpringboardCell *)cell
{
    //google分析
    WFGAConfig * gaConfig = [WFGAConfig gaConfigByKey:GAKey_A_Mag_Delete];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:gaConfig.category
                                                          action:gaConfig.action
                                                           label:@""
                                                           value:nil] build]];

    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    [self.editPageList removeObjectAtIndex:indexPath.row];
    [self.collectionView hv_deleteItemAtIndexPath:indexPath];
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    WFBookNameAlertView * alert = (WFBookNameAlertView *) alertView;
    if (alert.tag == kTagOfSaveAlert && buttonIndex == 1) {
        if (buttonIndex == 1) {
            //google分析
            WFGAConfig * gaConfig = [WFGAConfig gaConfigByKey:GAKey_A_Mag_Save];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:gaConfig.category
                                                                  action:gaConfig.action
                                                                   label:@""
                                                                   value:nil] build]];

            NSString * bookName = alert.textField.text;
            if (bookName.length == 0) {
                bookName = NSLocalizedString_WFBook(@"wf_book_default_name", nil);
            }
            BOOL publicYn = alert.bookPublic;
            WFBookPublicStat stat = (publicYn == YES)?WFBookPublicStatOpen:WFBookPublicStatClose;
            [alert close];
            
            __weak typeof(self) selfWR = self;
            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDAddedTo:self.view];
            hud.removeFromSuperViewOnHide = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray * images = [[NSMutableArray alloc] init];
                NSUInteger dataCount = [selfWR.parentVC.pageList count];
                for (int i = 0; i < dataCount; i++) {
                    @autoreleasepool {
                        
                        WFDBModelMagPage * pageModel = (WFDBModelMagPage *)[selfWR.parentVC.pageList objectAtIndex:i];
                        WFMagPageShower * pageShower = [[WFMagPageShower alloc] initWithFrame:CGRectMake(0, 0, 320, 480) pageModel:pageModel];
                        __block UIImage * screenShot;
                        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                        
                        [pageShower screenshotWithCompleteBlock:^(UIImage *image) {
                            screenShot = image;
                            dispatch_semaphore_signal(sem);
                        }];
                        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
                        dispatch_semaphore_wait(sem, time);
                        NSString * picturePath = [[WFMGMagazineMake sharedInstance] saveMagazinePicture:screenShot];
                        if (picturePath) {
                            [images addObject:picturePath];
                        }
                    }
                }
                WFDBModelBook * magazine = [[WFMGMagazineMake sharedInstance] addNewMagazine:bookName publicStat:stat images:images pageModels:selfWR.parentVC.pageList];
                if (selfWR.parentVC.magTemplate.magType == WFModelMagTemplateTypeCombine) {
                    magazine.tempType = WFBookTemplateTypeCombine;
                }
                else
                {
                    magazine.tempType = WFBookTemplateTypeWhole;
                }
                magazine.tempSeq = selfWR.parentVC.magTemplate.magSeq;
                [magazine saveToDB];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:WFNotificationBookShelfReload object:nil userInfo:nil];
                    selfWR.parentVC.book = magazine;
                    if ([selfWR.parentVC.delegate respondsToSelector:@selector(WFVC_magCBMakeViewDidFinished:)]) {
                        [selfWR.parentVC.delegate WFVC_magCBMakeViewDidFinished:selfWR.parentVC];
                    }
                    if (selfWR.parentVC.whenDone)
                    {
                        selfWR.parentVC.whenDone(selfWR.parentVC);
                    }
                    else
                        [selfWR.parentVC.navigationController popViewControllerAnimated:YES];
                });
            });
        }
    }
    else
    {
        [alert close];
    }
    
}


@end

//-------------WFMagGridViewCell------------------//

@interface WFMagSBViewCell ()

@property (nonatomic,strong) UIButton * deleteButton;
@property (nonatomic,strong) UIImageView * pageShower;

@end

@implementation WFMagSBViewCell

@synthesize pageShower = _pageShower;
@synthesize pageModel = _pageModel;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.pageShower = [[UIImageView alloc] init];
        self.pageShower.backgroundColor = [UIColor blackColor];
        self.pageShower.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.pageShower];
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.backgroundColor = [UIColor clearColor];
        [self.deleteButton setImage:UILocalizedIcon_WFBook(@"mgz_page_delete.png", nil) forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(p_deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteButton];
        self.deleteButton.hidden = YES;
        self.pageShower.layer.borderWidth = 1.0f;
        self.pageShower.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

- (void) bindPage:(WFDBModelMagPage *)pageModel
{
    [self.pageShower setImage:pageModel.pageThumb];
}

- (void) p_deleteAction
{
    if ([self.delegate respondsToSelector:@selector(hvsb_cellDidDeleted:)])
    {
        [self.delegate hvsb_cellDidDeleted:self];
    }
}

- (void) setSbEditing:(BOOL)sbEditing
{
    [super setSbEditing:sbEditing];
    if (sbEditing == YES)
    {
        self.deleteButton.hidden = NO;
    }
    else
    {
        self.deleteButton.hidden = YES;
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGRect f1 = bounds;
    f1.size.width = f1.size.width - 16;
    f1.size.height = f1.size.height - 24;
    f1.origin.x = 8;
    f1.origin.y = 12;
    self.pageShower.frame = f1;
    
    CGRect f2 = CGRectMake(0, 0, 15, 15);
    f2.origin.x = CGRectGetMinX(f1) - 7.5;
    f2.origin.y = CGRectGetMinY(f1) - 7.5;
    self.deleteButton.frame = f2;
    
}

@end
//-----------WFMagGridViewCell End----------------//
