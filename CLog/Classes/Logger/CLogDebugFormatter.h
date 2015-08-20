//
//  CLogDebugFormatter.h
//  CLog
//
//  Created by Christoph Lückler on 20/08/15.
//  Copyright (c) 2015 Up To Eleven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface CLogDebugFormatter : NSObject <DDLogFormatter> {
    int atomicLoggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}

@end
