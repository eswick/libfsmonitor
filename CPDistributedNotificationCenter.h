

@interface CPDistributedNotificationCenter : NSObject
{
    NSString *_centerName;
    NSLock *_lock;
    struct __CFRunLoopSource *_receiveNotificationSource;
    BOOL _isServer;
    CFDictionaryRef _sendPorts;
    unsigned int _startCount;
}

+ (id)centerForServerPort:(unsigned int)arg1;
+ (void)setCenter:(id)arg1 forServerPort:(unsigned int)arg2;
+ (CFDictionaryRef)_serverPortToNotificationCenterMap;
+ (id)_serverPortToNotificationCenterMapDispatchQueue;
+ (id)centerNamed:(id)arg1;
- (void)_receivedCheckIn:(unsigned int)arg1 auditToken:(void *)arg2;
- (BOOL)postNotificationName:(id)arg1 userInfo:(id)arg2 toBundleIdentifier:(id)arg3;
- (void)postNotificationName:(id)arg1 userInfo:(id)arg2;
- (void)postNotificationName:(id)arg1;
- (void)runServer;
- (void)runServerOnCurrentThread;
- (void)deliverNotification:(id)arg1 userInfo:(id)arg2;
- (void)stopDeliveringNotifications;
- (void)startDeliveringNotificationsToRunLoop:(CFRunLoopRef)arg1;
- (void)startDeliveringNotificationsToMainThread;
- (void)_notificationServerWasRestarted;
- (void)_checkOutAndRemoveSource;
- (void)_checkIn;
- (void)_createReceiveSourceForRunLoop:(CFRunLoopRef)arg1;
- (id)name;
- (void)dealloc;
- (id)_initWithServerName:(id)arg1;

@end
