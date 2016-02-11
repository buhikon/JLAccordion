//
//  JLAccordionDataController.m
//
//  Version 0.1.1
//
//  Created by Joey L. on 5/18/2015.
//  https://github.com/buhikon/JLAccordion
//
#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "JLAccordionDataController.h"

@interface JLAccordionDataController ()

@property (strong, nonatomic) NSMutableArray *tableViewDataArray;   // array of JLAccordionData
@property (strong, nonatomic) NSMutableArray *parentDataArray;      // array of JLAccordionData
@property (strong, nonatomic) NSMutableArray *childDataArray;       // array of JLAccordionData
@property (strong, nonatomic) NSMutableArray *openedIdentifierArray; // array of NSString

@end

@implementation JLAccordionDataController

#pragma mark - accessor

- (NSMutableArray *)openedIdentifierArray
{
    if(!_openedIdentifierArray) {
        _openedIdentifierArray = [[NSMutableArray alloc] init];
    }
    return _openedIdentifierArray;
    
}

#pragma mark - public methods

- (BOOL)setParentDataArray:(NSArray *)parentDataArray
            childDataArray:(NSArray *)childDataArray
{
    if( ![self isValidParentArray:parentDataArray] ) return NO;
    if( ![self isValidChildArray:childDataArray] ) return NO;
    if( ![self isValidParentArray:parentDataArray childArray:childDataArray] ) return NO;
    
    self.parentDataArray = [NSMutableArray arrayWithArray:parentDataArray];
    self.childDataArray = [NSMutableArray arrayWithArray:childDataArray];;
    
    [self updateOpenedIdentifierArray];
    [self updateTableViewDataArray];
    
    return YES;
}
- (JLAccordionData *)dataForIndex:(NSInteger)index
{
    return self.tableViewDataArray[index];
}

#pragma mark -hasChild

