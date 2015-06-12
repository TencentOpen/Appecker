#import <Foundation/Foundation.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

#import <stdio.h>

void printNotice()
{
	printf("Open utility is written by Conrad Kramer!\n");
	printf("This specific version is patched by williammu@tencent.com to provide a way of specifying arguments.\n");
	printf("This specific version should be used only within Tencent, or it will violate GPL!\n");
}

int main(int argc, char **argv, char **envp) {
    if(!argv[1]) {
        fprintf(stderr, "Usage: open com.application.identifier [args...]\n");
        return 1;
    }
	
	printNotice();

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray* args = nil;

	if(argc > 2){
		args = [[[NSMutableArray alloc] init] autorelease] ;
		for(int i = 2; i < argc; i ++){
			NSString* arg = [NSString stringWithUTF8String:argv[i]];
			[args addObject:arg];

		}
	}

    
    
    NSString *identifier = [NSString stringWithUTF8String:argv[1]];
    NSMutableDictionary* userInfo = [[[NSMutableDictionary alloc] init] autorelease];
	[userInfo setObject:identifier forKey:@"identifier"];
	if(args){
		[userInfo setObject:args forKey:@"arguments"];
	}

    CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.conradkramer.open.server"];
    NSDictionary *status = [messagingCenter sendMessageAndReceiveReplyName:@"open" userInfo:userInfo];
    int returnValue = [[status objectForKey:@"status"] intValue];
    
    [pool release];
    
    if (returnValue == 1) {
        fprintf(stderr, "Application with identifier %s not found\n", argv[1]);
    }
    
    return returnValue;
}

// vim:ft=objc
