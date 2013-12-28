int main(int argc, char **argv, char **envp) {
	NSLog(@"fsmonitor daemon launched!");
	[[NSRunLoop currentRunLoop] run];
	return 0;
}

// vim:ft=objc
