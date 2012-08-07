//
//  AppDelegate.m
//  UploadPhotoXML
//
//  Created by Яблочник on 8/6/12.
//  Copyright (c) 2012 org. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "Base64.h"
#import "sqlite3.h"

@implementation AppDelegate

- (NSString*)generateUniqueFilename
{
    NSString *path = @"";
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
	path = [path stringByAppendingPathComponent:(__bridge NSString *)newUniqueIdString];
	path = [path stringByAppendingPathExtension: @"PNG"];
	CFRelease(newUniqueId);
	CFRelease(newUniqueIdString);
    return path;
}

-(void)saveImageToHistory:(UIImage*)imageToPost description:(NSString*)desc detail:(NSString*)detail price:(NSString*)price
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    sqlite3 *historyDB;
    
    NSString *databasePath = [[NSString alloc] initWithString: [documentsPath stringByAppendingPathComponent: @"history.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    const char *dbpath = [databasePath UTF8String];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)    {
        [filemgr createFileAtPath:databasePath contents:nil attributes:nil];
		if (sqlite3_open(dbpath, &historyDB) == SQLITE_OK)         {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS history (ID INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT, details TEXT, price TEXT, img_filename TEXT)";
            if (sqlite3_exec(historyDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)     {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(historyDB);
        } else {
            NSLog(@"Failed to open/create database");
            return;
        }
    }
        if (sqlite3_open(dbpath, &historyDB) == SQLITE_OK)         {
            char *errMsg;
            NSString *imgPath = [self generateUniqueFilename];
            NSData *image = UIImageJPEGRepresentation(imageToPost, 0.8f);
            NSString *imgFullPath = [documentsPath stringByAppendingPathComponent:imgPath];
            [image writeToFile:imgFullPath atomically:YES];
            NSString *stmt = [NSString stringWithFormat:
                              @"INSERT INTO history (description, details, price, img_filename) VALUES "
                              @"('%@', '%@','%@', '%@')",
                              desc, detail, price, imgPath];
            const char *sql_stmt = (const char *)[stmt UTF8String];
            if (sqlite3_exec(historyDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)     {
                NSLog(@"Failed to write to DB");
            }
            sqlite3_close(historyDB);
        } else {
            NSLog(@"Failed to open database");
        }

}

-(void)postImageToServer:(UIImage*)imageToPost description:(NSString*)desc detail:(NSString*)detail price:(NSString*)price
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized(self)
        {
            NSMutableString *xmlDocument = [[NSMutableString alloc] init];
            NSData *image = UIImagePNGRepresentation(imageToPost);
            [xmlDocument appendString:@"<?xml version='1.0' encoding='utf-8'?>"];
            [xmlDocument appendString:@"<Photo>"];
            [xmlDocument appendFormat:@"<ImageData>%@</ImageData><Description>%@</Description><Detail>%@</Detail><Price>%@</Price>", [Base64 encode:image], desc, detail, price];
            [xmlDocument appendString:@"</Photo>"];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                            initWithURL:[NSURL URLWithString:@"http://"]];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            [request setTimeoutInterval:60];
            
            request.HTTPBody = [[Base64 encode:[xmlDocument dataUsingEncoding:NSUTF8StringEncoding]] dataUsingEncoding:NSUTF8StringEncoding];
            NSHTTPURLResponse *response = nil;
            NSError *error = nil;
            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
        }
    });
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController addChildViewController:self.viewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
