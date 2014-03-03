//
//  CLogService.h
//  CLog
//
//  Created by Christoph Lückler on 14.02.14.
//  Copyright (c) 2014 sms.at mobile internet services gmbh. All rights reserved.
//

#import "DDLog.h"
#import <MessageUI/MessageUI.h>

// configure log level for debug and release configuration
extern int ddLogLevel;

/**
 *  Should be used to dynamicaly set the debug log level and stored in NSUserDefaults
 */
extern NSString *kCLogDebugUserDefaultsKey;

#define SharedCLogService ([CLogService sharedService])

#define CLogError(fmt, ...)     DDLogError((@"%s (%d) | " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define CLogWarn(fmt, ...)      DDLogWarn((@"%s (%d) | " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define CLogInfo(fmt, ...)      DDLogInfo((@"%s (%d) | " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define CLogDebug(fmt, ...)     DDLogDebug((@"%s (%d) | " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define CLogVerbose(fmt, ...)   DDLogVerbose((@"%s (%d) | " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


@interface CLogService : DDLog {
    
}

/**
 * LogLevel when Logger is in debug mode
 */
@property (assign) int debugLogLevel;

/**
 * LogLevel when Logger is not in debug mode
 */
@property (assign) int normalLogLevel;


/**
 * Initializes a new instance of the Logger.
 *
 * @return CLLogService Object
 */
+ (CLogService *)sharedService;

/**
 * Returns the current save path of the log files.
 *
 * @return NSString, path to log files
 */
- (NSString *)baseLogFilePath;

/**
 * Returns an NSArray with all paths of all available log files.
 *
 * @return NSArray with NSStrings, path to log files
 */
- (NSArray *)logFilePaths;

/**
 * Compress all available logfiles for sending purpose.
 *
 * @param completion Completion Block, is calles when the compression progress is completed and returns the save path of the compressed file.
 */
- (void)compressLogFiles:(void (^)(NSString *zipPath))completion;

@end
