//
//  VLTCaptureOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTOperation.h"

@class VLTPBCapture;

@interface VLTCaptureOperation : VLTOperation

@property (nonatomic, strong, readonly, nonnull) VLTPBCapture *captureRequest;

- (nonnull instancetype)initWithCaptureRequest:(nonnull VLTPBCapture *)captureRequest;

- (void)processCaptureRequest;

@end
