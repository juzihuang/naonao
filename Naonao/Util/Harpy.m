//
//  Harpy.m
//  Harpy
//
//  Created by Arthur Ariel Sabintsev on 11/14/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//


#import "Harpy.h"

static BOOL harpyForceUpdate = NO;

#define kHarpyCurrentVersion

@interface Harpy ()

+ (void)showAlertWithAppStoreVersion:(NSString*)appStoreVersion;

@end

@implementation Harpy

#pragma mark - Public Methods
+ (void)checkVersion
{
    // Asynchronously query iTunes AppStore for publically available version
    NSString *storeString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", kHarpyAppID];
    NSURL *storeURL = [NSURL URLWithString:storeString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:storeURL];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       
        if ( [data length] > 0 && !error ) { // Success
            
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                // All versions that have been uploaded to the AppStore
                NSArray *versionsInAppStore = [[appData valueForKey:@"results"] valueForKey:@"version"];
                if ( ![versionsInAppStore count] ) { // No versions of app in AppStore
                    return;
                }
                else
                {
                    NSString *currentAppStoreVersion = [versionsInAppStore objectAtIndex:0];
                    CLog(@"%@", APP_Version);
                    if ([APP_Version compare:currentAppStoreVersion options:NSNumericSearch] == NSOrderedAscending)
                    {
                        [Harpy showAlertWithAppStoreVersion:currentAppStoreVersion];
                    }
                    else {
                        NSLog(@"您当前安装的版本已经是最新的");
                    }
                }
            });
        }
        
    }];
}

#pragma mark - Private Methods
+ (void)showAlertWithAppStoreVersion:(NSString *)currentAppStoreVersion
{
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    if ( harpyForceUpdate ) { // Force user to update app
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kHarpyAlertViewTitle
                                                            message:[NSString stringWithFormat:@"%@ %@版已发布, 请更新到新版本。", appName, currentAppStoreVersion]
                                                           delegate:self
                                                  cancelButtonTitle:kHarpyUpdateButtonTitle
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }
    else {
        // Allow user option to update next time user launches your app

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kHarpyAlertViewTitle
                                                            message:[NSString stringWithFormat:@"%@ %@版已发布, 请更新到新版本。", appName, currentAppStoreVersion]
                                                           delegate:self
                                                  cancelButtonTitle:kHarpyCancelButtonTitle
                                                  otherButtonTitles:kHarpyUpdateButtonTitle, nil];
        
        [alertView show];
        
    }
    
}

#pragma mark - UIAlertViewDelegate Methods
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ( harpyForceUpdate ) {

        NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", kHarpyAppID];
        NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
        [[UIApplication sharedApplication] openURL:iTunesURL];
        
    } else {

        switch ( buttonIndex ) {
                
            case 0:{ // Cancel / Not now
        
                // Do nothing
                
            } break;
                
            case 1:{ // Update
                
                NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", kHarpyAppID];
                NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
                [[UIApplication sharedApplication] openURL:iTunesURL];
                
            } break;
                
            default:
                break;
        }
        
    }
}

@end
