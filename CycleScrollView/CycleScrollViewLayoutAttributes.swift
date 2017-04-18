//
//  CycleScrollViewLayoutAttributes.swift
//  BingoCycleScrollViewDemo
//
//  Created by 王昱斌 on 17/4/17.
//  Copyright © 2017年 Qtin. All rights reserved.
//

import UIKit

open class CycleScrollViewLayoutAttributes: UICollectionViewLayoutAttributes {
    open var position: CGFloat = 0
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? CycleScrollViewLayoutAttributes else {
            return false
        }
        var isEqual = super.isEqual(object)
        isEqual = isEqual && (self.position == object.position)
        return isEqual
    }
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! CycleScrollViewLayoutAttributes
        copy.position = self.position
        return copy
    }

}
