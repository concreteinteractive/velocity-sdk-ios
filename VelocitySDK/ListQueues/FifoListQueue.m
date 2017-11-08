//
//  FifoListQueue.m
//  VelocitySDK iOS
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "FifoListQueue.h"

@interface FifoListQueue ()

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong) NSMutableArray *storage;

@end

@implementation FifoListQueue

- (instancetype)init {
    self = [super init];
    if (self) {
        _dispatchQueue = dispatch_queue_create("net.vlcty.VelocitySDK.fifoQueue", DISPATCH_QUEUE_CONCURRENT);
        _storage = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)add:(id)item {
    dispatch_barrier_sync(self.dispatchQueue, ^{
        [self.storage addObject:item];
    });
}

- (id)get {
    __block id result = nil;
    dispatch_barrier_sync(self.dispatchQueue, ^{
        if (self.storage.count > 0) {
            result = [self.storage firstObject];
            [self.storage removeObjectAtIndex:0];
        }
    });
    return result;
}

- (NSUInteger)count {
    __block NSUInteger count = 0;
    dispatch_sync(self.dispatchQueue, ^{
        count = self.storage.count;
    });
    return count;
}

@end
