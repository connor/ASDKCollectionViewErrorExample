/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "ASBaselinePositionedLayout.h"

#import "ASLayoutSpecUtilities.h"
#import "ASStackLayoutSpecUtilities.h"

static CGFloat baselineForItem(const ASBaselineLayoutSpecStyle &style,
                               const ASLayout *layout) {

  __weak id<ASBaselineLayoutable> child = (id<ASBaselineLayoutable>) layout.layoutableObject;
  switch (style.baselineAlignment) {
    case ASBaselineLayoutBaselineAlignmentNone:
      return 0;
    case ASBaselineLayoutBaselineAlignmentFirst:
      return child.ascender;
    case ASBaselineLayoutBaselineAlignmentLast:
      return layout.size.height + child.descender;
  }

}

static CGFloat baselineOffset(const ASBaselineLayoutSpecStyle &style,
                              const ASLayout *l,
                              const CGFloat maxAscender,
                              const CGFloat maxBaseline)
{
  if (style.stackLayoutStyle.direction == ASStackLayoutDirectionHorizontal) {
    __weak id<ASBaselineLayoutable> child = (id<ASBaselineLayoutable>)l.layoutableObject;
    switch (style.baselineAlignment) {
      case ASBaselineLayoutBaselineAlignmentFirst:
        return maxAscender - child.ascender;
      case ASBaselineLayoutBaselineAlignmentLast:
        return maxBaseline - baselineForItem(style, l);
      case ASBaselineLayoutBaselineAlignmentNone:
        return 0;
    }
  }
  return 0;
}

static CGFloat maxDimensionForLayout(const ASLayout *l,
                                     const ASStackLayoutSpecStyle &style)
{
  CGFloat maxDimension = crossDimension(style.direction, l.size);
  style.direction == ASStackLayoutDirectionVertical ? maxDimension += l.position.x : maxDimension += l.position.y;
  return maxDimension;
}

