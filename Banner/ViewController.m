//
//  ViewController.m
//  Banner
//
//  Created by Charlie.Hsu on 2022/5/31.
//

#import "ViewController.h"
#import "CHBannerView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CHBannerView* view = [[CHBannerView alloc]initWithDirect:(CHBannerViewDirectionHorizontal) timerInterval:3];
    [self.view addSubview:view];

    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
    view.center = self.view.center;
    view.pageIndicatorTintColor = UIColor.lightGrayColor;
    view.currentPageIndicatorTintColor = UIColor.blueColor;

    NSMutableArray* arr = [[NSMutableArray alloc]init];
    for (int i = 1; i < 5 ; i++) {
        NSString* n = [NSString stringWithFormat:@"%d",i];
        UIImage* i = [UIImage imageNamed:n];
        CHBannerModel* model = [[CHBannerModel alloc]init];
        model.image = i;
        [arr addObject:model];
    }
    
//    NSMutableArray* arr = [[NSMutableArray alloc]initWithArray:@[
//        [UIImage imageNamed:@"1"],
//        [UIImage imageNamed:@"2"],
//        [UIImage imageNamed:@"3"],
//        [UIImage imageNamed:@"4"],
//    ]];
    
    view.dataSource = arr;
    [view start];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
