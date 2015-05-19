//
//  JLAccordionData.h
//
//  Version 1.0.0
//
//  Created by Joey L. on 5/18/2015.
//  https://github.com/buhikon/JLAccordion
//
#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JLAccordionData : NSObject

@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *parentIdentifier;
@property (strong, nonatomic) id userData;

+ (JLAccordionData *)parentDataWithIdentifier:(NSString *)identifier
                                     userData:(id)userData;
+ (JLAccordionData *)childDataWithIdentifier:(NSString *)identifier
                            parentIdentifier:(NSString *)parentIdentifier
                                    userData:(id)userData;

- (BOOL)isParentData;

@end