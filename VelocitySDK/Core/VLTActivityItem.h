//
//  VLTActivityItem.m
//  Velocity
//
//  
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTActivityItem : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSDate *date;

- (instancetype)initWithName:(NSString *)name date:(NSDate *)date;

@end
