//
//  JLAccordionData.m
//
//  Version 1.0.0
//
//  Created by Joey L. on 5/18/2015.
//  https://github.com/buhikon/JLAccordion
//
#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "JLAccordionData.h"

@implementation JLAccordionData

+ (JLAccordionData *)parentDataWithIdentifier:(NSString *)identifier
                                     userData:(id)userData
{
    JLAccordionData *instance = [[JLAccordionData alloc] init];
    instance.identifier = identifier;
    instance.parentIdentifier = nil;
    instance.userData = userData;
    return instance;
}
+ (JLAccordionData *)childDataWithIdentifier:(NSString *)identifier
                            parentIdentifier:(NSString *)parentIdentifier
                                    userData:(id)userData
{
    JLAccordionData *instance = [[JLAccordionData alloc] init];
    instance.identifier = identifier;
    instance.parentIdentifier = parentIdentifier;
    instance.userData = userData;
    return instance;
}

- (BOOL)isParentData
{
    return self.parentIdentifier ? NO : YES;
}

@end