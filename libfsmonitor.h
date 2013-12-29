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

#import "FSMonitor.h"