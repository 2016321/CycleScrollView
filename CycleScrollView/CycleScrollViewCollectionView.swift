
//
//  CycleScrollViewCollectionView.swift
//  BingoCycleScrollViewDemo
//
//  Created by 王昱斌 on 17/4/17.
//  Copyright © 2017年 Qtin. All rights reserved.
//

import UIKit

class CycleScrollViewCollectionView: UICollectionView {
    
    fileprivate var cycleScrollView: CycleScrollView? {
        return self.superview?.superview as? CycleScrollView
    }
    
    override var contentInset: UIEdgeInsets {
        set {
            super.contentInset = .zero
            if (newValue.top > 0) {
                let contentOffset = CGPoint(x:self.contentOffset.x, y:self.contentOffset.y+newValue.top);
                self.contentOffset = contentOffset
            }
        }
        get {
            return super.contentInset
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
}

extension CycleScrollViewCollectionView{
    
    fileprivate func commonInit() {
        self.contentInset = .zero
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.isPagingEnabled = true
        //MARK: - iOS10中关闭预加载，因为是动态改变cell大小，一定要关闭，一定要关闭，一定要关闭！
        if #available(iOS 10.0, *) {
            self.isPrefetchingEnabled = false
        }
        #if !os(tvOS)
            self.scrollsToTop = false
            self.isPagingEnabled = false
        #endif
    }
    
}
