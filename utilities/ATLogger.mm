///////////////////////////////////////////////////////////////////////////////////////////////////////
// Tencent is pleased to support the open source community by making Appecker available.
// 
// Copyright (C) 2015 THL A29 Limited, a Tencent company. All rights reserved.
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.
///////////////////////////////////////////////////////////////////////////////////////////////////////

#import "ATLogger.h"
#import "ATXmlHelper.h"

const int CLOSING_ROOT_ELEMENT_LENGTH = 28;
static ATLogger * sharedInstanceOfLogger;

void ATLogMessage(NSString* message){
    [[ATLogger sharedInstance] logInfomation: message];
}

void ATLogWarning(NSString* message){
    [[ATLogger sharedInstance] logWarning: message];

}
void ATLogError(NSString* message){
    [[ATLogger sharedInstance] logError: message];

}

void ATLogMessageFormat(NSString* format,...){
    va_list argumentList;
    va_start(argumentList, format);
    NSString *message = [[[NSString alloc] initWithFormat:format arguments: argumentList] autorelease];
    [[ATLogger sharedInstance] logInfomation: message];
    va_end(argumentList);
}

void ATLogWarningFormat(NSString* format,...){
    va_list argumentList;
    va_start(argumentList, format);
    NSString *message = [[[NSString alloc] initWithFormat:format arguments: argumentList] autorelease];
    [[ATLogger sharedInstance] logWarning: message];
    va_end(argumentList);
}


void ATLogErrorFormat(NSString* format,...){
    va_list argumentList;
    va_start(argumentList, format);
    NSString *message = [[[NSString alloc] initWithFormat:format arguments: argumentList] autorelease];
    [[ATLogger sharedInstance] logError: message];
    va_end(argumentList);
}


#define BOOL_TO_NSSTRING(b) ((b) ? @"YES":@"NO")


void ATLogIfAreEqual(NSString* expected, NSString* actual, NSString* message)
{
	ATLogIfAreEqualStr(expected, actual, message);
}

void ATLogIfAreEqualStr(NSString* expected, NSString* actual, NSString* message)
{
	if(expected == actual && actual == nil){
		ATLogMessage([NSString stringWithFormat:@"%@ Pass! Expected: %@, Actual: %@", message, expected, actual]);
		return;
	}


	if([expected isEqualToString:actual])
	{
		ATLogMessage([NSString stringWithFormat:@"%@ Pass! Expected: %@, Actual: %@", message, expected, actual]);
	}
	else
	{
		ATLogError([NSString stringWithFormat:@"%@ Failed! Expected: %@, Actual: %@", message, expected, actual]);
	}
}


void ATLogIfAreEqualInt(int expected, int actual, NSString* message)
{
	if(expected == actual)
	{
		ATLogMessage([NSString stringWithFormat:@"%@ Pass! Expected: %d, Actual: %d", message, expected, actual]);
	}
	else
	{
		ATLogError([NSString stringWithFormat:@"%@ Failed! Expected: %d, Actual: %d", message, expected, actual]);
	}
}

void ATLogIfAreEqualBOOL(BOOL expected, BOOL actual, NSString* message)
{
	if(expected == actual)
	{
		ATLogMessage([NSString stringWithFormat:@"%@ Pass! Expected: %@, Actual: %@", message, BOOL_TO_NSSTRING(expected), BOOL_TO_NSSTRING(actual)]);
	}
	else
	{
		ATLogError([NSString stringWithFormat:@"%@ Failed! Expected: %@, Actual: %@", message, BOOL_TO_NSSTRING(expected), BOOL_TO_NSSTRING(actual)]);
	}
}

void ATLogIfAreBelowInt(int standard, int actual, NSString* message)
{
	if(actual < standard){
		ATLogMessage([NSString stringWithFormat:@"%@ Pass! Standard: %d, Actual: %d", message, standard, actual]);
	}else{
		ATLogError([NSString stringWithFormat:@"%@ Failed! Standard: %d, Actual: %d", message, standard, actual]);
	}
}

void ATLogIfAreBelowEqualInt(int standard, int actual, NSString* message)
{
	if(actual <= standard){
		ATLogMessage([NSString stringWithFormat:@"%@ Pass! Standard: %d, Actual: %d", message, standard, actual]);
	}else{
		ATLogError([NSString stringWithFormat:@"%@ Failed! Standard: %d, Actual: %d", message, standard, actual]);
	}

}


@implementation ATLogger


+(NSString *) getFullLogFileName:(NSString *)fileName underFolder:(NSString *) folderPath{
    if(fileName == nil){
        fileName = @"app.log";
    }
    if(folderPath == nil){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        folderPath = [paths objectAtIndex:0];
    }
    NSString *fullPath = [folderPath stringByAppendingPathComponent:fileName];
    return fullPath;
}