ASBaselinePositionedLayout ASBaselinePositionedLayout::compute(const ASStackPositionedLayout &positionedLayout,
                                                                 const ASBaselineLayoutSpecStyle &style,
                                                                 const ASSizeRange &constrainedSize)
{
  ASStackLayoutSpecStyle stackStyle = style.stackLayoutStyle;

  /* Step 1: Look at each child and determine the distance from the top of the child node it's baseline.
     For  example, let's say we have the following two text nodes and want to align them to the first baseline:

     Hello!    Why, hello there! How
               are you today?

     The first node has a font of size 14, the second a font of size 12. The first node will have a baseline offset of
     the ascender of a font of size 14, the second will have a baseline of the ascender of a font of size 12. The first
     baseline will be larger so we will keep that as the max baseline.

     However, if were to align from the last baseline we'd find the max baseline by taking the height of node and adding
     the font's descender (its negative). In the case of the first node, which is only 1 line, this should be the same value as the ascender.
     The second node, however, has a larger height and there will have a larger baseline offset.
   */
  const auto baselineIt = std::max_element(positionedLayout.sublayouts.begin(), positionedLayout.sublayouts.end(), [&](const ASLayout *a, const ASLayout *b){
    return baselineForItem(style, a) < baselineForItem(style, b);
  });
  const CGFloat maxBaseline = baselineIt == positionedLayout.sublayouts.end() ? 0 : baselineForItem(style, *baselineIt);

  /*
    Step 2: Find the max ascender for all of the children.
    Imagine 3 nodes aligned horizontally, all with the same text but with font sizes of 12, 14, 16. Because it is has the largest
    ascender node with font size of 16 will not need to move, the other two nodes will align to this node's baseline. The offset we will use
    for each node is our computed maxAscender - node.ascender. If the 16pt node had an ascender of 10 and the 14pt node
    had an ascender of 8, that means we will offset the 14pt node by 2 pts.

    Note: if we are alinging to the last baseline, then we don't need this value in our computation. However, we do want
    our layoutSpec to have it so that it can be baseline aligned with another text node or baseline layout spec.
   */
  const auto ascenderIt = std::max_element(positionedLayout.sublayouts.begin(), positionedLayout.sublayouts.end(), [&](const ASLayout *a, const ASLayout *b){
    return ((id<ASBaselineLayoutable>)a.layoutableObject).ascender < ((id<ASBaselineLayoutable>)b.layoutableObject).ascender;
  });
  const CGFloat maxAscender = baselineIt == positionedLayout.sublayouts.end() ? 0 : ((id<ASBaselineLayoutable>)(*ascenderIt).layoutableObject).ascender;

  /*
    Step 3: Take each child and update its layout position based on the baseline offset.

    If this is a horizontal stack, we take a positioned child and add to its y offset to align it to the maxBaseline of the children.
    If this is a vertical stack, we add the child's descender to the location of the next child to position. This will ensure the
    spacing between the two nodes is from the baseline, not the bounding box.

  */
  CGPoint p = CGPointZero;
  BOOL first = YES;
  auto stackedChildren = AS::map(positionedLayout.sublayouts, [&](ASLayout *l) -> ASLayout *{
    __weak id<ASBaselineLayoutable> child = (id<ASBaselineLayoutable>) l.layoutableObject;
    p = p + directionPoint(stackStyle.direction, child.spacingBefore, 0);
    if (first) {
      // if this is the first item use the previously computed start point
      p = l.position;
    } else {
      // otherwise add the stack spacing
      p = p + directionPoint(stackStyle.direction, stackStyle.spacing, 0);
    }
    first = NO;

    // Find the difference between this node's baseline and the max baseline of all the children. Add this difference to the child's y position.
    l.position = p + CGPointMake(0, baselineOffset(style, l, maxAscender, maxBaseline));

    // If we are a vertical stack, add the item's descender (it is negative) to the offset for the next node. This will ensure we are spacing
    // node from baselines and not bounding boxes.
    CGFloat spacingAfterBaseline = 0;
    if (stackStyle.direction == ASStackLayoutDirectionVertical) {
      spacingAfterBaseline = child.descender;
    }
    p = p + directionPoint(stackStyle.direction, stackDimension(stackStyle.direction, l.size) + child.spacingAfter + spacingAfterBaseline, 0);

    return l;
  });

  /*
    Step 4: Since we have been mucking with positions, there is a chance that our cross size has changed. Imagine a node with a font size of 40
    and another node with a font size of 12 but with multiple lines. We align these nodes to the first baseline, which will be the baseline of the node with
    font size of 40 (max ascender). Now, we have to move the node with multiple lines down to the other node's baseline. This node with multiple lines will
    extend below the first node farther than it did before aligning the baselines thus increasing the cross size.

    After finding the new cross size, we need to clamp it so that it fits within the constrainted size.

   */
  const auto it = std::max_element(stackedChildren.begin(), stackedChildren.end(),
                                   [&](ASLayout *a, ASLayout *b) {
                                     return maxDimensionForLayout(a, stackStyle) < maxDimensionForLayout(b, stackStyle);
                                   });
  const auto largestChildCrossSize = it == stackedChildren.end() ? 0 : maxDimensionForLayout(*it, stackStyle);
  const auto minCrossSize = crossDimension(stackStyle.direction, constrainedSize.min);
  const auto maxCrossSize = crossDimension(stackStyle.direction, constrainedSize.max);
  const CGFloat crossSize = MIN(MAX(minCrossSize, largestChildCrossSize), maxCrossSize);

  /*
     Step 5: finally, we must find the smallest descender (descender is negative). This is since ASBaselineLayoutSpec implements
     ASBaselineLayoutable and needs an ascender and descender to lay itself out properly.
   */
  const auto descenderIt = std::max_element(stackedChildren.begin(), stackedChildren.end(), [&](const ASLayout *a, const ASLayout *b){
    return  a.position.y + a.size.height <  b.position.y + b.size.height;
  });
  const CGFloat minDescender = descenderIt == stackedChildren.end() ? 0 : ((id<ASBaselineLayoutable>)(*descenderIt).layoutableObject).descender;

  return {stackedChildren, crossSize, maxAscender, minDescender};
}