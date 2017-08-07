//
//  VLTActivityItem.m
//  Velocity
//
//  Created by Vytautas Galaunia on 16/11/2016.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTActivityItem : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSDate *date;

- (instancetype)initWithName:(NSString *)name date:(NSDate *)date;

@end
