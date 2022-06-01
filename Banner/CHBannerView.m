//
//  CHBannerView.m
//  Banner
//
//  Created by Charlie.Hsu on 2022/5/31.
//

#import "CHBannerView.h"

@interface CHBannerView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, assign) CHBannerViewDirection direct;
@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) CGFloat timerInterval;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) BOOL isTimerSuspend;
@end



@implementation CHBannerView

-(instancetype)initWithDirect:(CHBannerViewDirection)direction timerInterval:(CGFloat)timerInterval {
    if (self = [super init]) {
        self.currentIndex = 0;
        self.timerInterval = timerInterval;
        self.direct = direction;
        self.dataSource = [[NSMutableArray alloc]init];
        [self setupUI];
//        [self setupTimer];
    }
    return self;
}


//-(void) setupTimer {
//
//    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(move:) userInfo:nil repeats:YES];
//    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
//    self.timer = timer;
//    [self.timer invalidate];
//    self.isTimerValidate = NO;
//}

-(void)start {
    dispatch_resume(self.timer);
    self.isTimerSuspend = NO;
}

-(void)stop {
    dispatch_suspend(self.timer);
    self.isTimerSuspend = YES;
}

-(void) invalidate {
    if (_timer) {
        if (self.isTimerSuspend) {
            dispatch_resume(_timer);
        }
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

-(void) setupUI {
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];

    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.collectionView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
        [self.collectionView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        
        [self.pageControl.leftAnchor constraintEqualToAnchor:self.leftAnchor],
        [self.pageControl.rightAnchor constraintEqualToAnchor:self.rightAnchor],
        [self.pageControl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
}

//MARK: - Event

-(void) move {
    if (self.currentIndex >= self.dataSource.count) { return; }
    if (self.currentIndex == self.dataSource.count-1) {
        //最後一筆
        self.currentIndex = 0;
        self.pageControl.currentPage = 0;
        [self.collectionView setContentOffset:CGPointZero];
        return;
    }
    [self updateCurrentIndexWith:self.currentIndex+1 animated:YES];
}


-(void) updateCurrentIndexWith:(NSUInteger) currentIndex animated:(BOOL) animated {
    self.currentIndex = currentIndex;
    self.pageControl.currentPage = self.currentIndex;
    if (self.direct == CHBannerViewDirectionHorizontal) {
        CGFloat pointX = self.collectionView.frame.size.width* self.currentIndex;
        [self.collectionView setContentOffset:CGPointMake(pointX, 0) animated:animated];
    }else if (self.direct == CHBannerViewDirectionVertical) {
        self.pageControl.currentPage = self.currentIndex;
        CGFloat pointY = self.collectionView.frame.size.height* self.currentIndex;
        [self.collectionView setContentOffset:CGPointMake(0, pointY) animated:animated];
    }
}


//MARK: - ScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stop];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (velocity.x > 0) {
        //向右滑
        CGFloat lastX = scrollView.contentSize.width-scrollView.frame.size.width;
        BOOL isLast = (scrollView.contentOffset.x > lastX);
        if (isLast && targetContentOffset->x == lastX) {
            //已經在最右邊, 繼續往右滑
            [self updateCurrentIndexWith:0 animated:NO];
            targetContentOffset->x = 0;
        }
        
    }else{
        //向左滑
    
        if (scrollView.contentOffset.x < 0 && targetContentOffset->x == 0) {
            //已在最左邊, 向左滑
            [self updateCurrentIndexWith:self.dataSource.count-1 animated:NO];
            targetContentOffset->x = scrollView.contentSize.width - scrollView.frame.size.width;
        }
        
        
    }
    
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //算出index
    if (self.direct == CHBannerViewDirectionHorizontal) {
        NSUInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
        self.currentIndex = index;
        self.pageControl.currentPage = index;
    }else if (self.direct == CHBannerViewDirectionVertical) {
        NSUInteger index = scrollView.contentOffset.y / scrollView.frame.size.height;
        self.currentIndex = index;
        self.pageControl.currentPage = index;
    }
    [self start];
}


//MARK: - CollectionDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CHBannerViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CHBannerViewCell" forIndexPath:indexPath];
    if (self.dataSource.count > indexPath.row) {
        cell.model = self.dataSource[indexPath.row];
    }
    return cell;
}

//MARK: - CollectionDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate) {
        [self.delegate banner:self didSelectItemAtIndexPath:indexPath];
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}


//MARK: - Init
-(UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = (self.direct == CHBannerViewDirectionVertical ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.backgroundColor = UIColor.redColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[CHBannerViewCell class] forCellWithReuseIdentifier:@"CHBannerViewCell"];
    }
    return _collectionView;
}


-(UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.pageIndicatorTintColor = self.pageIndicatorTintColor;
        _pageControl.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor;
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pageControl;
}


-(void)setDataSource:(NSMutableArray<CHBannerModel *> *)dataSource {
    _dataSource = dataSource;
    
    if (NSThread.currentThread) {
        self.pageControl.numberOfPages = dataSource.count;
        self.pageControl.currentPage = 0;
        [self.collectionView reloadData];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pageControl.numberOfPages = dataSource.count;
            self.pageControl.currentPage = 0;
            [self.collectionView reloadData];
        });
    }
}

-(void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

-(void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

- (dispatch_source_t)timer {
    if (!_timer) {
        
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, self.timerInterval * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_timer, ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf move];
        });
    }
    return _timer;
}



@end





@interface CHBannerViewCell()
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) UIStackView* vStackView;
@end
@implementation CHBannerViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}


-(void) setup {
    [self.contentView addSubview:self.vStackView];
    [self.vStackView addArrangedSubview:self.imageView];
    [self.vStackView addArrangedSubview:self.label];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.vStackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.vStackView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor],
        [self.vStackView.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor],
        [self.vStackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
    ]];

}

-(void)setModel:(CHBannerModel *)model {
    if (_model == model) { return; }
    _model = model;
    
    if (model.text) {
        self.imageView.hidden = YES;
        self.label.hidden = NO;
        self.label.text = model.text;
    }else{
        self.imageView.hidden = NO;
        self.label.hidden = YES;
        self.imageView.image = model.image;
    }
    
}



//MARK: - Init
-(UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}


-(UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc]init];
    }
    return _label;
}


-(UIStackView *)vStackView {
    if (!_vStackView) {
        _vStackView = [[UIStackView alloc]init];
        _vStackView.translatesAutoresizingMaskIntoConstraints = NO;
        _vStackView.axis = UILayoutConstraintAxisVertical;
    }
    return _vStackView;
}

@end


@implementation CHBannerModel
@end

