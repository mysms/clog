//
//  CLogService.m
//  CLog
//
//  Created by Christoph Lückler on 14.02.14.
//  Copyright (c) 2014 sms.at mobile internet services gmbh. All rights reserved.
//

#import "CLogService.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "CLogFormatter.h"

#import "ZipFile.h"
#import "ZipWriteStream.h"

// configure log level for debug and release configuration
int ddLogLevel = LOG_LEVEL_WARN;

NSString *kCLogLogLevelObserveKey = @"logLevel";

@interface CLogService () {
    DDFileLogger *fileLogger;
}
@end

@implementation CLogService

static CLogService *g_sharedInstance;

#pragma mark
#pragma mark - Initialisation

+ (CLogService *)sharedService {
	return g_sharedInstance ?: [self new];
}

- (id)init {
    if (g_sharedInstance) {
        
	} else if ((self = g_sharedInstance = [super init])) {
#ifdef DEBUG
        // Sends log statements to Apple System Logger, so they show up on Console.app
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        
        // Sends log statements to Xcode console - if available
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        
        // Customize debug colors
        [[DDTTYLogger sharedInstance] setForegroundColor: [UIColor redColor]
                                         backgroundColor: nil
                                                 forFlag: LOG_FLAG_ERROR];
        
        [[DDTTYLogger sharedInstance] setForegroundColor: [UIColor orangeColor]
                                         backgroundColor: nil
                                                 forFlag: LOG_FLAG_WARN];
        
        [[DDTTYLogger sharedInstance] setForegroundColor: [UIColor greenColor]
                                         backgroundColor: nil
                                                 forFlag: LOG_FLAG_INFO];
#endif

        // Set initial log level
        NSNumber *savedLogLevel = [[NSUserDefaults standardUserDefaults] objectForKey:kCLogLogLevelObserveKey];
        if (savedLogLevel) {
            [self setLogLevel:[savedLogLevel integerValue]];
        } else {
            [self setLogLevel:CLogLevelDefault];
        }
        
        // Sends log statements to a file
        fileLogger = [[DDFileLogger alloc] init];
        fileLogger.logFormatter = [CLogFormatter new];
        fileLogger.rollingFrequency = 86400;
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:fileLogger];

        // Add observer to detect setting change
        [[NSUserDefaults standardUserDefaults] addObserver: self
                                                forKeyPath: kCLogLogLevelObserveKey
                                                   options: NSKeyValueObservingOptionNew
                                                   context: nil];
    }
    return g_sharedInstance;
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] removeObserver: self
                                               forKeyPath: kCLogLogLevelObserveKey];
}


#pragma mark
#pragma mark - Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kCLogLogLevelObserveKey]) {
        NSUserDefaults *defaults = object;
        [self setLogLevel:[[defaults objectForKey:kCLogLogLevelObserveKey] integerValue]];
    }
}


#pragma mark
#pragma mark - Private methods

- (void)setLogLevel:(CLogLevel)level {
    CLogInfo(@"Set %d log level", (int)level);
    
#ifdef DEBUG
    ddLogLevel = LOG_LEVEL_VERBOSE;
#else
    switch (level) {
        case CLogLevelVerbose:
            ddLogLevel = LOG_LEVEL_VERBOSE;
            break;
            
        case CLogLevelDebug:
            ddLogLevel = LOG_LEVEL_DEBUG;
            break;
            
        case CLogLevelInfo:
            ddLogLevel = LOG_LEVEL_INFO;
            break;
            
        case CLogLevelWarn:
            ddLogLevel = LOG_LEVEL_WARN;
            break;
            
        case CLogLevelError:
            ddLogLevel = LOG_LEVEL_ERROR;
            break;
            
        default:
            ddLogLevel = LOG_LEVEL_WARN;
            break;
    }
#endif
}

- (NSString *)baseLogFilePath {
    if (fileLogger) {
        return [fileLogger.logFileManager logsDirectory];
    } else {
        return nil;
    }
}

- (NSArray *)logFilePaths {
    if (fileLogger) {
        return [fileLogger.logFileManager sortedLogFilePaths];
    } else {
        return nil;
    }
}

- (void)compressLogFiles:(void (^)(NSString *zipPath))completion {
    if (!fileLogger || [[self logFilePaths] count] == 0) {
        completion(nil);
        return;
    }
    
    NSString *zipPath = [NSTemporaryDirectory() stringByAppendingString:@"logs.zip"];
    
    // Check if old log file exists and delete it
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath isDirectory:NO]) {
        [[NSFileManager defaultManager] removeItemAtPath: zipPath
                                                   error: nil];
    }
    
    // Create new log file
    ZipFile *zipFile = [[ZipFile alloc] initWithFileName: zipPath
                                                    mode: ZipFileModeCreate];

    // Add items to new log file
    for (NSString *filePath in [self logFilePaths]) {
        NSURL *fileUrl = [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        
        NSString *fileName = [[fileUrl lastPathComponent] stringByReplacingOccurrencesOfString:[[NSBundle mainBundle] bundleIdentifier] withString:@""];
        fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        ZipWriteStream *stream = [zipFile writeFileInZipWithName: fileName
                                                compressionLevel: ZipCompressionLevelBest];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        if (data.length > 0) {
            [stream writeData:data];
            [stream finishedWriting];
        }
    }
    
    [zipFile close];
    
    completion(zipPath);
}

@end
