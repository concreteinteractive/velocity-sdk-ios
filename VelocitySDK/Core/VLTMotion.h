//
//  VLTMotion.h
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTMotion : NSObject

- (nonnull instancetype)initWithName:(nonnull NSString *)name weight:(float)weight;

@property (nonatomic, readonly, nonnull) NSString *name;

/** Motion relevance */
@property (nonatomic, readonly, assign) float weight;

@end
