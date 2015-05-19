//
//  ParentTableViewCell.h
//  AccordionDemo
//
//  Created by Joey L. on 5/19/15.
//  Copyright (c) 2015 Joey L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

- (void)setOpened:(BOOL)opened animated:(BOOL)animated;

@end
