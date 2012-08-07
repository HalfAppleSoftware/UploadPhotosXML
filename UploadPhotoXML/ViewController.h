//
//  ViewController.h
//  UploadPhotoXML
//
//  Created by Яблочник on 8/6/12.
//  Copyright (c) 2012 org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtDescription;
@property (strong, nonatomic) IBOutlet UITextField *txtDetail;
@property (strong, nonatomic) IBOutlet UITextField *txtPrice;
@property (strong, nonatomic) IBOutlet UIImageView *imageToPost;
@property (strong, nonatomic) IBOutlet UIButton *btnUpload;
- (IBAction)takePictureTap:(id)sender;
- (IBAction)uploadTap:(id)sender;

@end
