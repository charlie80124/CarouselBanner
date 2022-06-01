//
//  CHBannerView.h
//  Banner
//
//  Created by Charlie.Hsu on 2022/5/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CHBannerViewDirection){
    CHBannerViewDirectionVertical,
    CHBannerViewDirectionHorizontal

};
 
@class CHBannerView, CHBannerModel;
@protocol CHBannerViewDelegate <NSObject>
-(void) banner:(CHBannerView*) banner didSelectItemAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface CHBannerView : UIView
-(instancetype)initWithDirect:(CHBannerViewDirection) direction timerInterval:(CGFloat)timerInterval;
@property (nonatomic, strong) NSMutableArray<CHBannerModel*>* dataSource;
@property (nonatomic, weak, nullable) id<CHBannerViewDelegate>delegate;

@property (nonatomic, strong) UIColor* tintColor;

//PageControl
@property (nonatomic, strong) UIColor* currentPageIndicatorTintColor;
@property (nonatomic, strong) UIColor* pageIndicatorTintColor;
@property (nonatomic, assign) BOOL hiddenPageControl;

-(void) start;
-(void) stop;
-(void) invalidate; // need call in dealloc
@end


@interface CHBannerViewCell: UICollectionViewCell
@property (nonatomic, strong) CHBannerModel* model;
@end

@interface CHBannerModel : NSObject
@property (nonatomic, copy, nullable) NSString* url;
@property (nonatomic, strong, nullable) UIImage* image;
@property (nonatomic, copy, nullable) NSString* text;
@end

NS_ASSUME_NONNULL_END
