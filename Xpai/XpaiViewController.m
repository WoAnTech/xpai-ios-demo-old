//
//  XpaiViewController.m
//  Xpai
//
//  Created by 徐功伟 on 13-04-01.
//  Copyright 2011年 沃安科技. All rights reserved.
//

#import "XpaiViewController.h"
#import "RecordViewController.h"
#import "InputViewController.h"
#import "SettingViewController.h"
#import "WoanPlayerInterface.h"
#import "XpaiInterface.h"

@implementation XpaiViewController

@synthesize cTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"XpaiDemo";
        
        dataSourceAry =[[NSMutableArray alloc]initWithCapacity:2];
        NSArray *array1 = [[NSArray alloc] initWithObjects:@"拍摄Demo",@"拍摄参数设置", nil];
        NSArray *array2 = [[NSArray alloc] initWithObjects:@"播放器Demo", nil];
        
        [dataSourceAry addObject:array1];
        [dataSourceAry addObject:array2];
        [array1 release];
        [array2 release];
    }
    return self;
}

- (void)dealloc
{
    [cTableView release];
    [dataSourceAry release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSourceAry count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [NSString stringWithFormat:@"拍摄SDK-%@",[XpaiInterface getXpaiLibVersion]];
    }else if (section == 1){
        return [NSString stringWithFormat:@"播放器SDK-%@",[WoanPlayerInterface getWoanPlayerLibVersion]];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dataSourceAry objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XpaiDemoTableViewCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableViewCell"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [[dataSourceAry objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                RecordViewController *recordController = [[RecordViewController alloc] initWithNibName:@"RecordView" bundle:0];
                [self.navigationController presentModalViewController:recordController animated:NO];
                [recordController release];
                break;
            }
            case 1:{
                SettingViewController *settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
                [self.navigationController pushViewController:settingViewController animated:YES];
                [settingViewController release];
                break;
            }
            default:
                break;
        }
    }else{
        InputViewController *inputViewController = [[InputViewController alloc] initWithNibName:@"InputViewController" bundle:nil];
        [self.navigationController pushViewController:inputViewController animated:YES];
        [inputViewController release];
    }
    
}

@end
