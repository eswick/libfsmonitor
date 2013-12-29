#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <pwd.h>
#include <grp.h>

#import "fsevents.h"
#import "../CPDistributedNotificationCenter.h"

#define DEV_FSEVENTS     "/dev/fsevents" // the fsevents pseudo-device
#define FSEVENT_BUFSIZ   131072          // buffer for reading from the device
#define EVENT_QUEUE_SIZE 4096            // limited by MAX_KFS_EVENTS

void handleEvent(pid_t pid, int32_t type, NSArray *arguments);

CPDistributedNotificationCenter *notifier;

// an event argument
typedef struct kfs_event_arg {
	u_int16_t  type;         // argument type
	u_int16_t  len;          // size of argument data that follows this field
	union {
		struct vnode *vp;
		char         *str;
		void         *ptr;
		int32_t       int32;
		dev_t         dev;
		ino_t         ino;
		int32_t       mode;
		uid_t         uid;
		gid_t         gid;
		time_t      timestamp;
	} data;
} kfs_event_arg_t;

#define KFS_NUM_ARGS  FSE_MAX_ARGS

// an event
typedef struct kfs_event {
	int32_t         type; // event type
	pid_t           pid;  // pid of the process that performed the operation
	kfs_event_arg_t args[KFS_NUM_ARGS]; // event arguments
} kfs_event;

int main(int argc, char **argv){
	int32_t arg_id;
	int     fd, clonefd = -1;
	int     i, eoff, off, ret;

	kfs_event_arg_t *kea;
	struct           fsevent_clone_args fca;
	char             buffer[FSEVENT_BUFSIZ];
	u_int32_t        is_fse_arg_vnode = 0;
	int8_t           event_list[] = { // action to take for each event
		FSE_REPORT,  // FSE_CREATE_FILE,
		FSE_REPORT,  // FSE_DELETE,
		FSE_REPORT,  // FSE_STAT_CHANGED,
		FSE_REPORT,  // FSE_RENAME,
		FSE_REPORT,  // FSE_CONTENT_MODIFIED,
		FSE_REPORT,  // FSE_EXCHANGE,
		FSE_REPORT,  // FSE_FINDER_INFO_CHANGED,
		FSE_REPORT,  // FSE_CREATE_DIR,
		FSE_REPORT,  // FSE_CHOWN,
		FSE_REPORT,  // FSE_XATTR_MODIFIED,
		FSE_REPORT,  // FSE_XATTR_REMOVED,
	};

	notifier = [CPDistributedNotificationCenter centerNamed:@"com.eswick.libfsmonitor"];
	[notifier runServer];

	if (geteuid() != 0) {
		NSLog(@"Error: %s must be run as root.", argv[0]);
		exit(1);
	}

	setbuf(stdout, NULL);

	if ((fd = open(DEV_FSEVENTS, O_RDONLY)) < 0) {
		perror("open");
		exit(1);
	}

	fca.event_list = (int8_t *)event_list;
	fca.num_events = sizeof(event_list)/sizeof(int8_t);
	fca.event_queue_depth = EVENT_QUEUE_SIZE;
	fca.fd = &clonefd; 
	if ((ret = ioctl(fd, FSEVENTS_CLONE, (char *)&fca)) < 0) {
		perror("ioctl");
		close(fd);
		exit(1);
	}

	close(fd);
	//printf("fsevents device cloned (fd %d)\nfslogger ready\n", clonefd);

	if ((ret = ioctl(clonefd, FSEVENTS_WANT_EXTENDED_INFO, NULL)) < 0) {
		perror("ioctl");
		close(clonefd);
		exit(1);
	}

	while (1) { // event processing loop

		ret = read(clonefd, buffer, FSEVENT_BUFSIZ);

		off = 0;

		while (off < ret) { // process one or more events received

			struct kfs_event *kfse = (struct kfs_event *)((char *)buffer + off);

			off += sizeof(int32_t) + sizeof(pid_t); // type + pid

			if (kfse->type == FSE_EVENTS_DROPPED) { // special event
				NSLog(@"Process %d dropped events.", kfse->pid);
				off += sizeof(u_int16_t); // FSE_ARG_DONE: sizeof(type)
				continue;
			}

			int32_t atype = kfse->type & FSE_TYPE_MASK;
			uint32_t aflags = FSE_GET_FLAGS(kfse->type);

			if ((atype < FSE_MAX_EVENTS) && (atype >= -1)) { //atype = Event Type
				if (aflags & FSE_COMBINED_EVENTS) {
					//Combined events
				}
				if (aflags & FSE_CONTAINS_DROPPED_EVENTS) {
					//Contains dropped events
				}
			} else { // should never happen
				NSLog(@"This may be a program bug (type = %d).", atype);
				exit(1);
			}

			NSMutableArray *arguments = [[NSMutableArray alloc] init];

			kea = kfse->args; 
			i = 0;

			while (off < ret) {// process arguments
				i++;

				if (kea->type == FSE_ARG_DONE) { // no more arguments
					off += sizeof(u_int16_t);
					break;
				}

				eoff = sizeof(kea->type) + sizeof(kea->len) + kea->len;
				off += eoff;

				arg_id = (kea->type > FSE_MAX_ARGS) ? 0 : kea->type;

				switch (kea->type) { // handle based on argument type

					case FSE_ARG_VNODE:  // a vnode (string) pointer
						is_fse_arg_vnode = 1;
						[arguments addObject:[NSString stringWithUTF8String:(char *)&(kea->data.vp)]];
						break;

					case FSE_ARG_STRING: // a string pointer
						[arguments addObject:[NSString stringWithUTF8String:(char *)&(kea->data.str)]];
						break;

					case FSE_ARG_INT32:
						[arguments addObject:@(kea->data.int32)];
						break;

					case FSE_ARG_RAW: // a void pointer
						//Not implemented
						break;

					case FSE_ARG_INO: // an inode number
						[arguments addObject:@((uint32_t)kea->data.ino)];
						break;

					case FSE_ARG_UID: // a user ID
						[arguments addObject:@(kea->data.uid)];
						break;

					case FSE_ARG_DEV: // a file system ID or a device number
						[arguments addObject:@(kea->data.dev)];
						break;

					case FSE_ARG_MODE: // a combination of file mode and file type
						[arguments addObject:@(kea->data.mode)];
						break;

					case FSE_ARG_GID: // a group ID
						[arguments addObject:@(kea->data.gid)];
						break;
					case FSE_ARG_INT64: // timestamp
						[arguments addObject:@(kea->data.timestamp)];
						break;

					default:
						NSLog(@"such argument. so unknown. wow.");
						NSLog(@"(Unknown event argument)");
						[arguments addObject:@"unknown"];
						break;
				}

				kea = (kfs_event_arg_t *)((char *)kea + eoff); // next
			} // for each argument
			handleEvent(kfse->pid, kfse->type, arguments);
			[arguments release];
		} // for each event
	} // forever

	close(clonefd);

	exit(0);
}


