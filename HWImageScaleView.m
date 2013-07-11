//
//  HWImageScaleView.m
//  HWImageScrollView
//
//  Created by Howard on 13/7/9.
//  Copyright (c) 2013年 howard. All rights reserved.
//

#import "HWImageScaleView.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface HWImageScaleView()
{
@private
    id<HWImageScaleViewDelegate> delegate;
    BOOL                         supportDoubleClickScale_;
    BOOL                         supportPageLabelShow_;
    CGFloat                      boundaryBottomRatio_;
    CGFloat                      boundaryLeftRatio_;
    CGFloat                      boundaryRightRatio_;
    CGFloat                      boundaryTopRatio_;
    CGFloat                      pageLabelHeightRatio_;
    
    UIImageView                  *scaleContentView_;
    UIScrollView                 *scaleScrollView_;
    UITapGestureRecognizer       *doubleTapGestureRecognizer_;
    UITapGestureRecognizer       *oneTapGestureRecognizer_;
}

@property (nonatomic,retain) UIImageView            *scaleContentView;
@property (nonatomic,retain) UIScrollView           *scaleScrollView;
@property (nonatomic,retain) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic,retain) UITapGestureRecognizer *oneTapGestureRecognizer;

- (void)scaleContentViewImageFitSize;

- (CGFloat)bottom;
- (CGFloat)left;
- (CGFloat)right;
- (CGFloat)top;

- (CGRect)scaleContentViewFrame;
- (CGRect)scaleScrollViewFrame;

- (void)handleDoubleTapWithGestureRecongnizer:(UIGestureRecognizer *)gestureRecognizer;
- (void)handleSingleTapWithGestureRecongnizer:(UIGestureRecognizer *)gestureRecognizer;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - HWImageScaleView

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HWImageScaleView

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Synthesize

@synthesize delegate                   = delegate;
@synthesize supportDoubleClickScale    = supportDoubleClickScale_;
@synthesize supportPageLabelShow       = supportPageLabelShow_;
@synthesize boundaryBottomRatio        = boundaryBottomRatio_;
@synthesize boundaryLeftRatio          = boundaryLeftRatio_;
@synthesize boundaryRightRatio         = boundaryRightRatio_;
@synthesize boundaryTopRatio           = boundaryTopRatio_;
@synthesize pageLabelHeightRatio       = pageLabelHeightRatio_;
@synthesize scaleContentView           = scaleContentView_;
@synthesize scaleScrollView            = scaleScrollView_;
@synthesize doubleTapGestureRecognizer = doubleTapGestureRecognizer_;
@synthesize oneTapGestureRecognizer    = oneTapGestureRecognizer_;

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Creating, Copying, and Deallocating Objects

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        supportPageLabelShow_ = YES;
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        boundaryBottomRatio_  = BoundaryDefaultBottomRatio;
        boundaryLeftRatio_    = BoundaryDefaultLeftRatio;
        boundaryTopRatio_     = BoundaryDefaultTopRatio;
        boundaryRightRatio_   = BoundaryDefaultRightRatio;
        pageLabelHeightRatio_ = PageLableDefaultHeightRatio;
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        scaleScrollView_ = [[UIScrollView alloc]initWithFrame:[self scaleScrollViewFrame]];
        
        scaleScrollView_.contentMode                    = UIViewContentModeScaleAspectFit;
        scaleScrollView_.backgroundColor                = [UIColor clearColor];
        
        scaleScrollView_.decelerationRate               = UIScrollViewDecelerationRateFast;
        scaleScrollView_.delegate                       = self;
        
        scaleScrollView_.alwaysBounceHorizontal		    = NO;
		scaleScrollView_.alwaysBounceVertical		    = NO;
		scaleScrollView_.bounces						= YES;
		scaleScrollView_.bouncesZoom					= NO;
        
		scaleScrollView_.canCancelContentTouches		= NO;
        scaleScrollView_.clipsToBounds				    = YES;
        scaleScrollView_.exclusiveTouch                 = YES;
		scaleScrollView_.showsHorizontalScrollIndicator = NO;
		scaleScrollView_.showsVerticalScrollIndicator   = NO;
        scaleScrollView_.maximumZoomScale               = DefaultMaxRoomScale;
        scaleScrollView_.minimumZoomScale               = DefaultMinRoomScale;
        scaleScrollView_.scrollsToTop                   = NO;
        
        [self addSubview:scaleScrollView_];
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        scaleContentView_ = [[UIImageView alloc]initWithFrame:[self scaleContentViewFrame]];
        scaleContentView_.contentMode = UIViewContentModeScaleAspectFit;
        scaleContentView_.backgroundColor = [UIColor clearColor];
        [scaleScrollView_ addSubview:scaleContentView_];
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        oneTapGestureRecognizer_ = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTapWithGestureRecongnizer:)];
        
        [self addGestureRecognizer:oneTapGestureRecognizer_];
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // 雙擊的 Recognizer
        doubleTapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapWithGestureRecongnizer:)];
        
        [self setSupportDoubleClickScale:YES];
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        [oneTapGestureRecognizer_ requireGestureRecognizerToFail:doubleTapGestureRecognizer_];
    }
    
    return self;
}

