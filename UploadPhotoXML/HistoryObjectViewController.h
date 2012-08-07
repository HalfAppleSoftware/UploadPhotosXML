//
//  HistoryObjectViewController.h
//  UploadPhotoXML
//
//  Created by Яблочник on 8/7/12.
//  Copyright (c) 2012 org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryObjectViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *desc;
@property (strong, nonatomic) IBOutlet UILabel *detail;
@property (strong, nonatomic) IBOutlet UILabel *price;

@property (strong, nonatomic) NSString *descText;
@property (strong, nonatomic) NSString *detailText;
@property (strong, nonatomic) NSString *priceText;
@property (strong, nonatomic) UIImage *imageUI;


@end
