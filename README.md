# JLAccordion
An accordion controller based on UITableView.



## Usage
Please check out the demo project in the repository.



#### Structure

[![](https://raw.github.com/buhikon/JLAccordion/master/img01.png)](https://raw.github.com/buhikon/JLAccordion/master/img01.png)

There are 2 types of cell, Parent and Child.
You need to create parent data and child data for each cells.



#### Set data

- Create Parent Data
```
[JLAccordionData parentDataWithIdentifier:@"parent_001"
                                 userData:@{@"title":@"Hello"}];
```

- Create Child Data                                 
```
[JLAccordionData childDataWithIdentifier:@"child_001"
                        parentIdentifier:@"parent_001"
                                userData:@{@"title":@"World"}];
```
                                
- Set parent data and child data
```
self.accordionDataController = [JLAccordionDataController alloc] init];
self.accordionDataController.accordionDelegate = self;
[self.accordionDataController setParentDataArray:(array of parent data)
                                  childDataArray:(array of child data)];
```
                        

#### Implement below 3 protocols.

> UITableViewDataSource
> UITableViewDelegate
> JLAccordionDelegate


```
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
```



## Sample data and Demo

```
sample of parent data : (
    "identifier : 100, parentIdentifier : (null), userData : {title : Hello}",
    "identifier : 200, parentIdentifier : (null), userData : {title : World}",
    "identifier : 300, parentIdentifier : (null), userData : {title : Amazing}",
    "identifier : 400, parentIdentifier : (null), userData : {title : Don't worry}",
    "identifier : 500, parentIdentifier : (null), userData : {title : Be Happy}"
)
sample of child data : (
    "identifier : 101, parentIdentifier : 100, userData : {title : Hello1}",
    "identifier : 102, parentIdentifier : 100, userData : {title : Hello2}",
    "identifier : 103, parentIdentifier : 100, userData : {title : Hello3}",
    "identifier : 104, parentIdentifier : 100, userData : {title : Hello4}",
    "identifier : 201, parentIdentifier : 200, userData : {title : World1}",
    "identifier : 202, parentIdentifier : 200, userData : {title : World2}",
    "identifier : 203, parentIdentifier : 200, userData : {title : World3}",
    "identifier : 204, parentIdentifier : 200, userData : {title : World4}",
    "identifier : 501, parentIdentifier : 500, userData : {title : show me the money}",
    "identifier : 502, parentIdentifier : 500, userData : {title : operation cwal}",
    "identifier : 503, parentIdentifier : 500, userData : {title : power overwhelming}"
)
```

[![](https://raw.github.com/buhikon/JLAccordion/master/demo.gif)](https://raw.github.com/buhikon/JLAccordion/master/demo.gif)




## License
Licensed under the MIT license. You can use the code in your commercial and non-commercial projects.