void handleEvent(pid_t pid, int32_t type, NSArray *arguments){
	NSMutableDictionary *event = [NSMutableDictionary new];

	[event setObject:@(type) forKey:@"TYPE"];
	[event setObject:@(pid) forKey:@"PID"];
	[event setObject:[arguments objectAtIndex:[arguments count] - 1] forKey:@"TIMESTAMP"];

	switch(type){
		case FSE_CREATE_FILE:
		case FSE_DELETE:
		case FSE_STAT_CHANGED:
		case FSE_CONTENT_MODIFIED:
		case FSE_CHOWN:
		case FSE_CREATE_DIR:
		case FSE_XATTR_MODIFIED:
			[event setObject:[arguments objectAtIndex:0] forKey:@"FILE"];
			[event setObject:@(major([[arguments objectAtIndex:1] intValue])) forKey:@"DEVICE_MAJOR"];
			[event setObject:@(minor([[arguments objectAtIndex:1] intValue])) forKey:@"DEVICE_MINOR"];
			[event setObject:[arguments objectAtIndex:2] forKey:@"INODE"];
			[event setObject:[arguments objectAtIndex:3] forKey:@"MODE"];
			[event setObject:[arguments objectAtIndex:4] forKey:@"UID"];
			[event setObject:[arguments objectAtIndex:5] forKey:@"GID"];

			break;
		case FSE_RENAME:
			[event setObject:[arguments objectAtIndex:0] forKey:@"FILE"];
			[event setObject:@(major([[arguments objectAtIndex:1] intValue])) forKey:@"DEVICE_MAJOR"];
			[event setObject:@(minor([[arguments objectAtIndex:1] intValue])) forKey:@"DEVICE_MINOR"];
			[event setObject:[arguments objectAtIndex:2] forKey:@"INODE"];
			[event setObject:[arguments objectAtIndex:3] forKey:@"MODE"];
			[event setObject:[arguments objectAtIndex:4] forKey:@"UID"];
			[event setObject:[arguments objectAtIndex:5] forKey:@"GID"];

			[event setObject:[arguments objectAtIndex:0] forKey:@"DEST_FILE"];
			[event setObject:@(major([[arguments objectAtIndex:1] intValue])) forKey:@"DEST_DEVICE_MAJOR"];
			[event setObject:@(minor([[arguments objectAtIndex:1] intValue])) forKey:@"DEST_DEVICE_MINOR"];
			[event setObject:[arguments objectAtIndex:2] forKey:@"DEST_INODE"];
			[event setObject:[arguments objectAtIndex:3] forKey:@"DEST_MODE"];
			[event setObject:[arguments objectAtIndex:4] forKey:@"DEST_UID"];
			[event setObject:[arguments objectAtIndex:5] forKey:@"DEST_GID"];
			break;
		case FSE_EXCHANGE:
			//Not implemented
			break;
		case FSE_FINDER_INFO_CHANGED:
			//Not implemented
			break;
		case FSE_XATTR_REMOVED:
			//Not implemented
			break;
		default:
			break;
	}

	[notifier postNotificationName:@"FSMONITORD_CALLBACK" userInfo:event];

	[event release];
}

