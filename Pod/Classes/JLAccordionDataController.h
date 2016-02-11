//
//  JLAccordionDataController.h
//
//  Version 0.1.1
//
//  Created by Joey L. on 5/18/2015.
//  https://github.com/buhikon/JLAccordion
//
#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import <UIKit/UIKit.h>
#import "JLAccordionData.h"

@protocol JLAccordionDelegate
- (void)accordionTableView:(UITableView *)tableView shouldOpenCellForIndexPath:(NSIndexPath *)indexPath;
- (void)accordionTableView:(UITableView *)tableView shouldCloseCellForIndexPath:(NSIndexPath *)indexPath;
@end

@interface JLAccordionDataController : NSObject

@property (weak, nonatomic) id<JLAccordionDelegate> accordionDelegate;

- (BOOL)setParentDataArray:(NSArray *)parentDataArray
            childDataArray:(NSArray *)childDataArray;

- (JLAccordionData *)dataForIndex:(NSInteger)index;

// has child
- (BOOL)hasChildForIndex:(NSInteger)index;
- (BOOL)hasChildForIdentifier:(NSString *)identifier;

// is opened
- (BOOL)isOpenedForIndex:(NSInteger)index;
- (BOOL)isOpenedForIdentifier:(NSString *)identifier;

// open
- (void)openCellForIndexPath:(NSIndexPath *)indexPath
                   tableView:(UITableView *)tableView;
- (void)openCellForIdentifier:(NSString *)identifier
                    tableView:(UITableView *)tableView
                      section:(NSUInteger)section;
- (void)openAllCellsWithTableView:(UITableView *)tableView
                          section:(NSUInteger)section;

// close
- (void)closeCellForIndexPath:(NSIndexPath *)indexPath
                    tableView:(UITableView *)tableView;
- (void)closeCellForIdentifier:(NSString *)identifier
                     tableView:(UITableView *)tableView
                       section:(NSUInteger)section;
- (void)closeAllCellsWithTableView:(UITableView *)tableView
                           section:(NSUInteger)section;
- (void)toggleCellForIdentifier:(NSString *)identifier
                      tableView:(UITableView *)tableView
                        section:(NSUInteger)section;

// toggle
- (void)toggleCellForIndexPath:(NSIndexPath *)indexPath
                     tableView:(UITableView *)tableView;

// table view datasource, delegate
- (NSUInteger)numberOfRows;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;


@end

