//
//  HistoryObjectViewController.m
//  UploadPhotoXML
//
//  Created by Яблочник on 8/7/12.
//  Copyright (c) 2012 org. All rights reserved.
//

#import "HistoryObjectViewController.h"

@interface HistoryObjectViewController ()

@end

@implementation HistoryObjectViewController
@synthesize image;
@synthesize desc;
@synthesize detail;
@synthesize price;

@synthesize descText;
@synthesize detailText;
@synthesize priceText;
@synthesize imageUI;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        nibNameOrNil = [NSString stringWithFormat:@"%@%@",nibNameOrNil,@"_iPad"];
    }

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.desc.text = self.descText;
    self.detail.text = self.detailText;
    self.price.text = self.priceText;
    self.image.image = self.imageUI;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setDesc:nil];
    [self setDetail:nil];
    [self setImage:nil];
    [self setPrice:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
