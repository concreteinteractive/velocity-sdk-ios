//
//  VLTMacros.h
//  Velocity
//
//  Created by Antanas Majus on 10/25/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#ifndef VLTMacros_h
#define VLTMacros_h

#define vlt_invoke_block(block, ...) block ? block(__VA_ARGS__) : nil

#define vlt_weakify(var) __weak typeof(var) weak_##var = var;

#define vlt_strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = weak_##var; \
_Pragma("clang diagnostic pop")


#define DEBUG_LOG 0

#if DEBUG_LOG == 1
    #define DLog(format, ...) NSLog(format, ##__VA_ARGS__)
#else
    #define DLog(format, ...)
#endif


#define VLT_BASE64_DATA(content) [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters]

#endif /* VLTMacros_h */
