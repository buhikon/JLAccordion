//
//  ParentTableViewCell.m
//  AccordionDemo
//
//  Created by Joey L. on 5/19/15.
//  Copyright (c) 2015 Joey L. All rights reserved.
//

#import "ParentTableViewCell.h"

@interface ParentTableViewCell ()
{
    BOOL _opened;
}
@end

@implementation ParentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setOpened:(BOOL)opened animated:(BOOL)animated
{
    _opened = opened;
    
    [UIView animateWithDuration:animated ? 0.3 : 0.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGFloat angle = !opened ? 0.0 : 180.001;
                         self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI * angle / 180.0);
                     }
                     completion:nil];
}

@end
