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

NSString *kCLogDebugUserDefaultsKey = @"debugModeEnabled";

@interface CLogService () {
    DDFileLogger *fileLogger;
}
@end

@implementation CLogService
@synthesize debugLogLevel, normalLogLevel;

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
#endif
        
        // Set lov levels
        debugLogLevel = LOG_LEVEL_DEBUG;
        normalLogLevel = LOG_LEVEL_WARN;
        
        // Set log level
        [self setLogLevelForDebugMode:YES];
        
        // Sends log statements to a file
        fileLogger = [[DDFileLogger alloc] init];
        fileLogger.logFormatter = [CLogFormatter new];
        fileLogger.rollingFrequency = 86400;
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:fileLogger];

        // Add observer to detect setting change
        [[NSUserDefaults standardUserDefaults] addObserver: self
                                                forKeyPath: kCLogDebugUserDefaultsKey
                                                   options: NSKeyValueObservingOptionNew
                                                   context: nil];
    }
    return g_sharedInstance;
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] removeObserver: self
                                               forKeyPath: kCLogDebugUserDefaultsKey];
}


#pragma mark
#pragma mark - Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kCLogDebugUserDefaultsKey]) {
        NSUserDefaults *defaults = object;
        [self setLogLevelForDebugMode:[defaults boolForKey:kCLogDebugUserDefaultsKey]];
    }
}


#pragma mark
#pragma mark - Private methods

- (void)setLogLevelForDebugMode:(BOOL)debugMode {
    CLogInfo(@"Set debug mode enabled - %d", debugMode);
    
#ifdef DEBUG
    ddLogLevel = LOG_LEVEL_VERBOSE;
#else
    if (debugMode) {
        ddLogLevel = debugLogLevel;
    } else {
        ddLogLevel = normalLogLevel;
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
