#import <dlfcn.h>
#import <objc/runtime.h>
#import <substrate.h>
#import <CoreFoundation/CoreFoundation.h>
#import <notify.h>
#import <prefs.h>

#define NSLog(...)

@interface CPNetworkObserver : NSObject
+ (CPNetworkObserver *)sharedNetworkObserver;
- (void)addNetworkReachableObserver:(id)observer selector:(SEL)selector;
- (BOOL)isNetworkReachable;
@end
@interface HomeClickController : PSListController
@end
@interface AssistantController : PSListController
-(void)setAssistantEnabled:(bool)arg1;
@end
@interface NSUserDefaults ()
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
@end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
	%orig;
	[[CPNetworkObserver sharedNetworkObserver] addNetworkReachableObserver:self selector:@selector(networkStateChangedSiriIfPossible:)];
}
%new
- (void)networkStateChangedSiriIfPossible:(NSNotification *)unusedNotification
{
	@autoreleasepool {
		int valueCurrent = [[[NSUserDefaults standardUserDefaults] objectForKey:@"HomeButtonAssistantPreference" inDomain:@"com.apple.Accessibility"]?:@(0) intValue];
		if(valueCurrent == 2) {
			return;
		}
		BOOL isNetworkReachable = [[CPNetworkObserver sharedNetworkObserver] isNetworkReachable];
		HomeClickController* homeClicC = [%c(HomeClickController) new];
		[homeClicC loadView];
		[homeClicC viewDidLoad];
		PSSpecifier* spec = nil;
		for(PSSpecifier* specNow in [homeClicC specifiers]) {
			if(NSString* specKey = [specNow properties][@"key"]) {
				if([specKey isEqualToString:isNetworkReachable?@"assistantChoiceSiri":@"assistantChoiceVoiceControl"]) {
					spec = specNow;
					break;
				}
			}
		}
		if(spec) {
			if(UITableView* tableV = (UITableView *)object_getIvar(homeClicC, class_getInstanceVariable([homeClicC class], "_table"))) {
				[tableV selectRowAtIndexPath:[homeClicC indexPathForSpecifier:spec] animated:YES scrollPosition:UITableViewScrollPositionNone];
				[homeClicC tableView:tableV didSelectRowAtIndexPath:[homeClicC indexPathForSpecifier:spec]];
				if(isNetworkReachable) {
					AssistantController* AssistantConC = [%c(AssistantController) new];
					[AssistantConC setAssistantEnabled:YES];
				}
			}
		}
	}
}
%end


%ctor
{
	dlopen("/System/Library/PreferenceBundles/AccessibilitySettings.bundle/AccessibilitySettings", RTLD_LAZY);
	dlopen("/System/Library/PreferenceBundles/Assistant.bundle/Assistant", RTLD_LAZY);
}