- (BOOL)hasChildForIndex:(NSInteger)index
{
    JLAccordionData *data = [self dataForIndex:index];
    return [self hasChildForIdentifier:data.identifier];
}
- (BOOL)hasChildForIdentifier:(NSString *)identifier
{
    if(!identifier) return NO;
    
    for(JLAccordionData *childData in self.childDataArray) {
        if( [childData.parentIdentifier isEqualToString:identifier] ) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -isOpened

- (BOOL)isOpenedForIndex:(NSInteger)index
{
    JLAccordionData *data = [self dataForIndex:index];
    return [self isOpenedForIdentifier:data.identifier];
}
- (BOOL)isOpenedForIdentifier:(NSString *)identifier
{
    if(!identifier) return NO;
    
    for (JLAccordionData *data in self.tableViewDataArray) {
        if( [data.parentIdentifier isEqualToString:identifier] ) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -open

- (void)openCellForIndexPath:(NSIndexPath *)indexPath
                   tableView:(UITableView *)tableView
{
    JLAccordionData *data = [self dataForIndex:indexPath.row];
    if([data isParentData]) {
        [self openCellForIdentifier:data.identifier
                          tableView:tableView
                            section:indexPath.section];
    }
}
- (void)openCellForIdentifier:(NSString *)identifier
                    tableView:(UITableView *)tableView
                      section:(NSUInteger)section
{
    if(!identifier) return;
    if([self isOpenedForIdentifier:identifier]) {
        NSLog(@"warning: tried to open the cell which is already opened.");
        return;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.tableViewDataArray];
    
    // search parent index
    NSInteger parentIndex = -1;
    for(NSInteger i=0; i<array.count; i++) {
        JLAccordionData *data = array[i];
        if([identifier isEqualToString:data.identifier]) {
            parentIndex = i;
            break;
        }
    }

    if(parentIndex >= 0) {
        
        // animate
        if(self.accordionDelegate) {
           [self.accordionDelegate accordionTableView:tableView shouldOpenCellForIndexPath:[NSIndexPath indexPathForRow:parentIndex inSection:section]];
        }
        
        // add to openedIdentifierArray
        [self.openedIdentifierArray addObject:identifier];
        
        // insert child
        NSInteger cnt = 0;
        for(JLAccordionData *childData in self.childDataArray) {
            if([childData.parentIdentifier isEqualToString:identifier]) {
                [array insertObject:childData atIndex:parentIndex+(++cnt)];
            }
        }
        // set new data
        self.tableViewDataArray = array;
        
        // reflect to tableview
        if(tableView) {
            NSMutableArray *insertIndexPaths = [NSMutableArray array];
            for(NSInteger i=0; i<cnt; i++) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:parentIndex+i+1 inSection:section]];
            }
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    }
}

- (void)openAllCellsWithTableView:(UITableView *)tableView
                          section:(NSUInteger)section
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.tableViewDataArray];
    NSMutableArray *openedIdentifiers = [NSMutableArray arrayWithArray:self.openedIdentifierArray];
    NSMutableArray *insertIndexPaths = [NSMutableArray array];
    
    // -----------------------------------------------------------
    // #step 1: call delegate for animating cells
    //   - the indexpath for this delegate should be the index before changing array.
    if(self.accordionDelegate) {
        for(NSInteger parentIndex=0; parentIndex<array.count; parentIndex++) {
            
            JLAccordionData *openedData = array[parentIndex];
            
            // don't use [self isOpenedForIdentifier] here
            BOOL isOpened = NO;
            for (JLAccordionData *data in array) {
                if( [data.parentIdentifier isEqualToString:openedData.identifier] ) {
                    isOpened = YES;
                    break;
                }
            }
            if([openedData isParentData] && !isOpened) {
                [self.accordionDelegate accordionTableView:tableView shouldOpenCellForIndexPath:[NSIndexPath indexPathForRow:parentIndex inSection:section]];
            }
        }
    }
    
    // -----------------------------------------------------------
    // #step 2: change data and animate
    for(NSInteger parentIndex=0; parentIndex<array.count; parentIndex++) {
        
        JLAccordionData *openedData = array[parentIndex];
        
        // don't use [self isOpenedForIdentifier] here
        BOOL isOpened = NO;
        for (JLAccordionData *data in array) {
            if( [data.parentIdentifier isEqualToString:openedData.identifier] ) {
                isOpened = YES;
                break;
            }
        }
        
        if([openedData isParentData] && !isOpened) {

            // add to openedIdentifierArray
            [openedIdentifiers addObject:openedData.identifier];
            
            // insert child
            NSInteger cnt = 0;
            for(JLAccordionData *childData in self.childDataArray) {
                if([childData.parentIdentifier isEqualToString:openedData.identifier]) {
                    [array insertObject:childData atIndex:parentIndex+(++cnt)];
                }
            }
            
            // collect indexPaths to be reloaded on tableview
            for(NSInteger i=0; i<cnt; i++) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:parentIndex+i+1 inSection:section]];
            }
        }
    }
    if(insertIndexPaths.count > 0) {
        // set new data
        self.openedIdentifierArray = openedIdentifiers;
        self.tableViewDataArray = array;
        
        // reflect to tableview
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    
}

#pragma mark -close

