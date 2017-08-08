//
//  VLTCore.h
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTCore : NSObject

+ (NSOperationQueue *)queue;

+ (dispatch_source_t)timer:(NSTimeInterval)interval handler:(dispatch_block_t)handler;

@end
