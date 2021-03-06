//
//  AppDelegate.h
//  UploadPhotoXML
//
//  Created by Яблочник on 8/6/12.
//  Copyright (c) 2012 org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

-(void)postImageToServer:(UIImage*)imageToPost description:(NSString*)desc detail:(NSString*)detail price:(NSString*)price;
-(void)saveImageToHistory:(UIImage*)imageToPost description:(NSString*)desc detail:(NSString*)detail price:(NSString*)price;

@end
