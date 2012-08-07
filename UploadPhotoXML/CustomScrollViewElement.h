//
//  CustomScrollViewElement.h
//  tstScroller
//
//  Created by Snow Leopard User on 23/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// this class may be usefull for further expansion
// used in caching operations
@interface CustomScrollViewElement : NSObject

@property (nonatomic, retain) UIView *view; // save our view here
@property (nonatomic) int viewIndexInScrollView;    // save index of our view

@end
