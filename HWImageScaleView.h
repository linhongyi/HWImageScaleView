//
//  HWImageScaleView.h
//  HWImageScrollView
//
//  Created by Howard on 13/7/9.
//  Copyright (c) 2013年 howard. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////////////////////

#define DefaultMaxRoomScale 3
#define DefaultMinRoomScale 1

#define PageLableDefaultFontSize    10
#define PageLableDefaultHeightRatio 0.15
#define BoundaryDefaultTopRatio     0.02
#define BoundaryDefaultBottomRatio  0.02
#define BoundaryDefaultLeftRatio    0.02
#define BoundaryDefaultRightRatio   0.02

////////////////////////////////////////////////////////////////////////////////////////////////////

@class HWImageScaleView;

@protocol HWImageScaleViewDelegate <NSObject>

@optional
 -(void)imageScaleViewDidSingleTouch:(HWImageScaleView *)imageScaleView;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - HWImageScaleView

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface HWImageScaleView : UIView<UIScrollViewDelegate>

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Property

@property (nonatomic,assign)   id<HWImageScaleViewDelegate> delegate;

//預設支持雙點擊放大縮小
@property (nonatomic,assign)   BOOL      supportDoubleClickScale;
@property (nonatomic,assign)   BOOL      supportPageLabelShow;
@property (nonatomic,assign)   CGFloat   boundaryBottomRatio;
@property (nonatomic,assign)   CGFloat   boundaryLeftRatio;
@property (nonatomic,assign)   CGFloat   boundaryRightRatio;
@property (nonatomic,assign)   CGFloat   boundaryTopRatio;
@property (nonatomic,assign)   CGFloat   pageLabelHeightRatio;

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Instance Method

- (UIImage *)contentImage;
- (void)setContentImage:(UIImage *)image;

@end