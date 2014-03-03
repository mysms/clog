//
//  CLLogFormatter.h
//  CLog
//
//  Created by Christoph Lückler on 17.02.14.
//  Copyright (c) 2014 sms.at mobile internet services gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface CLLogFormatter : NSObject <DDLogFormatter> {
    int atomicLoggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}

@end
