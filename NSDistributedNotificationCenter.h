


@interface NSDistributedNotificationCenter : NSNotificationCenter

+ (id)defaultCenter;

- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;

@end
