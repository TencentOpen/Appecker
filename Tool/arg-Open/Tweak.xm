/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.
*/

#import <SpringBoard/SpringBoard.h>

#import "DSDisplayController.h"

static NSArray* s_args = nil;

%hook SBApplicationController

- (id)init {
    if ((self = %orig)) {
        CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.conradkramer.open.server"];
        [messagingCenter runServerOnCurrentThread];

        [messagingCenter registerForMessageName:@"open" target:self selector:@selector(handleOpenCommand:withUserInfo:)];
    }
    return self;
}

%new(@@:@@)
- (NSDictionary *)handleOpenCommand:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
    NSString *identifier = [userInfo objectForKey:@"identifier"];
	s_args = [[userInfo objectForKey:@"arguments"] retain];

    SBApplication *application = [self applicationWithDisplayIdentifier:identifier];
    
	NSDictionary* result;

    if (application) {
        [[DSDisplayController sharedInstance] activateApplication:application animated:YES];
        result = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"status"];
    } else {
        result = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"status"];
    }

	[s_args release];

	return result;
}

%end


%hook SBLaunchdUtilities
+ (BOOL)createJobWithLabel:(id)label path:(id)path arguments:(id)arguments environment:(id)environment standardOutputPath:(id)path5 standardErrorPath:(id)path6 machServices:(id)services threadPriority:(long long)priority waitForDebugger:(BOOL)debugger denyCreatingOtherJobs:(BOOL)jobs runAtLoad:(BOOL)load disableASLR:(BOOL)aslr
{
	if(s_args){
		arguments = s_args;
		s_args = nil;
	}

	return %orig;
}
%end
