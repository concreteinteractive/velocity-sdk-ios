//
//  VLTMotion.h
//  Velocity
//
//  Created by Antanas Majus on 10/21/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTMotion : NSObject

- (nonnull instancetype)initWithName:(nonnull NSString *)name weight:(float)weight;

@property (nonatomic, readonly, nonnull) NSString *name;

/** Motion relevance */
@property (nonatomic, readonly, assign) float weight;

@end