- (void)dealloc
{
    [scaleContentView_ removeFromSuperview];
    [scaleContentView_ release];
    
    [scaleScrollView_ removeFromSuperview];
    [scaleScrollView_ release];
    
    [self removeGestureRecognizer:oneTapGestureRecognizer_];
    [oneTapGestureRecognizer_ release];
    
    [self removeGestureRecognizer:doubleTapGestureRecognizer_];
    [doubleTapGestureRecognizer_ release];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    [super dealloc];
}

#pragma mark - Layout of Subviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    [self.scaleScrollView setZoomScale:DefaultMinRoomScale animated:NO];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self.scaleScrollView.frame  = [self scaleScrollViewFrame];
    self.scaleContentView.frame = [self scaleContentViewFrame];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    if(self.scaleContentView.image!=nil)
    {
        [self scaleContentViewImageFitSize];
        
        self.scaleScrollView.frame  = CGRectMake(0,0,self.scaleContentView.frame.size.width,self.scaleContentView.frame.size.height);
        
        self.scaleScrollView.center = CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2);
        
        self.scaleScrollView.contentSize = self.scaleContentView.frame.size;
        self.scaleScrollView.contentOffset = CGPointMake(0,0);
        
    }
    
}


#pragma mark - HWImageScaleView delegate Method


////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.scaleContentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    // 小於螢幕大小
    if(self.scaleScrollView.zoomScale<DefaultMinRoomScale)
    {
        [self.scaleScrollView setZoomScale:1.0f animated:YES];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Accessory Method

- (void)setSupportDoubleClickScale:(BOOL)supportDoubleClickScale
{
    supportDoubleClickScale_ = supportDoubleClickScale;
    
    if(supportDoubleClickScale_==YES)
    {
        if(self.doubleTapGestureRecognizer!=nil)
        {
            self.doubleTapGestureRecognizer.numberOfTapsRequired    = 2;
            [self addGestureRecognizer:self.doubleTapGestureRecognizer];
        }
    }
    else
    {
        [self removeGestureRecognizer:self.doubleTapGestureRecognizer];
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Private Method

- (void)scaleContentViewImageFitSize
{
    UIImage *image = self.scaleContentView.image;
    
    if(image!=nil)
    {
        CGFloat x_ratio = self.scaleScrollView.frame.size.width / self.scaleContentView.image.size.width;
        CGFloat y_ratio = self.scaleScrollView.frame.size.height / self.scaleContentView.image.size.height;
        CGFloat min_ratio = MIN(x_ratio,y_ratio);
        
        self.scaleContentView.frame = CGRectMake(0,0,self.scaleContentView.image.size.width*min_ratio,self.scaleContentView.image.size.height*min_ratio);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Boundary Method

- (CGFloat)bottom
{
    return self.bounds.size.height*self.boundaryBottomRatio;
}

- (CGFloat)top
{
    return self.bounds.size.height*self.boundaryTopRatio;
}

- (CGFloat)right
{
    return self.bounds.size.width*self.boundaryRightRatio;
}

- (CGFloat)left
{
    return self.bounds.size.width*self.boundaryLeftRatio;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Get Frame

- (CGRect)scaleContentViewFrame
{
    return self.scaleScrollView.bounds;
}

- (CGRect)scaleScrollViewFrame
{
    if(self.supportPageLabelShow==YES)
    {
        return CGRectMake(self.bounds.origin.x+[self left],self.bounds.origin.y+[self top],self.bounds.size.width-[self left]-[self right],self.bounds.size.height-[self top]);
    }
    else
    {
        return CGRectMake(self.bounds.origin.x+[self left],self.bounds.origin.y+[self top],self.bounds.size.width-[self left]-[self right],self.bounds.size.height-[self top]-[self bottom]);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark- HandleGestureEvent

- (void)handleDoubleTapWithGestureRecongnizer:(UIGestureRecognizer *)gestureRecognizer
{
    float newScale = DefaultMinRoomScale;
    
    if( [self.scaleScrollView zoomScale] >= DefaultMaxRoomScale)
    {
        newScale = DefaultMinRoomScale;
    }
    else
    {
        newScale = DefaultMaxRoomScale;
    }
    
    [self.scaleScrollView setZoomScale:newScale animated:YES];
}

- (void)handleSingleTapWithGestureRecongnizer:(UIGestureRecognizer *)gestureRecognizer
{
    if([self.delegate respondsToSelector:@selector(imageScaleViewDidSingleTouch:)]==YES)
    {
        [self.delegate imageScaleViewDidSingleTouch:self];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Instance Method

- (UIImage *)contentImage
{
    return self.scaleContentView.image;
}

- (void)setContentImage:(UIImage *)image
{
    if(image!=nil)
    {
        [self.scaleScrollView setZoomScale:DefaultMinRoomScale animated:NO];
        
        self.scaleContentView.image = image;
        
        [self scaleContentViewImageFitSize];
    }
}

@end

