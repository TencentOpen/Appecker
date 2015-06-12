#import <Foundation/Foundation.h>

@class SBDisplayStack, SBApplication;

@interface DSDisplayController : NSObject {
}
+ (DSDisplayController *)sharedInstance;

@property (nonatomic, readonly) SBDisplayStack *preActivateStack;
@property (nonatomic, readonly) SBDisplayStack *activeStack;
@property (nonatomic, readonly) SBDisplayStack *suspendingStack;
@property (nonatomic, readonly) SBDisplayStack *suspendedEventOnlyStack;

@property (nonatomic, readonly) SBApplication *activeApp;
@property (nonatomic, readonly) NSSet *activeApplications;
@property (nonatomic, readonly) NSArray *activeApps;
@property (nonatomic, readonly) NSSet *backgroundedApplications;
@property (nonatomic, readonly) NSArray *backgroundedApps;

- (void)activateAppWithDisplayIdentifier:(NSString *)identifier animated:(BOOL)animated;
- (void)activateApplication:(SBApplication *)app animated:(BOOL)animated;
- (void)backgroundTopApplication;
- (void)setBackgroundingEnabled:(BOOL)enabled forDisplayIdentifier:(NSString *)identifier;
- (void)setBackgroundingEnabled:(BOOL)enabled forApplication:(SBApplication *)app;
- (void)exitAppWithDisplayIdentifier:(NSString *)displayIdentifier animated:(BOOL)animated;
- (void)exitApplication:(SBApplication *)app animated:(BOOL)animated;
- (void)exitAppWithDisplayIdentifier:(NSString *)displayIdentifier animated:(BOOL)animated force:(BOOL)force;
- (void)exitApplication:(SBApplication *)app animated:(BOOL)animated force:(BOOL)force;
- (void)deactivateTopApplicationAnimated:(BOOL)animated;
- (void)deactivateTopApplicationAnimated:(BOOL)animated force:(BOOL)force;
- (void)enableBackgroundingForDisplayIdentifier:(NSString *)identifier;
- (void)disableBackgroundingForDisplayIdentifier:(NSString *)identifier;
@end
