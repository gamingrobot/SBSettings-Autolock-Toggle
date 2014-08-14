#import <UIKit/UIKit.h>

#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#import <dlfcn.h>

//updates the preferneces after .plist has been changed
void updatePref(NSString *key)
{
    void *gs = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_LAZY);
	if(gs != NULL)
	{
		int (*updPref)(id appID, id theKey) = dlsym(gs, "GSSendAppPreferencesChanged");
		updPref(CFSTR("com.apple.springboard"), key);
		dlclose(gs);
	}
}



// Determines if the device is capable of running on this platform. If your toggle is device specific like only for
BOOL isCapable()
{
	return YES;
}

// This runs when iPhone springboard resets. This is on boot or respring.
BOOL isEnabled()
{
	BOOL Enabled = NO;
	NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist"];
	if(plistDict != nil)
	{
		int AutoDimT = [[plistDict objectForKey:@"SBAutoLockTime"] intValue];
		int AutoLockT = [[plistDict objectForKey:@"SBAutoLockTime"] intValue];
		if (AutoLockT == -1)
		{
			Enabled = YES;
		}
		else
		{
			FILE	*fp;
			fp = fopen("values.txt", "w+");
			fprintf(fp, "%d", [NSNumber numberWithInt:AutoLockT]);
			fprintf(fp, "%d", [NSNumber numberWithInt:AutoDimT]);
			fclose(fp);
			Enabled = NO;
		}
	}
	return Enabled;
}

// This function is optional and should only be used if it is likely for the toggle to become out of sync
// with the state while the iPhone is running. It must be very fast or you will slow down the animated
// showing of the sbsettings window. Imagine 12 slow toggles trying to refresh tate on show.
BOOL getStateFast()
{
	return isEnabled();
}

// Pass in state to set. YES for enable, NO to disable.
void setState(BOOL Enable)
{
	NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist"];
	if(plistDict != nil)
	{
		if (Enable == YES) 
		{
			[plistDict setValue:[NSNumber numberWithInt:-1] forKey:@"SBAutoLockTime"];
			[plistDict writeToFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist" atomically: YES];
			[plistDict setValue:[NSNumber numberWithInt:-1] forKey:@"SBAutoDimTime"];
			[plistDict writeToFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist" atomically: YES];
		}
		else if (Enable == NO) 
		{
			[plistDict setValue:[NSNumber numberWithInt:60] forKey:@"SBAutoLockTime"];
			[plistDict writeToFile:@"/var/mobile/Library/Preferences/com.apple.springbord.plist" atomically: YES];
			[plistDict setValue:[NSNumber numberWithInt:45] forKey:@"SBAutoDimTime"];
			[plistDict writeToFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist" atomically: YES];
		}
		
		updatePref(@"SBAutoLockTime");
		updatePref(@"SBAutoDimTime");
	}
}

// Amount of time spinner should spin in seconds after the toggle is selected.
float getDelayTime()
{
	return 0.6f;
}

// Runs when the dylib is loaded. Only useful for debug. Function can be omitted.
__attribute__((constructor)) 
static void toggle_initializer() 
{ 
	NSLog(@"Initializing AutoLock Toggle\n"); 
}