- (void)closeCellForIndexPath:(NSIndexPath *)indexPath
                    tableView:(UITableView *)tableView
{
    JLAccordionData *data = [self dataForIndex:indexPath.row];
    if([data isParentData]) {
        [self closeCellForIdentifier:data.identifier
                           tableView:tableView
                             section:indexPath.section];
    }
}
- (void)closeCellForIdentifier:(NSString *)identifier
                     tableView:(UITableView *)tableView
                       section:(NSUInteger)section
{
    if(!identifier) return;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.tableViewDataArray];
    NSMutableArray *deleteIndexPaths = [NSMutableArray array];
    
    // delete, and collect indexpath
    for(NSInteger i=array.count-1; i>=0; i--) {
        JLAccordionData *data = array[i];
        if ([identifier isEqualToString:data.parentIdentifier]) {
            [array removeObjectAtIndex:i];
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
    }
    



    // remove from openedIdentifierArray
    for(NSInteger i=0; i<self.openedIdentifierArray.count; i++) {
        NSString *openedIdentifier = self.openedIdentifierArray[i];
        if([openedIdentifier isEqualToString:identifier]) {
            [self.openedIdentifierArray removeObjectAtIndex:i];
            break;
        }
    }
    
    
    // animate cell (delegate)
    if(self.accordionDelegate) {
        // search parent index
        NSInteger parentIndex = -1;
        for(NSInteger i=0; i<array.count; i++) {
            JLAccordionData *data = array[i];
            if([identifier isEqualToString:data.identifier]) {
                parentIndex = i;
                break;
            }
        }
        if(parentIndex >= 0) {
            [self.accordionDelegate accordionTableView:tableView shouldCloseCellForIndexPath:[NSIndexPath indexPathForRow:parentIndex inSection:section]];
        }
    }
    
    // *** set new data
    self.tableViewDataArray = array;

    
    // reflect to tableview
    if(tableView) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)closeAllCellsWithTableView:(UITableView *)tableView
                           section:(NSUInteger)section
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.tableViewDataArray];
    NSMutableArray *deleteIndexPaths = [NSMutableArray array];
    
    // search all opened cells
    NSArray *identifiers = [NSArray arrayWithArray:self.openedIdentifierArray];
    
    // animate cells (delegate) <- should be performed before setting new data to self.tableViewDataArray.
    NSMutableArray *indexPathsToBeClosed = nil;
    if(self.accordionDelegate) {

        indexPathsToBeClosed = [NSMutableArray array];
        // search parent index
        for (NSString *identifier in identifiers) {
            NSInteger parentIndex = -1;
            for(NSInteger i=0; i<array.count; i++) {
                JLAccordionData *data = array[i];
                if([identifier isEqualToString:data.identifier]) {
                    parentIndex = i;
                    break;
                }
            }
            if(parentIndex >= 0) {
                [self.accordionDelegate accordionTableView:tableView shouldCloseCellForIndexPath:[NSIndexPath indexPathForRow:parentIndex inSection:section]];
            }
        }
    }
    
    // delete from array, and collect indexpath
    for(NSInteger i=array.count-1; i>=0; i--) {
        JLAccordionData *data = array[i];
        for (NSString *identifier in identifiers) {
            if ([identifier isEqualToString:data.parentIdentifier]) {
                [array removeObjectAtIndex:i];
                [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
                break;
            }
        }
    }
    
    // remove from openedIdentifierArray
    [self.openedIdentifierArray removeAllObjects];
    
    // *** set new data
    self.tableViewDataArray = array;
    
    // reflect to tableview
    if(tableView) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    
}

#pragma mark -toggle

- (void)toggleCellForIndexPath:(NSIndexPath *)indexPath
                     tableView:(UITableView *)tableView
{
    JLAccordionData *data = [self dataForIndex:indexPath.row];
    if([data isParentData]) {
        if([self isOpenedForIdentifier:data.identifier]) {
            [self closeCellForIdentifier:data.identifier
                               tableView:tableView
                                 section:indexPath.section];
        }
        else {
            [self openCellForIdentifier:data.identifier
                               tableView:tableView
                                 section:indexPath.section];
        }
    }
}
- (void)toggleCellForIdentifier:(NSString *)identifier
                      tableView:(UITableView *)tableView
                        section:(NSUInteger)section
{
    if([self isOpenedForIdentifier:identifier]) {
        [self closeCellForIdentifier:identifier
                           tableView:tableView
                             section:section];
    }
    else {
        [self openCellForIdentifier:identifier
                          tableView:tableView
                            section:section];
    }
}

#pragma mark -table view datasource, delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleCellForIndexPath:indexPath tableView:tableView];
}

- (NSUInteger)numberOfRows
{
    return self.tableViewDataArray.count;
}

#pragma mark - private methods

// remove identifier from openedIdentifierArray, if not exists in parentDataArray.
- (void)updateOpenedIdentifierArray
{
    NSMutableArray *openedIdentifiers = [NSMutableArray arrayWithArray:self.openedIdentifierArray];
    
    for(NSInteger i=openedIdentifiers.count-1; i>=0; i--) {
        NSString *openedIdentifier = openedIdentifiers[i];
        
        BOOL exist = NO;
        for(JLAccordionData *data in self.parentDataArray) {
            if([openedIdentifier isEqualToString:data.identifier]) {
                exist = YES;
                break;
            }
        }
        if(!exist) {
            [openedIdentifiers removeObjectAtIndex:i];
        }
    }
    
    self.openedIdentifierArray = openedIdentifiers;
}

