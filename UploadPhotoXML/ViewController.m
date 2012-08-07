//
//  ViewController.m
//  UploadPhotoXML
//
//  Created by Яблочник on 8/6/12.
//  Copyright (c) 2012 org. All rights reserved.
//

#import "ViewController.h"
#import "HistoryViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize txtDescription;
@synthesize txtDetail;
@synthesize txtPrice;
@synthesize imageToPost;
@synthesize btnUpload;

- (void)showHistory
{
    HistoryViewController *historyVC = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    UIBarButtonItem *historyButton = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(showHistory)];
    self.navigationItem.rightBarButtonItem = historyButton;

}

- (void)viewDidUnload
{
    [self setImageToPost:nil];
    [self setTxtPrice:nil];
    [self setTxtDetail:nil];
    [self setTxtDescription:nil];
    [self setBtnUpload:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}


- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissModalViewControllerAnimated: YES];
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    UIImage *originalImage, *editedImage, *imageToSave;
    editedImage = (UIImage *) [info objectForKey:
                               UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    if (editedImage) {
        imageToSave = editedImage;
    } else {
        imageToSave = originalImage;
    }
    [self.imageToPost setImage:imageToSave];
    [self.btnUpload setEnabled:YES];
    [self.btnUpload setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self dismissModalViewControllerAnimated: YES];
}


- (IBAction)takePictureTap:(id)sender
{
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

- (IBAction)uploadTap:(id)sender
{
    AppDelegate *dlg = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [dlg saveImageToHistory:self.imageToPost.image
                description:txtDescription.text
                     detail:txtDetail.text
                      price:txtPrice.text];
    
    [dlg postImageToServer:self.imageToPost.image
               description:txtDescription.text
                    detail:txtDetail.text
                     price:txtPrice.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    int maxChars = 20;
    if (textField == self.txtDetail) {
        maxChars = 100;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > maxChars) ? NO : YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtPrice) {
        CGFloat f = [textField.text floatValue];
        if ([[NSString stringWithFormat:@"%f",f] isEqualToString:textField.text]) {
            [textField resignFirstResponder];
            return YES;
        }
        else {
            textField.text = [NSString stringWithFormat:@"%f",f];
            return NO;
        }
    }
    [textField resignFirstResponder];
    return YES;
}

@end
