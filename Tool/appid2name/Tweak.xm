/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor. */

#import <SpringBoard/SpringBoard.h>

%hook SBApplicationController 

- (id)init {
    if ((self = %orig)) {
		NSLog(@"msmsms: appid2name hooked!");
		CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.williammu.appid2name.server"];
		[messagingCenter runServerOnCurrentThread];
		[messagingCenter registerForMessageName:@"appid2name" target:self selector:@selector(handleAppid2nameCommand:withUserInfo:)];
	}   
	return self;
}

%new(@@:@@)
- (NSDictionary *)handleAppid2nameCommand:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
	NSLog(@"msmsms: handleAppid2nameCommand");
	NSString *identifier = [userInfo objectForKey:@"identifier"];
	SBApplication *application = [self applicationWithDisplayIdentifier:identifier];
	NSMutableDictionary* result = [[[NSMutableDictionary alloc] init] autorelease];
	
	if(!application)
		return result;

	NSString* path = [application path];
	
	[result setObject:path forKey:@"appPath"];

	return result; 
}

%end