- (void)updateTableViewDataArray
{
    NSMutableArray *array = [NSMutableArray array];
    
    // add parents
    [array addObjectsFromArray:self.parentDataArray];
    
    // add childs (if only the parent cell is opened)
    for(NSString *openedIdentifier in self.openedIdentifierArray) {
        
        NSInteger index = -1;
        for(NSInteger i=0; i<array.count; i++) {
            JLAccordionData *parentData = array[i];
            if([openedIdentifier isEqualToString:parentData.identifier]) {
                index = i;
                break;
            }
        }
        if(index == -1) continue;
        
        
        NSInteger cnt = 0;
        for(JLAccordionData *childData in self.childDataArray) {
            if([childData.parentIdentifier isEqualToString:openedIdentifier]) {
                [array insertObject:childData atIndex:index+(++cnt)];
            }
        }
    }
    
    // set array
    self.tableViewDataArray = array;
}

#pragma mark -validation

- (BOOL)isValidArray:(NSArray *)arr
{
    // check class type
    for(NSInteger i=0; i<arr.count; i++) {
        id obj = arr[i];
        if(![[obj class] isSubclassOfClass:[JLAccordionData class]]) {
            NSLog(@"error: JLAccodionData not found.");
            return NO;
        }
    }
    
    // check identifier
    for(NSInteger i=0; i<arr.count; i++) {
        JLAccordionData *data1 = arr[i];
        if(data1.identifier.length == 0) {
            NSLog(@"error: the length of identifier must be longer than 0 and cannot be nil.");
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)isValidParentArray:(NSArray *)arr
{
    if(![self isValidArray:arr]) return NO;
    
    for (JLAccordionData *parentData in arr) {
        if(parentData.parentIdentifier.length > 0) {
            NSLog(@"error: parent data cannot have parentIdentifier.");
            return NO;
        }
    }
    return YES;
}
- (BOOL)isValidChildArray:(NSArray *)arr
{
    if(![self isValidArray:arr]) return NO;
    
    for (JLAccordionData *childData in arr) {
        if(childData.parentIdentifier.length == 0) {
            NSLog(@"error: child data must have parentIdentifier.");
            return NO;
        }
    }
    return YES;
}

- (BOOL)isValidParentArray:(NSArray *)parentArray childArray:(NSArray *)childArray
{
    if( ![self isValidArray:parentArray] ) return NO;
    if( ![self isValidArray:childArray] ) return NO;
    
    if( ![self isValidParentArray:parentArray] ) return NO;
    if( ![self isValidChildArray:childArray] ) return NO;
    
    
    // check duplicate identifier
    for(NSInteger i=0; i<parentArray.count + childArray.count; i++) {
        JLAccordionData *data1 = i < parentArray.count ? parentArray[i] : childArray[i-parentArray.count];
        
        for(NSInteger j=0; j<parentArray.count + childArray.count; j++) {
            if(i == j) continue;
            JLAccordionData *data2 = j < parentArray.count ? parentArray[j] : childArray[j-parentArray.count];
            if([data1.identifier isEqualToString:data2.identifier]) {
                NSLog(@"error: duplicate identifier found.");
                return NO;
            }
        }
    }
    
    // check relationship between parent and child
    for(NSInteger i=0; i<parentArray.count + childArray.count; i++) {
        JLAccordionData *data1 = i < parentArray.count ? parentArray[i] : childArray[i-parentArray.count];
        if(data1.parentIdentifier.length == 0) continue;

        BOOL parentFound = NO;
        for(NSInteger j=0; j<parentArray.count + childArray.count; j++) {
            if(i == j) continue;
            JLAccordionData *data2 = j < parentArray.count ? parentArray[j] : childArray[j-parentArray.count];
            if([data1.parentIdentifier isEqualToString:data2.identifier]) {
                parentFound = YES;
                break;
            }
        }
        if(!parentFound) {
            NSLog(@"error: parent not found.");
            return NO;
        }
    }
    
    return YES;
    
}

@end
