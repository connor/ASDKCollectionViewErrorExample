# ASDKCollectionViewErrorExample

Selecting an item in `ASCollectionView` immediately after initializing and adding to the view throws an error. The same code in `UICollectionView` doesn't. This is an example app to demonstrate.

# Usage

1. clone the repo.
2. `pod install`
3. toggle the `USE_ASDK` BOOL in `AppDelegate.m` to use AsyncDisplayKit or use UIKit.

# Notes

The example works great when using UIKit, but fails due to an `NSInternalInconsistencyException` when using AsyncDisplayKit.
