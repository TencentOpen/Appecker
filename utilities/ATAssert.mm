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

#import <Foundation/Foundation.h>
#import "ATLogger.h"
#import "ATException.h"
#import "ATWindow.h"
#import "ATView.h"

void ATCaptureScreen()
{
    NSString * tree = [[UIWindow mainWindow] getTree];
    ATLogMessage(tree);
    UIAlertView * alert = [UIWindow alertView];
    if(alert){
        ATLogMessage(@"alert:");
        tree = [alert getTree];
        ATLogMessage(tree);
    }

    UIActionSheet *actionSheet = [UIWindow actionSheet];
    if(actionSheet)
    {
        ATLogMessage(@"action sheet:");
        tree = [actionSheet getTree];
        ATLogMessage(tree);
    }

    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[UIWindow activityIndicatorWindow];
    if(activityIndicator)
    {
        ATLogMessage(@"Activity indicator:");
        tree = [activityIndicator getTree];
        ATLogMessage(tree);
    }
}

void ATFail(NSString * message){
    ATLogError(message);
    ATCaptureScreen();
    ATException * ex = [ATValidationException exceptionWithMessage:message];
    @throw ex;
}

void ATFailIf(BOOL predication, NSString * message){
    if(predication){
        ATFail(message);
    }
}

void ATWarnIf(BOOL predication, NSString * message){
    if(predication){
        ATLogWarning(message);
    }
}

void ATMessageIf(BOOL predication, NSString * message){
    if(predication){
        ATLogMessage(message);
    }
}

void ATFailFormat(NSString * format,...){
    va_list argumentList;
    va_start(argumentList, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments: argumentList];
    ATFail(message);
    [message release];
    va_end(argumentList);
}

void ATFailFormatIf(BOOL predication, NSString * format,...){
    if(predication){
        va_list argumentList;
        va_start(argumentList, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments: argumentList];
        ATFail(message);
        [message release];
        va_end(argumentList);
    }
}

void ATWarnFormatIf(BOOL predication, NSString * format,...){
    if(predication){
        va_list argumentList;
        va_start(argumentList, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments: argumentList];
        ATLogWarning(message);
        [message release];
        va_end(argumentList);
    }
}

void ATMessageFormatIf(BOOL predication, NSString * format,...){
    if(predication){
        va_list argumentList;
        va_start(argumentList, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments: argumentList];
        ATLogMessage(message);
        [message release];
        va_end(argumentList);
    }
}