+(NSFileHandle *) openLogFile:(NSString *)fileName underFolder:(NSString *) folderPath{
    NSString* fullPath = [[self class] getFullLogFileName:fileName underFolder:folderPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
        NSString *logContent = @"<?xml version=\"1.0\" encoding=\"UTF-16\"?>\n<Root-Logger>\n</Root-Logger>";
        NSData * data = [logContent dataUsingEncoding:NSUTF16StringEncoding];
        BOOL succeeded = [[NSFileManager defaultManager] createFileAtPath:fullPath contents:data attributes:nil];
        if(!succeeded){
            ATSay(@"Failed to create log file at %@", fullPath);
            [NSException raise:@"Log Error" format:@"Failed to create log file!"];
        }
    }

    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:fullPath];
    if(nil == handle){
        ATSay(@"Failed to get log file handle!");
        [NSException raise:@"Log Error" format:@"Failed to get file handle!"];
    }

    ATSay(@"Log into file: %@", fullPath);
    unsigned long long offset = [handle seekToEndOfFile];
    offset -= CLOSING_ROOT_ELEMENT_LENGTH; //overwrite the enclosing root element at next write operation: </Root-Logger>
    [handle seekToFileOffset:offset];
    return handle;
}

-(id)initWithFileName:(NSString *) fileName underFolder:(NSString *) filePath{
    self = [super init];
    if(self != nil){
        fileHandle = [[[self class] openLogFile: fileName underFolder:filePath] retain];
    }
    return self;
}

-(void)dealloc{
    [fileHandle closeFile];
    [fileHandle release];
    [super dealloc];
}

+(ATLogger*) sharedInstance{
    if(nil == sharedInstanceOfLogger){
        [[self class] createSharedInstance:nil underFolder: nil];
    }
    return sharedInstanceOfLogger;
}

+(void)createSharedInstance:(NSString *) fileName underFolder:(NSString *) folderPath{
    @synchronized(self){
        [sharedInstanceOfLogger release];
        @try{
            sharedInstanceOfLogger = [[ATLogger alloc]initWithFileName:fileName underFolder: folderPath];
        }
        @catch(id ex){
            if(fileName != nil || folderPath != nil){
                //TODO: CREATE the log file at default path
                @try {
                    sharedInstanceOfLogger = [[ATLogger alloc]initWithFileName:nil underFolder: nil];
                }
                @catch (NSException * e) {
                    ATSay(@"Failed to create logger at default path: %@", e);
                }
            }
        }

    }
}

+(void)releaseSharedInstance{

    @synchronized(self){
        [sharedInstanceOfLogger release];
        sharedInstanceOfLogger = nil;
    }
}

-(void)writeContent:(NSString *)content{
    NSData *data = [content dataUsingEncoding:NSUTF16StringEncoding];
    @synchronized(self){
        [fileHandle writeData:data];
        [fileHandle synchronizeFile];
        unsigned long long offset = [fileHandle offsetInFile];
        offset -= CLOSING_ROOT_ELEMENT_LENGTH; //overwrite the enclosing root element at next write operation: </Root-Logger>
        [fileHandle seekToFileOffset:offset];
    }
}

-(void)writeLogEntry:(NSString *)elementName withUserText:(NSString *) message{
    if(nil != message){
        ATSay(@"%@: %@", elementName, message);
        NSString *escapedMessage = [ATXmlHelper escape:message];
        escapedMessage = [ATXmlHelper filterInvalidChar:escapedMessage];
        NSString *contentToWrite = [NSString stringWithFormat:@"<%@ t=\"%@\" msg=\"%@\"></%@>\n</Root-Logger>",
                                    elementName, [[NSDate date] description], escapedMessage, elementName];
        [self writeContent:contentToWrite];
    }
}


-(void)logError:(NSString *) message{
    if((int) _result < (int) TRFailed){
        _result = TRFailed;
    }
    [self writeLogEntry:@"Error" withUserText:message];
}

-(void)logWarning:(NSString *) message{
    if((int) _result < (int) TRWarning){
        _result = TRWarning;
    }
    [self writeLogEntry:@"Warning" withUserText:message];
}

-(void)logInfomation:(NSString *) message{
    [self writeLogEntry:@"Msg" withUserText:message];
}

-(void)logStartTest:(NSString *) caseId{
    _result = TRPassed;
    [self writeLogEntry:@"StartTest" withUserText:caseId];
}

-(ATTestResult)logEndTest:(NSString *) caseId
{
    NSString * resultText = nil;
    switch(_result){
        case TRPassed:
            resultText = @"Pass";
            break;
        case TRFailed:
            resultText = @"Fail";
            break;
        case TRBlocked:
            resultText = @"Blocked";
            break;
        case TRWarning:
            resultText = @"Warning";
            break;
        case TRSkipped:
            resultText = @"Skipped";
            break;
        default:
            resultText = @"NoneInvalid";
            break;
    }
    ATSay(@"EndTest: %@, result=%@", caseId, resultText);
    NSString *escapedMessage = [ATXmlHelper escape:caseId];
    NSString *contentToWrite = [NSString stringWithFormat:@"<EndTest t=\"%@\" msg=\"%@\" Result=\"%@\"></EndTest>\n</Root-Logger>",
                                [[NSDate date] description], escapedMessage, resultText];
    [self writeContent:contentToWrite];
    return _result;
}

-(ATTestResult)logEndTest:(NSString *) caseId withResult:(ATTestResult) result
{
    _result = result;
    return [self logEndTest: caseId];
}

-(ATTestResult)caseResult
{
    return _result;
}

@end
