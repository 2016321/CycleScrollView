//
//  CycleScrollView+Protocol.swift
//  CycleScrollViewDemo
//
//  Created by 王昱斌 on 17/4/17.
//  Copyright © 2017年 Qtin. All rights reserved.
//

import Foundation



@objc
public enum CycleScrollViewTransformerType : Int {
    case linear
}

@objc
public enum CycleScrollViewDirection : Int {
    case horizontal
    case vertical
}

@objc
public protocol CycleScrollViewDataSource: NSObjectProtocol {
    
    @objc(numberOfItemsInCycleScrollView:)
    /// how many items in the cycleScrollView
    ///
    /// - Parameter cycleScrollView: cycleScrollView description
    /// - Returns: return value description
    /// cycleScrollView中有多少item
    func numberOfItems(in cycleScrollView : CycleScrollView) -> Int
    
    @objc(cycleScrollView:cellForItemAtIndexPath:)
    /// return the cell in the cycleScrollView
    ///
    /// - Parameters:
    ///   - cycleScrollView: cycleScrollView description
    ///   - indexPath: indexPath description
    /// - Returns: return value description
    /// 根据indexPath返回cell
    func cycleScrollView(_ cycleScrollView: CycleScrollView, cellForItemAt indexPath: Int) -> CycleScrollViewCell
    
}

@objc
public protocol CycleScrollViewDelegate: NSObjectProtocol {
    
    @objc(cycleScrollView:shouldHighlightItemAtIndex:)
    ///  the item should be highlighted during tracking.
    ///
    /// - Parameters:
    ///   - cycleScrollView: cycleScrollView description
    ///   - index: index description
    /// - Returns: return value description
    /// item是否需要高亮
    optional func cycleScrollView(_ cycleScrollView: CycleScrollView, shouldHighlightItemAt index: Int) -> Bool
    
    @objc(cycleScrollView:didHighlightItemAtIndex:)
    /// item at the specified index was highlighted.
    ///
    /// - Parameters:
    ///   - cycleScrollView: cycleScrollView description
    ///   - index: index description
    /// - Returns: return value description
    /// 具体的一个item高亮
    optional func cycleScrollView(_ cycleScrollView: CycleScrollView, didHighlightItemAt index: Int)
    
    @objc(cycleScrollView:shouldSelectItemAtIndex:)
    /// if the specified item should be selected.
    ///
    /// - Parameters:
    ///   - cycleScrollView: cycleScrollView description
    ///   - index: index description
    /// - Returns: return value description
    /// 如果item高亮的回调
    optional func cycleScrollView(_ cycleScrollView: CycleScrollView, shouldSelectItemAt index: Int) -> Bool
    
    @objc(cycleScrollView:didSelectItemAtIndex:)
    /// the item at the specified index was selected.
    ///
    /// - Parameters:
    ///   - cycleScrollView: cycleScrollView description
    ///   - index: index description
    /// item 被点击
    optional func cycleScrollView(_ cycleScrollView: CycleScrollView, didSelectItemAt index: Int)
    
    @objc(cycleScrollView:willDisplayCell:forItemAtIndex:)
    /// the specified cell is about to be displayed in the pager view.
    ///
    /// - Parameters:
    ///   - cycleScrollView: cycleScrollView description
    ///   - cell: cell description
    ///   - index: index description
    /// 当item将要被展示时候
    optional func cycleScrollView(_ cycleScrollView: CycleScrollView, willDisplay cell: CycleScrollViewCell, forItemAt index: Int)
    
    @objc(cycleScrollView:didEndDisplayingCell:forItemAtIndex:)
    /// the specified cell was removed from the pager view.
    ///
    /// - Parameters:
    ///   - cycleScrollView: cycleScrollView description
    ///   - cell: cell description
    ///   - index: index description
    /// 当item将要消失
    optional func cycleScrollView(_ cycleScrollView: CycleScrollView, didEndDisplaying cell: CycleScrollViewCell, forItemAt index: Int)
    
    @objc(cycleScrollViewWillBeginDragging:)
    /// when the pager view is about to start scrolling the content.
    ///
    /// - Parameter cycleScrollView: cycleScrollView description
    /// 当开始被拖动时候
    optional func cycleScrollViewWillBeginDragging(_ cycleScrollView: CycleScrollView)
    
    @objc(cycleScrollViewWillEndDragging:targetIndex:)
    /// when the user finishes scrolling the content.
    ///
    /// - Parameters:
    ///   - cycleScrollView: cycleScrollView description
    ///   - targetIndex: targetIndex description
    /// 当结束被拖动时候
    optional func cycleScrollViewWillEndDragging(_ cycleScrollView: CycleScrollView, targetIndex: Int)
    
    @objc(cycleScrollViewDidScroll:)
    /// when the user scrolls the content view within the receiver.
    ///
    /// - Parameter cycleScrollView: cycleScrollView description
    /// 当滚动的时候
    optional func cycleScrollViewDidScroll(_ cycleScrollView: CycleScrollView)
    
    @objc(cycleScrollViewDidEndScrollAnimation:)
    /// when a scrolling animation in the pager view concludes.
    ///
    /// - Parameter cycleScrollView: cycleScrollView description
    /// 当结束滚动动画时候
    optional func cycleScrollViewDidEndScrollAnimation(_ cycleScrollView: CycleScrollView)
    
    
    @objc(cycleScrollViewDidEndDecelerating:)
    /// the pager view has ended decelerating the scrolling movement.
    ///
    /// - Parameter cycleScrollView: cycleScrollView description
    /// 当结束减速时候
    optional func cycleScrollViewDidEndDecelerating(_ cycleScrollView: CycleScrollView)
}
