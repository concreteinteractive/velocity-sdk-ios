//
//  VLTActivityItem.m
//  Velocity
//
//  Created by Vytautas Galaunia on 16/11/2016.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import "VLTActivityItem.h"

@interface VLTActivityItem ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *date;

@end

@implementation VLTActivityItem

- (instancetype)initWithName:(NSString *)name date:(NSDate *)date
{
    self = [super init];
    if (self) {
        _name = name;
        _date = date;
    }
    return self;
}

@end
