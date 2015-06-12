/* Author: Landon Fuller <landonf@plausiblelabs.com>
 * Copyright (c) 2008-2011 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 *
 * See the LICENSE file for the license on the source code in this file.
 */

#import <Foundation/Foundation.h>
#import <iPhoneSimulatorRemoteClient/iPhoneSimulatorRemoteClient.h>
#import "version.h"

@interface iPhoneSimulator : NSObject <DTiPhoneSimulatorSessionDelegate> {
@private
  DTiPhoneSimulatorSystemRoot *sdkRoot;
  BOOL exitOnStartup;
  BOOL verbose;
  BOOL alreadyPrintedData;
}

- (void)runWithArgc:(int)argc argv:(char **)argv;

@end
