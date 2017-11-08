//
//  ListQueue.h
//  VelocitySDK iOS
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ListQueue

- (void)add:(id)object;
- (id)get;
- (NSUInteger)count;

@end
