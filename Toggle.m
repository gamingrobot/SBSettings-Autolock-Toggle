#import <UIKit/UIKit.h>

#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#import <dlfcn.h>

extern void GSSendAppPreferencesChanged(NSString *bundleID, NSString *key);

static void updatePref(NSString *key)
{
    GSSendAppPreferencesChanged(@"com.apple.springboard", key);
}

// Determines if the device is capable of running on this platform. If your toggle is device specific like only for
BOOL isCapable()
{
	return YES;
}

// This runs when iPhone springboard resets. This is on boot or respring.
BOOL isEnabled()
{
  NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist"];
  if(plistDict != nil)
  {
    int AutoLockT = [[plistDict objectForKey:@"SBAutoLockTime"] intValue];
    if (AutoLockT != -1)
    	return YES;
  }
  return NO;
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
  FILE*  fp      = NULL;
  int    AutoLockT  = 0; 
  int    AutoDimT  = 0;

  // If we're already in the state being requested, don't do anything.
  if(isEnabled() != Enable)
  {
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist"];
    if(plistDict != nil)
    {
      if (Enable == NO) 
      {
        AutoLockT = [[plistDict objectForKey:@"SBAutoLockTime"] intValue];
        AutoDimT = [[plistDict objectForKey:@"SBAutoDimTime"] intValue];

        // Store off current autolock values.
        fp = fopen("/var/mobile/Library/SBSettings/autolock.sav","wb");
        if(fp != NULL)
        {
          fwrite(&AutoLockT, sizeof(AutoLockT), 1, fp);
          fwrite(&AutoDimT, sizeof(AutoDimT), 1, fp);
          fclose(fp);
        }

        [plistDict setValue:[NSNumber numberWithInt:-1] forKey:@"SBAutoLockTime"];
        [plistDict writeToFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist" atomically: YES];
        [plistDict setValue:[NSNumber numberWithInt:-1] forKey:@"SBAutoDimTime"];
        [plistDict writeToFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist" atomically: YES];
      }
      else if (Enable == YES) 
      {
        // Store off current autolock values.
        fp = fopen("/var/mobile/Library/SBSettings/autolock.sav","rb");
        if(fp != NULL)
        {
          fread(&AutoLockT, sizeof(AutoLockT), 1, fp);
          fread(&AutoDimT, sizeof(AutoDimT), 1, fp);
          fclose(fp);
          remove("/var/mobile/Library/SBSettings/autolock.sav");
        }
        else
        {
          AutoDimT = 45;
          AutoLockT = 60;
        }

        [plistDict setValue:[NSNumber numberWithInt:AutoLockT] forKey:@"SBAutoLockTime"];
        [plistDict writeToFile:@"/var/mobile/Library/Preferences/com.apple.springbord.plist" atomically: YES];
        [plistDict setValue:[NSNumber numberWithInt:AutoDimT] forKey:@"SBAutoDimTime"];
        [plistDict writeToFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist" atomically: YES];
      }

      updatePref(@"SBAutoLockTime");
      updatePref(@"SBAutoDimTime");
    }
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