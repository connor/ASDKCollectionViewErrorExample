//
//  AppKitCollectionViewCell.m
//  ASDKCollectionViewDemo
//
//  Created by Connor Montgomery on 9/3/15.
//  Copyright (c) 2015 Connor Montgomery. All rights reserved.
//

#import "AppKitCollectionViewCell.h"

@interface AppKitCollectionViewCell()

@property (nonatomic, strong) UILabel *label;

@end

@implementation AppKitCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.font = [UIFont systemFontOfSize:18.0f];
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = CGRectMake(0, 0, CGRectGetWidth(self.label.frame), CGRectGetHeight(self.label.frame));
}

- (void)prepareForReuse
{
    self.text = nil;
    self.textColor = [UIColor blackColor];
    self.selected = NO;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.label.textColor = textColor;
    [self.label setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.label.text = text;
    [self.label sizeToFit];
}

@end
