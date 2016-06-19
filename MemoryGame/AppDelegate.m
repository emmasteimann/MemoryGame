//
//  AppDelegate.m
//  MemoryGame
//
//  
//  
//

#import "AppDelegate.h"
#import "SoundCloudClient.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [SoundCloudClient sharedInstance];
  return YES;
}

@end
