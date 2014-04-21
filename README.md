# libfsmonitor #

##Overview##

libfsmonitor is an Objective-C library allows processes to be notified upon various filesystem events, such as files being created, modified, or deleted. The daemon (fsmonitord) trails /dev/fsevents and parses the data into an NSDictionary, which is then sent via NSDistributedNotificationCenter to any interested clients. Included is a small wrapper around NSDistributedNotificationCenter which handles listening and directory filtering.

## Usage ##
Classes wishing to receive filesystem notification events must conform to the **FSMonitorDelegate** protocol.

#### Initialization ####

    FSMonitor *filesystemMonitor = [FSMonitor new];
    filesystemMonitor.delegate = self;

    [filesystemMonitor addDirectoryFilter:[NSURL URLWithString:@"/path/to/monitor/"] recursive:TRUE or FALSE];

#### Delegate Method ####
    - (void)monitor:(FSMonitor*)monitor recievedEventInfo:(NSDictionary*)info{
        FSMonitorEventType type = [[info objectForKey:@"TYPE"] intValue];
        switch(type){
            case FSMonitorEventTypeRename:
            {
                NSString *originalName = [[info objectForKey:@"FILE"] path];
                NSString *newName = [[info objectForKey:@"DEST_FILE"] path];
                break;
            }
            case FSMonitorEventTypeDeletion:
                ...
#### Event Info ####
The info dictionary contains information about the event. All events include the following keys and their corresponding values:

* FILE
 * The path of the file or directory involved with the event.
* DEVICE_MAJOR
 * The major value of the physical drive FILE is located on.
* DEVICE_MINOR
 * The minor value of the physical drive FILE is located on.
* INODE
 * Whatever the hell an inode is.
* MODE
 * The read/write/execute protections on FILE.
* UID
 * The UID of the process that caused the event.
* GID
 * The GID of the process that caused the event.

The only exception is FSMonitorEventTypeRename, which contains one extra value:

* DEST_FILE
 * The path of the new file.
