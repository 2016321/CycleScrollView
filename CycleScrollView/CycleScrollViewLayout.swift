//
//  CycleScrollViewLayout.swift
//  BingoCycleScrollViewDemo
//
//  Created by 王昱斌 on 17/4/17.
//  Copyright © 2017年 Qtin. All rights reserved.
//

import UIKit

class CycleScrollViewLayout: UICollectionViewLayout {
    
    /// 滚动区间
    internal var contentSize : CGSize = .zero
    /// item露出的区间
    internal var leadingSpacing : CGFloat = 0
    /// item间距
    internal var itemSpacing : CGFloat = 0
    /// 是否需要重新布局
    internal var needsReprepare = true
    
    internal var scrollDirection : CycleScrollViewDirection = .horizontal
    
    /// 是否无线循环
    fileprivate var isInfinite: Bool = true
    /// 视图的大小
    fileprivate var collectionViewSize: CGSize = .zero
    /// 视图的组数
    fileprivate var numberOfSections = 1
    /// 视图的item的数量
    fileprivate var numberOfItems = 0
    /// 实际的item间距
    fileprivate var actualInteritemSpacing: CGFloat = 0
    /// 实际的item大小
    fileprivate var actualItemSize: CGSize = .zero
    fileprivate var cycleScrollView: CycleScrollView? {
        return self.collectionView?.superview?.superview as? CycleScrollView
    }
    
    
    /// 重载子类方法，继承自UICollectionViewLayout的子类都要返回重载这个方法
    open override class var layoutAttributesClass: AnyClass {
        get {
            return CycleScrollViewLayoutAttributes.self
        }
    }
    
    override open func prepare() {
        guard let collectionView = self.collectionView, let cycleScrollView = self.cycleScrollView else {
            return
        }
        guard self.needsReprepare || self.collectionViewSize != collectionView.frame.size else {
            return
        }
        self.needsReprepare = false
        
        self.collectionViewSize = collectionView.frame.size
        
        // Calculate basic parameters/variables
        self.numberOfSections = cycleScrollView.numberOfSections(in: collectionView)
        self.numberOfItems = cycleScrollView.collectionView(collectionView, numberOfItemsInSection: 0)
        self.actualItemSize = {
            var size = cycleScrollView.itemSize
            if size == .zero {
                size = collectionView.frame.size
            }
            return size
        }()
        
        self.actualInteritemSpacing = {
            if let transformer = cycleScrollView.transformer {
                return transformer.proposedInteritemSpacing()
            }
            return cycleScrollView.interitemSpacing
        }()
        self.scrollDirection = cycleScrollView.scrollDirection
        self.leadingSpacing = self.scrollDirection == .horizontal ? (collectionView.frame.width-self.actualItemSize.width)*0.5 : (collectionView.frame.height-self.actualItemSize.height)*0.5
        self.itemSpacing = (self.scrollDirection == .horizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing
        
        // Calculate and cache contentSize, rather than calculating each time
        self.contentSize = {
            let numberOfItems = self.numberOfItems*self.numberOfSections
            switch self.scrollDirection {
            case .horizontal:
                var contentSizeWidth: CGFloat = self.leadingSpacing*2 // Leading & trailing spacing
                contentSizeWidth += CGFloat(numberOfItems-1)*self.actualInteritemSpacing // Interitem spacing
                contentSizeWidth += CGFloat(numberOfItems)*self.actualItemSize.width // Item sizes
                let contentSize = CGSize(width: contentSizeWidth, height: collectionView.frame.height)
                return contentSize
            case .vertical:
                var contentSizeHeight: CGFloat = self.leadingSpacing*2 // Leading & trailing spacing
                contentSizeHeight += CGFloat(numberOfItems-1)*self.actualInteritemSpacing // Interitem spacing
                contentSizeHeight += CGFloat(numberOfItems)*self.actualItemSize.height // Item sizes
                let contentSize = CGSize(width: collectionView.frame.width, height: contentSizeHeight)
                return contentSize
            }
        }()
        self.adjustCollectionViewBounds()
    }
    
    override open var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        guard self.itemSpacing > 0, !rect.isEmpty else {
            return layoutAttributes
        }
        let rect = rect.intersection(CGRect(origin: .zero, size: self.contentSize))
        guard !rect.isEmpty else {
            return layoutAttributes
        }
        // Calculate start position and index of certain rects
        let numberOfItemsBefore = self.scrollDirection == .horizontal ? max(Int((rect.minX-self.leadingSpacing)/self.itemSpacing),0) : max(Int((rect.minY-self.leadingSpacing)/self.itemSpacing),0)
        let startPosition = self.leadingSpacing + CGFloat(numberOfItemsBefore)*self.itemSpacing
        let startIndex = numberOfItemsBefore
        // Create layout attributes
        var itemIndex = startIndex
        
        var origin = startPosition
        let maxPosition = self.scrollDirection == .horizontal ? min(rect.maxX,self.contentSize.width-self.actualItemSize.width-self.leadingSpacing) : min(rect.maxY,self.contentSize.height-self.actualItemSize.height-self.leadingSpacing)
        while origin <= maxPosition {
            let indexPath = IndexPath(item: itemIndex%self.numberOfItems, section: itemIndex/self.numberOfItems)
            let attributes = self.layoutAttributesForItem(at: indexPath) as! CycleScrollViewLayoutAttributes
            self.applyTransform(to: attributes, with: self.cycleScrollView?.transformer)
            layoutAttributes.append(attributes)
            itemIndex += 1
            origin += self.itemSpacing
        }
        return layoutAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = CycleScrollViewLayoutAttributes(forCellWith: indexPath)
        let frame = self.frame(for: indexPath)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.center = center
        attributes.size = self.actualItemSize
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return proposedContentOffset
        }
        var proposedContentOffset = proposedContentOffset
        let proposedContentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return proposedContentOffset.x
            }
            let translation = -collectionView.panGestureRecognizer.translation(in: collectionView).x
            var offset: CGFloat = round(proposedContentOffset.x/self.itemSpacing)*self.itemSpacing
            let minFlippingDistance = min(0.5 * self.itemSpacing,150)
            let originalContentOffsetX = collectionView.contentOffset.x - translation
            if abs(translation) <= minFlippingDistance {
                if abs(velocity.x) >= 0.3 && abs(proposedContentOffset.x-originalContentOffsetX) <= self.itemSpacing*0.5 {
                    offset += self.itemSpacing * (velocity.x)/abs(velocity.x)
                }
            }
            return offset
        }()
        let proposedContentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return proposedContentOffset.y
            }
            let translation = -collectionView.panGestureRecognizer.translation(in: collectionView).y
            var offset: CGFloat = round(proposedContentOffset.y/self.itemSpacing)*self.itemSpacing
            let minFlippingDistance = min(0.5 * self.itemSpacing,150)
            let originalContentOffsetY = collectionView.contentOffset.y - translation
            if abs(translation) <= minFlippingDistance {
                if abs(velocity.y) >= 0.3 && abs(proposedContentOffset.y-originalContentOffsetY) <= self.itemSpacing*0.5 {
                    offset += self.itemSpacing * (velocity.y)/abs(velocity.y)
                }
            }
            return offset
        }()
        proposedContentOffset = CGPoint(x: proposedContentOffsetX, y: proposedContentOffsetY)
        return proposedContentOffset
    }
    
}

