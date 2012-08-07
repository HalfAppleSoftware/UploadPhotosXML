//
//  CustomScrollView.m
//  tstScroller
//
//  Created by Snow Leopard User on 21/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomScrollView.h"

@interface CustomScrollView () 

- (void) placeView: (UIView *)newView index:(int)viewIndex;
- (void) rearrangeSubViews:(int)newIndex;

@property (nonatomic) int old_index;
@property (nonatomic,retain) NSNumber *old_width;
@property (nonatomic,retain) NSNumber *old_height;

@end


@implementation CustomScrollViewDelegate

- (void) scrollViewDidScroll:(CustomScrollView *)scrollView
{
    int view_index;
    
    if (scrollView.isHorizontal)
        view_index = (([scrollView contentOffset].x + scrollView.frame.size.width/4) / (scrollView.frame.size.width));
    else
        view_index = (([scrollView contentOffset].y + scrollView.frame.size.height/4) / scrollView.frame.size.height);
    
    if (abs(view_index - scrollView.currentViewIndex) >= 2) {
        view_index = scrollView.currentViewIndex;
    }
    
    if ((view_index != scrollView.old_index) ) // new view is shown in the center
    { 
        [scrollView rearrangeSubViews:view_index];        
        scrollView.old_index = view_index;
        scrollView.currentViewIndex = view_index;
    }
}

@end


@implementation CustomScrollView

@synthesize dataSource;
@synthesize elementsCount;
@synthesize currentViewIndex;
@synthesize enableCaching;
@synthesize isVertical;
@synthesize isHorizontal;

