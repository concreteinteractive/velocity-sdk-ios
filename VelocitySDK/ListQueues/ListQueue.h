//
//  ListQueue.h
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 23/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ListQueue

- (void)add:(id)object;
- (id)get;
- (NSUInteger)count;

@end
