/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <AsyncDisplayKit/ASStackLayoutable.h>

/** A layout spec is an immutable object that describes a layout, loosely inspired by React. */
@interface ASLayoutSpec : NSObject <ASStackLayoutable>

/**
 Creation of a layout spec should only happen by a user in layoutSpecThatFits:. During that method, a
 layout spec can be created and mutated. Once it is passed back to ASDK, the isMutable flag will be
 set to NO and any further mutations will cause an assert.
 */
@property (nonatomic, assign) BOOL isMutable;

- (instancetype)init;

@end
