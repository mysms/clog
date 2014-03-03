//
//  CLogTests.m
//  CLogTests
//
//  Created by Christoph Lückler on 03.03.14.
//  Copyright (c) 2014 Up To Eleven. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CLLogService.h"

@interface CLogTests : XCTestCase {
    CLogService *logService;
}

@end

@implementation CLogTests

- (void)setUp {
    [super setUp];
    
    logService = [[CLogService alloc] init];
    logService.normalLogLevel = LOG_LEVEL_VERBOSE;
}

- (void)tearDown {
    logService = nil;

    [super tearDown];
}

- (void)testLogging {
    CLogVerbose(@"Verbose");
    CLogDebug(@"Debug");
    CLogInfo(@"Info");
    CLogWarn(@"Warning");
    CLogError(@"Error");
}

@end
