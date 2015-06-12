#import <Foundation/Foundation.h>
#import <AppSupport/CPDistributedMessagingCenter.h> 
#import <stdio.h>


NSString* appNameFromPath( NSString* path ){
	NSCharacterSet* pathSeparator = [NSCharacterSet characterSetWithCharactersInString:@"/"];
	NSArray* aryPath = [path componentsSeparatedByCharactersInSet:pathSeparator];


	NSString* fullName = [aryPath lastObject];
	
	NSCharacterSet* dot = [NSCharacterSet characterSetWithCharactersInString:@"."];
	NSArray* aryFullName = [fullName componentsSeparatedByCharactersInSet:dot];
	
	NSString* appName = [aryFullName objectAtIndex:0];
	return appName;
}

int main(int argc, char **argv, char **envp) {
	if(!argv[1]){
		fprintf(stderr, "Usage: appid2name com.yourcompany.appid\n");	
		return 1;
	}

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *identifier = [NSString stringWithUTF8String:argv[1]];

	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:identifier forKey:@"identifier"];

	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.williammu.appid2name.server"];
	NSDictionary *status = [messagingCenter sendMessageAndReceiveReplyName:@"appid2name" userInfo:userInfo];
	
	NSString* appPath = [status objectForKey:@"appPath"];

	if(!appPath)
		return 1;

	NSString* appName = appNameFromPath(appPath);

	printf("%s\n", [appName UTF8String]);

	[pool release];

	return 0;

}
