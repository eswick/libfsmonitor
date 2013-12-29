#import "libfsmonitor.h"

@class FSMonitor;

@protocol FSMonitorDelegate <NSObject>
@required
- (void)monitor:(FSMonitor*)monitor recievedEventInfo:(NSDictionary*)info;
@end

@interface FSMonitor : NSObject

@property (assign) id<FSMonitorDelegate> delegate;
@property (assign) FSMonitorEventType typeFilter;
@property (retain) NSMutableArray *directoryFilter;

- (void)addDirectoryFilter:(NSURL*)url recursive:(BOOL)recursive;
- (void)removeDirectoryFilter:(NSURL*)url;

@end