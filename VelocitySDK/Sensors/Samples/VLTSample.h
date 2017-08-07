//
//  VLTSample.h
//  Velocity
//
//  Created by Vytautas Galaunia on 20/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VLTSample <NSObject>

@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly) NSArray <NSNumber *> *values;

@end
