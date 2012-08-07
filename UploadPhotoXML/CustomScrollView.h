//
//  CustomScrollView.h
//  tstScroller
//
//  Created by Snow Leopard User on 21/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CustomScrollViewElement.h"

@class CustomScrollView;

@protocol CustomScrollViewProtocol <NSObject>

@required
- (int) numberOfElementsInCustomScrollView:(CustomScrollView*)sender;
- (UIView *) customScrollView:(CustomScrollView*)sender viewAtIndex:(int)index;

@optional

@end


@interface CustomScrollViewDelegate : NSObject <UIScrollViewDelegate>

- (void) scrollViewDidScroll:(CustomScrollView *)scrollView; // scrolling event

@end


@interface CustomScrollView : UIScrollView 
{
    //id <CustomScrollViewProtocol> __unsafe_unretained dataSource;
    int elementsCount;
    int currentViewIndex;
    NSMutableArray *views_map;
    NSMutableArray *viewsCache;
    CustomScrollViewDelegate *inner_delegate;
}

- (void) removeAllItems;
- (void) reloadData;    // init new data for our control

@property (nonatomic) BOOL enableCaching;
@property (nonatomic) BOOL isVertical;
@property (nonatomic) BOOL isHorizontal;

@property (nonatomic, assign)  id dataSource;
@property (nonatomic, assign) int elementsCount;
@property (nonatomic, assign) int currentViewIndex;


@end
