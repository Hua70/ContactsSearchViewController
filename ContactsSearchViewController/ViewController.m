//
//  ViewController.m
//  ContactsSearchViewController
//
//  Created by YWH on 15/7/31.
//  Copyright (c) 2015年 YWH. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>
#define RGBACOLOR(R,G,B,A) [UIColor colorWithRed:(R)/255.0f green:(G)/255.0f blue:(B)/255.0f alpha:(A)]

#pragma mark - 设备型号识别
#define is_IOS_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#pragma mark - 硬件
#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,MFMessageComposeViewControllerDelegate>
{
    UITableView *_tableView;
    UISearchBar *mySearchBar;
    UISearchDisplayController *mySearchDisplayController;
    NSMutableDictionary *contentsDic; // 每行的内容
    NSArray *sectionTitles; // 每个分区的标题
    NSMutableArray *_resultsData;//搜索结果数据
}
@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    [self setEdgesForExtendedLayout:/*UIRectEdgeBottom | */UIRectEdgeLeft | UIRectEdgeRight];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initDataSource];
    [self initTableView];
    [self initMysearchBarAndMysearchDisPlay];
}



-(void)setExtraCellLineHidden:(UITableView*)tableView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
-(void)initDataSource
{
    sectionTitles = [[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#", nil];
    
    contentsDic =(NSMutableDictionary*)@{@"A":@[@"阿伟",@"阿姨",@"阿三"],@"C": @[@"蔡芯",@"成龙",@"陈鑫",@"陈丹",@"成名"],@"F": @[@"芳仔",@"房祖名",@"方大同",@"芳芳",@"范伟"],@"G":@[@"郭靖",@"郭美美",@"过儿",@"过山车"],@"H":@[@"何仙姑",@"和珅",@"郝歌",@"好人"],@"M": @[@"妈妈",@"毛主席"]};
    _resultsData = [[NSMutableArray alloc] init];
}


- (void)initTableView
{
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-44-66);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableFooterView = [[UIView alloc] init];
    //改变索引的颜色
    _tableView.sectionIndexColor = [UIColor colorWithRed:0 green:0.51 blue:1 alpha:1];
    //改变索引选中的背景颜色
    _tableView.sectionIndexTrackingBackgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_tableView];
   
}

-(void)initMysearchBarAndMysearchDisPlay
{
    mySearchBar  = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    mySearchBar.backgroundColor =  [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    mySearchBar.delegate = self;
    mySearchBar.placeholder = @"search placeholder";
    [self.view addSubview:mySearchBar];
    
    //    //设置选项
    //加入列表的header里面
    mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
    mySearchDisplayController.delegate = self;
    mySearchDisplayController.searchResultsDataSource = self;
    mySearchDisplayController.searchResultsDelegate = self;
     [self setExtraCellLineHidden:mySearchDisplayController.searchResultsTableView];
    
    
}

#pragma mark UISearchBar and UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller

shouldReloadTableForSearchString:(NSString *)searchString

{
    //一旦SearchBar輸入內容有變化，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    
    [self filterContentForSearchText:searchString
                               scope:[mySearchBar scopeButtonTitles][mySearchBar.selectedScopeButtonIndex]];
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller

shouldReloadTableForSearchScope:(NSInteger)searchOption

{
    //如果设置了选项，当Scope Button选项有變化的时候，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    
    // Return YES to cause the search result table view to be reloaded.
    
    [self filterContentForSearchText:mySearchBar.text
                               scope:mySearchBar.scopeButtonTitles[searchOption]];
    
    return YES;
}

//源字符串内容是否包含或等于要搜索的字符串内容
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSMutableArray *tempResults = [NSMutableArray array];
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    for (NSArray *array in [contentsDic allValues]) {
        for (int i = 0; i < array.count; i++) {
            NSString *storeString = array[i];
            NSRange storeRange = NSMakeRange(0, storeString.length);
            NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
            if (foundRange.length) {
                [tempResults addObject:storeString];
            }
        }
    }
    
    [_resultsData removeAllObjects];
    [_resultsData addObjectsFromArray:tempResults];
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //searchDisplayController自身有一个searchResultsTableView，所以在执行操作的时候首先要判断是否是搜索结果的tableView，如果是显示的就是搜索结果的数据，如果不是，则显示原始数据。
    if(tableView == mySearchDisplayController.searchResultsTableView)
    {
        
        return _resultsData.count;
    }
    else
    {
        return  [[contentsDic objectForKey:[[contentsDic allKeys] objectAtIndex:section]] count];
    }
    
}

// 每个分区的页眉
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView != mySearchDisplayController.searchResultsTableView)
    {
        return [[contentsDic allKeys] objectAtIndex:section];
    }else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *myCell = @"cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }
    
    if (tableView == mySearchDisplayController.searchResultsTableView)
    {
        cell.textLabel.text = _resultsData[indexPath.row];
    }
    else
    {
        cell.textLabel.text =[[contentsDic objectForKey:[[contentsDic allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
    
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (tableView == mySearchDisplayController.searchResultsTableView)
    {
        return 1;
    }else
    {
        return contentsDic.count;
    }
}
//返回索引数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView != mySearchDisplayController.searchResultsTableView)
    {
        return [contentsDic allKeys];
    }else
    {
        return nil;
    }
}

//响应点击索引时的委托方法
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    // 获取所点目录对应的indexPath值
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    
    // 让table滚动到对应的indexPath位置
    [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    return index;
}


#pragma mark--tableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL canSendSMS = [MFMessageComposeViewController canSendText];
    if (canSendSMS) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.navigationBar.tintColor = [UIColor blackColor];
        picker.body = @"面朝大海，春暖花开";
        picker.recipients = [NSArray arrayWithObjects:@"15960202364",@"18059040465", nil];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


//取消searchbar背景色
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

