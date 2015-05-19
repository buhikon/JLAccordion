//
//  ViewController.m
//  AccordionDemo
//
//  Created by Joey L. on 5/19/15.
//  Copyright (c) 2015 Joey L. All rights reserved.
//

#import "ViewController.h"
#import "ParentTableViewCell.h"
#import "ChildTableViewCell.h"
#import "JLAccordionDataController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, JLAccordionDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) JLAccordionDataController *accordionDataController;

@property (strong, nonatomic) NSMutableArray *parentData;
@property (strong, nonatomic) NSMutableArray *childData;

@end

@implementation ViewController

#pragma mark - accessor

- (JLAccordionDataController *)accordionDataController
{
    if(!_accordionDataController) {
        _accordionDataController = [[JLAccordionDataController alloc] init];
        _accordionDataController.accordionDelegate = self;
    }
    return _accordionDataController;
}
- (NSMutableArray *)parentData
{
    if(!_parentData) {
        _parentData = [[NSMutableArray alloc] init];
    }
    return _parentData;
}
- (NSMutableArray *)childData
{
    if(!_childData) {
        _childData = [[NSMutableArray alloc] init];
    }
    return _childData;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:path];
    for (NSDictionary *dict in data[@"parent"]) {
        [self.parentData addObject:[JLAccordionData parentDataWithIdentifier:dict[@"identifier"] userData:dict[@"userData"]]];
    }
    for (NSDictionary *dict in data[@"child"]) {
        [self.childData addObject:[JLAccordionData childDataWithIdentifier:dict[@"identifier"] parentIdentifier:dict[@"parentIdentifier"] userData:dict[@"userData"]]];
    }
    
    // start
    [self.accordionDataController setParentDataArray:self.parentData childDataArray:self.childData];
}

#pragma mark - IBAction

- (IBAction)reloadButtonTapped:(id)sender {
    [self.accordionDataController setParentDataArray:self.parentData childDataArray:self.childData];
    [self.tableView reloadData];
}
- (IBAction)closeAllButtonTapped:(id)sender {
    [self.accordionDataController closeAllCellsWithTableView:self.tableView section:0];
}
- (IBAction)openFirstCellButtonTapped:(id)sender {
    [self.accordionDataController openCellForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] tableView:self.tableView];
}
- (IBAction)openAllButtonTapped:(id)sender {
    [self.accordionDataController openAllCellsWithTableView:self.tableView section:0];
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accordionDataController numberOfRows];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JLAccordionData *data = [self.accordionDataController dataForIndex:indexPath.row];
    
    if( [data isParentData] ) {
        ParentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParentCell" forIndexPath:indexPath];
        cell.titleLabel.text = data.userData[@"title"];
        cell.arrowImageView.hidden = ![self.accordionDataController hasChildForIdentifier:data.identifier];
        [cell setOpened:[self.accordionDataController isOpenedForIdentifier:data.identifier] animated:NO];
        
        return cell;
    }
    else {
        ChildTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChildCell" forIndexPath:indexPath];
        cell.titleLabel.text = data.userData[@"title"];
        return cell;
        
    }
    return nil;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.accordionDataController toggleCellForIndexPath:indexPath tableView:tableView];
    
}
#pragma mark - <JLAccordionDelegate>

- (void)accordionTableView:(UITableView *)tableView shouldOpenCellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([[cell class] isSubclassOfClass:[ParentTableViewCell class]]) {
        ParentTableViewCell *parentCell = (ParentTableViewCell *)cell;
        [parentCell setOpened:YES animated:YES];
    }
}
- (void)accordionTableView:(UITableView *)tableView shouldCloseCellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([[cell class] isSubclassOfClass:[ParentTableViewCell class]]) {
        ParentTableViewCell *parentCell = (ParentTableViewCell *)cell;
        [parentCell setOpened:NO animated:YES];
    }
}

@end
