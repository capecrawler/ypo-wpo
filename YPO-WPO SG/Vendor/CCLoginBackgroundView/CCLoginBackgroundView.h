//
//  CCLoginBackgroundView.h
//  ClickTheCity
//
//  Created by Mario Antonio Cape on 2/11/15.
//
//

#import <UIKit/UIKit.h>

@interface CCLoginBackgroundView : UIView

@property (nonatomic, strong) NSArray * images;

- (void) blurImage: (BOOL) blur;
- (void) startSlideShow;
- (void) invalidateSlideShow;

@end
