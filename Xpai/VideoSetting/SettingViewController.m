//
//  SettingViewController.m
//  XpaiLiving
//
//  Created by xuming on 13-09-27.
//  Copyright (c) 2013年 沃安科技 . All rights reserved.
//
#import "SettingViewController.h"
#import "SettingConfig.h"
#import "VideoParamViewController.h"
#import "VideoRecordModeController.h"
#import "XpaiInterface.h"

static const int  PARAM_TYPE = 100;
static const int  RECORD_TYPE = 110;
static const int  VOLUME_SET = 120;

@implementation SettingViewController
@synthesize settingTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"拍摄参数设置";
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem* leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
        self.navigationItem.leftBarButtonItem = leftItem;
        [leftItem release];
        
        _dataSourceArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle
-(void)viewWillAppear:(BOOL)animated
{
    NSString *videoSolution = nil;
    if ([SettingConfig sharedInstance]._videoResolution ==RESOLUTION_LOW) {
        videoSolution = [NSString stringWithFormat:@"视频分辨率 (192*144)"];
    }else if ([SettingConfig sharedInstance]._videoResolution ==RESOLUTION_MEDIUM) {
        videoSolution = [NSString stringWithFormat:@"视频分辨率 (480*360)"];
    }else if ([SettingConfig sharedInstance]._videoResolution ==RESOLUTION_VGA){
        videoSolution = [NSString stringWithFormat:@"视频分辨率 (640*480)"];
    }else if ([SettingConfig sharedInstance]._videoResolution ==RESOLUTION_HIGH) {
        videoSolution = [NSString stringWithFormat:@"视频分辨率 (1280*720)"];
    }
    NSString *videoWorkMode = nil;
    if ([SettingConfig sharedInstance]._recordMode == HARDWARE_ENCODER_WITH_FULL_UPLOAD) {
        videoWorkMode = [NSString stringWithFormat:@"视频录制模式 (全直播)"];
    }else if ([SettingConfig sharedInstance]._recordMode == HARDWARE_ENCODER_LOW_DELAY) {
        videoWorkMode = [NSString stringWithFormat:@"视频录制模式 (半直播)"];
    }else if ([SettingConfig sharedInstance]._recordMode == HARDWARE_SOFTWARE_ENCODER_LOW_DELAY) {
        videoWorkMode = [NSString stringWithFormat:@"视频录制模式 (软编直播)"];
    }else if([SettingConfig sharedInstance]._recordMode == HARDWARE_ENCODER_STREAM){
        videoWorkMode = [NSString stringWithFormat:@"视频录制模式(IOS8优化)"];
    }
    
    [_dataSourceArray removeAllObjects];
    NSArray *array1 = [[NSArray alloc]initWithObjects:
              [NSDictionary dictionaryWithObjectsAndKeys:
               videoSolution, @"kName",
               @"qq.png", @"kImage",
               [NSNumber numberWithInt:PARAM_TYPE],@"kType",nil],
              [NSDictionary dictionaryWithObjectsAndKeys:
               videoWorkMode, @"kName",
               @"qq.png", @"kImage",
               [NSNumber numberWithInt:RECORD_TYPE],@"kType",nil],
              [NSDictionary dictionaryWithObjectsAndKeys:
               @"增音调节", @"kName",
               @"qq.png", @"kImage",
               [NSNumber numberWithInt:VOLUME_SET],@"kType",nil],
              nil];

    
    [_dataSourceArray addObject:array1];
    [array1 release];

    [settingTableView reloadData];

}

- (void)dealloc
{
    [settingTableView release];
    [_dataSourceArray release];
    [super dealloc];
}
 
#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [_dataSourceArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSArray* array = [_dataSourceArray objectAtIndex:section];
    return [array count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"SettingTableViewCell";
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    NSArray* array = [_dataSourceArray objectAtIndex:indexPath.section];
    NSDictionary* dict = [array objectAtIndex:indexPath.row];
    NSNumber* number = [dict valueForKey:@"kType"];
    cell.textLabel.text = [dict valueForKey:@"kName"];
        
    if([number intValue]==PARAM_TYPE || [number intValue]==RECORD_TYPE ){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if([number intValue]==VOLUME_SET){
        cell.accessoryType = UITableViewCellAccessoryNone;
        UISlider *volumeSlider = [[[UISlider alloc]initWithFrame:CGRectMake(85, 7, 220, 31)] autorelease];
        [volumeSlider addTarget:self action:@selector(VolumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
        volumeSlider.value = [SettingConfig sharedInstance]._volume;
        volumeSlider.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:volumeSlider];
    }

    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    NSArray* array = [_dataSourceArray objectAtIndex:indexPath.section];
    NSDictionary* dict = [array objectAtIndex:indexPath.row];
    NSNumber* number = [dict valueForKey:@"kType"];
    
    if([number intValue]==PARAM_TYPE){
        VideoParamViewController* pView = [[VideoParamViewController alloc]initWithNibName:@"VideoParamViewController" bundle:nil];
        [self.navigationController pushViewController:pView animated:YES];
        [pView release];        
    }
    if ([number intValue] == RECORD_TYPE){
        VideoRecordModeController *videoRecordModeView = [[VideoRecordModeController alloc]initWithNibName:@"VideoRecordModeController" bundle:nil];
        [self.navigationController pushViewController:videoRecordModeView animated:YES];
        [videoRecordModeView release];
    }
}

- (void)VolumeSliderChanged:(id)sender
{
    UISlider *volumeSlider = (UISlider *)sender;
    [SettingConfig sharedInstance]._volume = volumeSlider.value;
    [[SettingConfig sharedInstance] WriteDataToFile];
}

@end