// MARK:- Internal functions
extension CycleScrollViewLayout{
    
    internal func forceInvalidate() {
        self.needsReprepare = true
        self.invalidateLayout()
    }
    
    internal func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        guard let collectionView = self.collectionView else {
            return origin
        }
        let contentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return 0
            }
            let contentOffsetX = origin.x - (collectionView.frame.width*0.5-self.actualItemSize.width*0.5)
            return contentOffsetX
        }()
        let contentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return 0
            }
            let contentOffsetY = origin.y - (collectionView.frame.height*0.5-self.actualItemSize.height*0.5)
            return contentOffsetY
        }()
        let contentOffset = CGPoint(x: contentOffsetX, y: contentOffsetY)
        return contentOffset
    }
    
    internal func frame(for indexPath: IndexPath) -> CGRect {
        let numberOfItems = self.numberOfItems*indexPath.section + indexPath.item
        let originX: CGFloat = {
            if self.scrollDirection == .vertical {
                return (self.collectionView!.frame.width-self.actualItemSize.width)*0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems)*self.itemSpacing
        }()
        let originY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return (self.collectionView!.frame.height-self.actualItemSize.height)*0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems)*self.itemSpacing
        }()
        let origin = CGPoint(x: originX, y: originY)
        let frame = CGRect(origin: origin, size: self.actualItemSize)
        return frame
    }
    
    // MARK:- Notification
    @objc
    fileprivate func didReceiveNotification(notification: Notification) {
        if self.cycleScrollView?.itemSize == .zero {
            self.adjustCollectionViewBounds()
        }
    }
}

extension CycleScrollViewLayout{
    // MARK:- Private functions
    
    fileprivate func adjustCollectionViewBounds() {
        guard let collectionView = self.collectionView, let cycleScrollView = self.cycleScrollView else {
            return
        }
        let currentIndex = cycleScrollView.currentIndex
        let newIndexPath = IndexPath(item: currentIndex, section: self.isInfinite ? self.numberOfSections/2 : 0)
        let contentOffset = self.contentOffset(for: newIndexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds
    }
    
    fileprivate func applyTransform(to attributes: CycleScrollViewLayoutAttributes, with transformer: CycleScrollViewTransformer?) {
        guard let collectionView = self.collectionView else {
            return
        }
        guard let transformer = transformer else {
            return
        }
        switch self.scrollDirection {
        case .horizontal:
            let ruler = collectionView.bounds.midX
            attributes.position = (attributes.center.x-ruler)/self.itemSpacing
        case .vertical:
            let ruler = collectionView.bounds.midY
            attributes.position = (attributes.center.y-ruler)/self.itemSpacing
        }
        attributes.zIndex = Int(self.numberOfItems)-Int(attributes.position)
        transformer.applyTransform(to: attributes)
    }

}