//
//  CCLoginBackgroundView.m
//  ClickTheCity
//
//  Created by Mario Antonio Cape on 2/11/15.
//
//

#import "CCLoginBackgroundView.h"
#import <GPUImage/GPUImagePicture.h>
#import <GPUImage/GPUImageiOSBlurFilter.h>

#define iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define iOS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface CCGradientView : UIView

@end


@implementation CCGradientView

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

@end

@interface CCLoginBackgroundView()
@property (nonatomic, strong) CCGradientView * gradientView;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) id visualEffectView;
@property (nonatomic, assign) BOOL blur;
@end

@implementation CCLoginBackgroundView{
    dispatch_source_t _timer;
    GPUImageiOSBlurFilter * _blurFilter;;
}

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.currentIndex = -1;
        [self addSubview:self.imageView];
        [self addSubview:self.gradientView];
        
        if (iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
            UIVisualEffect *blurEffect;
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *visualEffectView;
            visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            visualEffectView.frame = self.bounds;
            self.visualEffectView = visualEffectView;
        }
    }
    return self;
}

- (void) layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.gradientView.frame = self.bounds;
    if (iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        ((UIVisualEffectView *)self.visualEffectView).frame = self.bounds;
    }
}

- (UIImageView *) imageView{
    if (_imageView == nil){
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    return _imageView;
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    self.imageView.contentMode = contentMode;
}


- (void) setImages:(NSArray *)images{
    _images = images;
    self.currentIndex = -1;
    [self changeImage];
}

- (CCGradientView *) gradientView{
    if (_gradientView == nil){
        _gradientView = [[CCGradientView alloc] initWithFrame:self.bounds];
        _gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _gradientView;
}

- (void) changeImage{
    if (self.images.count == 0) return;
    if (++self.currentIndex >= self.images.count){
        self.currentIndex = 0;
    }
    UIImage * toImage = self.images[self.currentIndex];
    if (self.blur && iOS_VERSION_LESS_THAN(@"8.0")){
        if (_blurFilter == nil){
            _blurFilter = [[GPUImageiOSBlurFilter alloc] init];
            _blurFilter.blurRadiusInPixels = 2.5f;
        }
        GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:toImage];
        [picture addTarget:_blurFilter];
        [picture processImageUpToFilter:_blurFilter withCompletionHandler:^(UIImage *processedImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView transitionWithView:self.imageView
                                  duration:1.0f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    self.imageView.image = processedImage;
                                } completion:^(BOOL finished) {
                                    if (finished){
                                        [_blurFilter removeAllTargets];
                                        [self startTimer];
                                    }
                                }];
            });
        }];
    }else{
        [UIView transitionWithView:self.imageView
                          duration:1.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.imageView.image = toImage;
                        } completion:^(BOOL finished) {
                            if (finished){
                                [self startTimer];
                            }
                        }];
    }
}


dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}


- (void)startTimer
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    double secondsToFire = 6.000f;
    
    _timer = CreateDispatchTimer(secondsToFire, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeImage];
        });
    });
}

- (void) startSlideShow{
    [self cancelTimer];
    [self startTimer];
}

- (void)cancelTimer{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void) blurImage: (BOOL) blur{
    self.blur = blur;
    if (iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        if (blur){
            [self addSubview:self.visualEffectView];
        }else{
            [self.visualEffectView removeFromSuperview];
        }
    }else{
        UIImage * toImage = self.images[self.currentIndex];
        if (blur){
            if (_blurFilter == nil){
                _blurFilter = [[GPUImageiOSBlurFilter alloc] init];
                _blurFilter.blurRadiusInPixels = 2.5f;
            }
            GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:toImage];
            [picture addTarget:_blurFilter];
            [picture processImageUpToFilter:_blurFilter withCompletionHandler:^(UIImage *processedImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = processedImage;
                    [_blurFilter removeAllTargets];
                });
            }];
        }else{
            self.imageView.image = toImage;
        }
    }
}

- (void) invalidateSlideShow{
    [self cancelTimer];
}

- (void) dealloc{
    [self cancelTimer];
}

@end
