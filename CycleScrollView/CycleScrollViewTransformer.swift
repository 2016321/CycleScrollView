//
//  CycleScrollViewTransformer.swift
//  BingoCycleScrollViewDemo
//
//  Created by 王昱斌 on 17/4/17.
//  Copyright © 2017年 Qtin. All rights reserved.
//

import UIKit

open class CycleScrollViewTransformer: NSObject {
    open internal(set) weak var cycleScrollView: CycleScrollView?
    open internal(set) var type: CycleScrollViewTransformerType
    
    open var minimumScale: CGFloat = 0.8
    open var minimumAlpha: CGFloat = 0.8
    
    public init(type: CycleScrollViewTransformerType) {
        self.type = type
    }
    
    // Apply transform to attributes - zIndex: Int, frame: CGRect, alpha: CGFloat, transform: CGAffineTransform or transform3D: CATransform3D.
    open func applyTransform(to attributes: CycleScrollViewLayoutAttributes) {
        guard let cycleScrollView = self.cycleScrollView else {
            return
        }
        let position = attributes.position
        let scrollDirection = cycleScrollView.scrollDirection
        switch self.type {
        case .linear:
            guard scrollDirection == .horizontal else {
                return
            }
            let scale = max(1 - (1-self.minimumScale) * abs(position), self.minimumScale)
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            attributes.transform = transform
            let alpha = (self.minimumAlpha + (1-abs(position))*(1-self.minimumAlpha))
            attributes.alpha = alpha
            let zIndex = (1-abs(position)) * 10
            attributes.zIndex = Int(zIndex)
            
        }
    }
    
    // An interitem spacing proposed by transformer class. This will override the default interitemSpacing provided by the pager view.
    open func proposedInteritemSpacing() -> CGFloat {
        guard let cycleScrollView = self.cycleScrollView else {
            return 0
        }
        let scrollDirection = cycleScrollView.scrollDirection
        guard scrollDirection == .horizontal else {
            return 0
        }
        return cycleScrollView.itemSize.width * -self.minimumScale * 0.1
    }
}
