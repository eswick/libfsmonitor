enum{
	FSMonitorEventTypeNone = 0,
	FSMonitorEventTypeFileCreation = 1 << 0,
	FSMonitorEventTypeDeletion = 1 << 1,
	FSMonitorEventTypeRename = 1 << 2,
	FSMonitorEventTypeModification = 1 << 3,
	FSMonitorEventTypeDirectoryCreation = 1 << 4,
	FSMonitorEventTypeOwnershipChange = 1 << 5,
	FSMonitorEventTypeAll = 0xFF
};
typedef NSUInteger FSMonitorEventType;

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