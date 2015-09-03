//
//  AppKitViewController.m
//  ASDKCollectionViewDemo
//
//  Created by Connor Montgomery on 9/3/15.
//  Copyright (c) 2015 Connor Montgomery. All rights reserved.
//

#import "AppKitViewController.h"
#import "AppKitCollectionViewCell.h"

@interface AppKitViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AppKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[AppKitCollectionViewCell class]
            forCellWithReuseIdentifier:[AppKitCollectionViewCell description]];
    [self.view addSubview:self.collectionView];

    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:10 inSection:0]
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionNone];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   AppKitCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[AppKitCollectionViewCell description]
                                                                               forIndexPath:indexPath];
    cell.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    if (cell.selected) {
        cell.textColor = [UIColor redColor];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

@end
