#import <fsmonitor.h>

@interface FSMonitorTestCase : NSObject <FSMonitorDelegate> {

}
@property (retain) FSMonitor *fsmonitor;
-(void)startMonitoring;
@end

@implementation FSMonitorTestCase

-(void)startMonitoring {

    self.fsmonitor = [FSMonitor new];
    self.fsmonitor.delegate = self;
    [self.fsmonitor addDirectoryFilter:[NSURL URLWithString:@"/var/mobile/Documents/"] recursive:FALSE];
    [self.fsmonitor release];

}

- (void)monitor:(FSMonitor *)monitor recievedEventInfo:(NSDictionary *)info {

NSLog(@"FSMonitorTestCase: UserInfo = %@",info);

}

@end

%ctor {

    @autoreleasepool {

    FSMonitorTestCase *testCase = [[FSMonitorTestCase alloc] init];
    [testCase startMonitoring];
    
    }

}