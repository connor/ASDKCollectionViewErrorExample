//
//  ASDKViewController.h
//  ASDKCollectionViewDemo
//
//  Created by Connor Montgomery on 9/3/15.
//  Copyright (c) 2015 Connor Montgomery. All rights reserved.
//

#import "ASDKViewController.h"
#import <AsyncDisplayKit.h>

@interface ASDKViewController () <ASCollectionViewDataSource, ASCollectionViewDelegate>

@property (nonatomic, strong) ASCollectionView *collectionView;

@end

@implementation ASDKViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    self.collectionView = [[ASCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.asyncDataSource = self;
    self.collectionView.asyncDelegate = self;
    [self.view addSubview:self.collectionView];

    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionNone];
}

- (ASCellNode *)collectionView:(ASCollectionView *)collectionView nodeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ASTextCellNode *cellNode = [[ASTextCellNode alloc] init];
    cellNode.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cellNode;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

@end
