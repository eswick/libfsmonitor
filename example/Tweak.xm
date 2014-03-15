#import <fsmonitor.h>

@interface FSMonitorExample : NSObject <FSMonitorDelegate> {

}
@property (retain) FSMonitor *fsmonitor;
-(void)startMonitoring;
@end

@implementation FSMonitorExample 

-(void)startMonitoring {

    NSLog(@"FSMonitorExample: INIT");
    self.fsmonitor = [FSMonitor new];
    self.fsmonitor.delegate = self;
    [self.fsmonitor addDirectoryFilter:[NSURL URLWithString:@"/var/mobile/Documents/"] recursive:FALSE];
    [self.fsmonitor release];

}

- (void)monitor:(FSMonitor *)monitor recievedEventInfo:(NSDictionary *)info {

NSLog(@"FSMonitorExample: UserInfo = %@",info);

}

@end

%ctor {

    @autoreleasepool {

    FSMonitorExample *example = [[FSMonitorExample alloc] init];
    [example startMonitoring];
    
    }

}