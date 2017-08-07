//
//  VLTRecordingConfig.h
//  Velocity
//
//  Created by Vytautas Galaunia on 20/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTRecordingConfig : NSObject

@property (nonatomic, readonly) NSTimeInterval sampleSize;
@property (nonatomic, readonly) NSTimeInterval captureInterval;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary;

- (BOOL)isValid;

@end
