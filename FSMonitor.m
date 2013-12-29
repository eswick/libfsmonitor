#import "FSMonitor.h"
#import "CPDistributedNotificationCenter.h"

@implementation FSMonitor

- (id)init{
	if(![super init])
		return nil;

	CPDistributedNotificationCenter* notificationCenter;
	notificationCenter = [CPDistributedNotificationCenter centerNamed:@"com.eswick.libfsmonitor"];
	[notificationCenter startDeliveringNotificationsToMainThread];

	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(daemonCallback:) name:@"FSMONITORD_CALLBACK" object:nil];

	return self;
}

- (void)daemonCallback:(NSNotification*)notification{
	NSLog(@"Daemon recieved callback.");
	NSLog(@"User info: %@", [notification userInfo]);
}

@end