@synthesize old_index;
@synthesize old_width;
@synthesize old_height;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) reloadData
{
    if (!dataSource)
        return;
    if (!self.isVertical) 
        self.isHorizontal = YES;
    if (!self.isHorizontal)
        self.isVertical = YES;
    
    for (UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    
    CustomScrollViewDelegate *inner_delegate = [[CustomScrollViewDelegate alloc] init];
    
    self.delegate = inner_delegate;
    
    old_width = [[NSNumber alloc] initWithInteger:0];
    old_height = [[NSNumber alloc] initWithInteger:0];
    
    // initial loading. Getting first element here
    viewsCache = nil;
    views_map = nil;
    self.elementsCount = [dataSource numberOfElementsInCustomScrollView:self];
    views_map = [[NSMutableArray alloc] initWithCapacity:self.elementsCount];
    viewsCache = [[NSMutableArray alloc] initWithCapacity:self.elementsCount];
    
    if (self.isHorizontal)
        [self setContentSize:CGSizeMake(self.frame.size.width*(self.elementsCount), 0)];
    else
    {
        [self setContentSize:CGSizeMake(0, self.frame.size.height*(self.elementsCount))];
        self.alwaysBounceHorizontal = NO;
    }
    
    old_index = 0;
    
    self.currentViewIndex = 0;
    [self placeView:[dataSource customScrollView:self viewAtIndex:0] index:0];
    [self placeView:[dataSource customScrollView:self viewAtIndex:1] index:1];    
    [self placeView:[dataSource customScrollView:self viewAtIndex:2] index:2];    
    
    
   /* [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(deviceBeganRotateSelector:) 
                                                 name: UIDeviceOrientationDidChangeNotification 
                                               object: nil];*/

}

- (void) placeView: (UIView *)newView index:(int)viewIndex {
    for (int i = 0; i < views_map.count; ++i) {
        if ([[views_map objectAtIndex:i] integerValue] == viewIndex)
            return; // don't place any view, we already have this one
    }
    
    // create new view or get it from cache
    if (viewIndex >= 0 && viewIndex < self.elementsCount) {
    
        [views_map addObject:[NSNumber numberWithInt:viewIndex]];
        [newView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        if (self.isHorizontal) {
            [newView setCenter:CGPointMake(self.frame.size.width*viewIndex +
                                           self.frame.size.width/2, self.frame.size.height/2)];
        }
        else    {
            [newView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height*viewIndex +
                                           self.frame.size.height/2)];
        }
        [self addSubview:newView];
        if (self.enableCaching) {   // maybe we have to put the view in cache?
            for (int i = 0; i < [viewsCache count]; ++i) {
                if ([[viewsCache objectAtIndex:i] viewIndexInScrollView] == viewIndex) {
                    return; // no, already have this one
                }
            }
            CustomScrollViewElement *tmp = [[[CustomScrollViewElement alloc] init] autorelease];
            tmp.view = newView;
            tmp.viewIndexInScrollView = viewIndex;
            [viewsCache addObject:tmp]; // yes, put it in cache with current index
        }
    }
}

- (void) rearrangeSubViews:(int)newIndex
{
    if (newIndex > old_index) { // scroll right
        
        if (!dataSource)
            return;
        
        // maybe it's not good, but if caching will be turned off during process? so less chance to crash
        UIView *tmp = nil;
        if (self.enableCaching) {
            BOOL foundViewInCache = NO;
            for (int i = 0; i < [viewsCache count]; ++i) {
                if ([[viewsCache objectAtIndex:i] viewIndexInScrollView] == newIndex+1) {
                    tmp = [[viewsCache objectAtIndex:i] view];
                    foundViewInCache = YES;
                    // view was found in cache
                    break;
                }
            }
            if (!foundViewInCache && [dataSource respondsToSelector:@selector(customScrollView:viewAtIndex:)]) {
                // view was taken from datasource, not found in cache
                tmp = [dataSource customScrollView:self viewAtIndex:newIndex+1];
            }
        }
        else
            if ([dataSource respondsToSelector:@selector(customScrollView:viewAtIndex:)])
                tmp = [dataSource customScrollView:self viewAtIndex:newIndex+1];
        
        for (int i = 0; i < views_map.count; ++i)  {
            if ([[views_map objectAtIndex:i] integerValue] != newIndex &&
                [[views_map objectAtIndex:i] integerValue] != newIndex-1)   {
                [views_map removeObjectAtIndex:i];
                [[[self subviews] objectAtIndex:i] removeFromSuperview];
            }
        }
        
        [self placeView:tmp index:newIndex+1];    // show our view
    }
    
    if (old_index > newIndex) { // scrolling left
        
        if (!dataSource)
            return;
        
        UIView *tmp = nil;
        if (self.enableCaching) {
            BOOL foundViewInCache = NO;
            for (int i = 0; i < [viewsCache count]; ++i) {
                if ([[viewsCache objectAtIndex:i] viewIndexInScrollView] == newIndex-1) {
                    tmp = [[viewsCache objectAtIndex:i] view];
                    foundViewInCache = YES;
                    break;
                }
            }
            if (!foundViewInCache && [dataSource respondsToSelector:@selector(customScrollView:viewAtIndex:)]) {
                tmp = [dataSource customScrollView:self viewAtIndex:newIndex-1];
            }
        }
        else
            if ([dataSource respondsToSelector:@selector(customScrollView:viewAtIndex:)])
                tmp = [dataSource customScrollView:self viewAtIndex:newIndex-1];
        
        for (int i = 0; i < views_map.count; ++i)  {
            if ([[views_map objectAtIndex:i] integerValue] != newIndex &&
                [[views_map objectAtIndex:i] integerValue] != newIndex+1)   {
                [views_map removeObjectAtIndex:i];
                [[[self subviews] objectAtIndex:i] removeFromSuperview];
            }
        }
        
        [self placeView:tmp index:newIndex-1];
        
    }

}


- (void) layoutSubviews
{
    if (self.frame.size.height != [self.old_height intValue] || self.frame.size.width != [self.old_width intValue])   // if rotated
    {
        // calc new placement and place forms on scrollView
        old_index = self.currentViewIndex;
        int xOffset = (int)self.frame.size.width * (self.currentViewIndex);
        int yOffset = (int)self.frame.size.height * (self.currentViewIndex);
        
        // clear cache. We will need new cache for new device orientation
        // clear all views
        if (self.enableCaching) 
            [viewsCache removeAllObjects];
        [views_map removeAllObjects];
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // set new bounds for scrollView
        if (self.isHorizontal) {
            [self setContentSize:CGSizeMake(self.frame.size.width*self.elementsCount,self.frame.size.height)];
            [self setContentOffset:CGPointMake(xOffset, 0) animated:NO];
        }
        else {
            [self setContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height*self.elementsCount)];
            [self setContentOffset:CGPointMake(0, yOffset) animated:NO];
        }
        
        [self placeView:[dataSource customScrollView:self viewAtIndex:self.currentViewIndex-1] index:self.currentViewIndex-1];
        [self placeView:[dataSource customScrollView:self viewAtIndex:self.currentViewIndex] index:self.currentViewIndex];
        [self placeView:[dataSource customScrollView:self viewAtIndex:self.currentViewIndex+1] index:self.currentViewIndex+1];
    }
    self.old_height = [NSNumber numberWithInt:(int)self.frame.size.height];
    self.old_width = [NSNumber numberWithInt:(int)self.frame.size.width];
}


- (void) removeAllItems
{
    // clear cache. We will need new cache for new device orientation
    // clear all views
    if (self.enableCaching) 
        [viewsCache removeAllObjects];
    [views_map removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void) dealloc
{
    old_width = nil;
    old_height = nil;
    
    viewsCache = nil;
    views_map = nil;
    [super dealloc];
}


@end
