//
//  HistoryObject.h
//  UploadPhotoXML
//
//  Created by Яблочник on 8/7/12.
//  Copyright (c) 2012 org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryObject : NSObject

@property (nonatomic) int Id;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *filePath;


@end
