//
//  CycleScrollView.swift
//  BingoCycleScrollViewDemo
//
//  Created by 王昱斌 on 17/4/17.
//  Copyright © 2017年 Qtin. All rights reserved.
//

import UIKit

let CycleScrollViewWidth : CGFloat = UIScreen.main.bounds.width
let CycleScrollViewHeight : CGFloat = CycleScrollViewWidth * 44 / 75
let TopSpace : CGFloat = CycleScrollViewWidth / 25
let MaxSizeWidth : CGFloat = CycleScrollViewWidth * 22 / 25
let MaxSizeHeight : CGFloat = MaxSizeWidth * 5 / 11
let MinSizeHeight : CGFloat = MaxSizeHeight * 4 / 5
let BottomLabelHeight : CGFloat = CycleScrollViewWidth * 11 / 75

open class CycleScrollView: UIView {

    open weak var dataSource: CycleScrollViewDataSource?
    open weak var delegate: CycleScrollViewDelegate?
    
    
    /// The scroll direction of the CycleScrollView. Default is horizontal.
    /// 滚动的方向，默认水平
    open var scrollDirection: CycleScrollViewDirection = .horizontal {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// The time interval of automatic sliding. 0 means disabling automatic sliding. Default is 0.
    /// 自动滚动的时间，0为不设置自动滚动
    open var automaticSlidingInterval: CGFloat = 0.0 {
        didSet {
            self.cancelTimer()
            if self.automaticSlidingInterval > 0 {
                self.startTimer()
            }
        }
    }
    
    /// The spacing to use between items in the CycleScrollView. Default is 0.
    /// item的间距
    open var interitemSpacing: CGFloat = 0 {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// The item size of the CycleScrollView. .zero means always fill the bounds of the CycleScrollView. Default is .zero.
    /// item的大小
    open var itemSize: CGSize = .zero {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// A Boolean value indicates that whether the CycleScrollView has infinite items. Default is false.
    /// 是否是无线循环
    open var isInfinite: Bool = false {
        didSet {
            self.collectionViewLayout.needsReprepare = true
            self.collectionView.reloadData()
        }
    }
    
    
    /// The background view of the CycleScrollView.
    /// 背景视图
    open var backgroundView: UIView? {
        didSet {
            if let backgroundView = self.backgroundView {
                if backgroundView.superview != nil {
                    backgroundView.removeFromSuperview()
                }
                self.insertSubview(backgroundView, at: 0)
                self.setNeedsLayout()
            }
        }
    }
    
    /// The transformer of the CycleScrollView.
    /// 动画变化模型
    open var transformer: CycleScrollViewTransformer? {
        didSet {
            self.transformer?.cycleScrollView = self
            self.collectionViewLayout.forceInvalidate()
        }
    }

    
    // MARK: - readonly-properties
    
    /// Returns whether the user has touched the content to initiate scrolling.
    /// 当用户触摸时候返回，还没开始拖拽
    open var isTracking: Bool {
        return self.collectionView.isTracking
    }
    
    /// The percentage of x position at which the origin of the content view is offset from the origin of the cycleScrollView view.
    open var scrollOffset: CGFloat {
        let contentOffset = max(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y)
        let scrollOffset = Double(contentOffset.divided(by: self.collectionViewLayout.itemSpacing))
        return fmod(CGFloat(scrollOffset), CGFloat(Double(self.numberOfItems)))
    }
    
    /// The underlying gesture recognizer for pan gestures.
    open var panGestureRecognizer: UIPanGestureRecognizer {
        return self.collectionView.panGestureRecognizer
    }
    
    open fileprivate(set) dynamic var currentIndex: Int = 0
    

    // MARK: - Private properties
    
    internal weak var collectionViewLayout: CycleScrollViewLayout!
    internal weak var collectionView: CycleScrollViewCollectionView!
    internal weak var contentView: UIView!
    
    internal var timer: Timer?
    internal var numberOfItems: Int = 0
    internal var numberOfSections: Int = 0
    
    fileprivate var dequeingSection = 0
    fileprivate var centermostIndexPath: IndexPath {
        guard self.numberOfItems > 0, self.collectionView.contentSize != .zero else {
            return IndexPath(item: 0, section: 0)
        }
        let sortedIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted { (l, r) -> Bool in
            let leftFrame = self.collectionViewLayout.frame(for: l)
            let rightFrame = self.collectionViewLayout.frame(for: r)
            var leftCenter: CGFloat,rightCenter: CGFloat,ruler: CGFloat
            switch self.scrollDirection {
            case .horizontal:
                leftCenter = leftFrame.midX
                rightCenter = rightFrame.midX
                ruler = self.collectionView.bounds.midX
            case .vertical:
                leftCenter = leftFrame.midY
                rightCenter = rightFrame.midY
                ruler = self.collectionView.bounds.midY
            }
            return abs(ruler-leftCenter) < abs(ruler-rightCenter)
        }
        let indexPath = sortedIndexPaths.first
        if let indexPath = indexPath {
            return indexPath
        }
        return IndexPath(item: 0, section: 0)
    }
    
    fileprivate var possibleTargetingIndexPath: IndexPath?
    
    
    // MARK: - Overriden functions
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView?.frame = self.bounds
        self.contentView.frame = self.bounds
        self.collectionView.frame = self.contentView.bounds
        //        self.collectionView.isPagingEnabled = true
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            self.startTimer()
        } else {
            self.cancelTimer()
        }
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.masksToBounds = true
        let label = UILabel(frame: self.contentView.bounds)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = "FScycleScrollView"
        self.contentView.addSubview(label)
    }
    
    deinit {
        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil
    }
    
}

// MARK: - Public functions
extension CycleScrollView{
    
    @objc(registerClass:forCellWithReuseIdentifier:)
    /// Register a class for use in creating new  CycleScrollViewcells.
    ///
    /// - Parameters:
    ///   - cellClass: The class of a cell that you want to use in the CycleScrollView.
    ///   - identifier: The reuse identifier to associate with the specified class. This parameter must not be nil and must not be an empty string.
    /// 注册cell
    open func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    @objc(registerNib:forCellWithReuseIdentifier:)
    /// Register a nib file for use in creating new CycleScrollView cells.
    ///
    /// - Parameters:
    ///   - nib: The nib object containing the cell object. The nib file must contain only one top-level object and that object must be of the type CycleScrollViewCell.
    ///   - identifier: The reuse identifier to associate with the specified nib file. This parameter must not be nil and must not be an empty string.
    /// 注册xib
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    @objc(dequeueReusableCellWithReuseIdentifier:atIndex:)
    /// Returns a reusable cell object located by its identifier
    ///
    /// - Parameters:
    ///   - identifier: The reuse identifier for the specified cell. This parameter must not be nil.
    ///   - index: The index specifying the location of the cell.
    /// - Returns: A valid CycleScrollViewCell object.
    /// 注册cell
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> CycleScrollViewCell {
        let indexPath = IndexPath(item: index, section: self.dequeingSection)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard cell.isKind(of: CycleScrollViewCell.self) else {
            fatalError("Cell class must be subclass of CycleScrollViewCell")
        }
        return cell as! CycleScrollViewCell
    }
    
    @objc(reloadData)
    /// Reloads all of the data for the collection view.
    ///刷新数据
    open func reloadData() {
        self.collectionViewLayout.needsReprepare = true;
        self.collectionView.reloadData()
    }
    
    @objc(selectItemAtIndex:animated:)
    /// Selects the item at the specified index and optionally scrolls it into view.
    ///
    /// - Parameters:
    ///   - index: The index path of the item to select.
    ///   - animated: Specify true to animate the change in the selection or false to make the change without animating it.
    /// 当选择某个item
    open func selectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        let scrollPosition: UICollectionViewScrollPosition = self.scrollDirection == .horizontal ? .centeredVertically : .centeredVertically
        self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    @objc(deselectItemAtIndex:animated:)
    /// Deselects the item at the specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the item to deselect.
    ///   - animated: Specify true to animate the change in the selection or false to make the change without animating it.
    /// 当取消选择某个item
    open func deselectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        self.collectionView.deselectItem(at: indexPath, animated: animated)
    }
    
    @objc(scrollToItemAtIndex:animated:)
    /// Scrolls the CycleScrollView contents until the specified item is visible.
    ///
    /// - Parameters:
    ///   - index: The index of the item to scroll into view.
    ///   - animated: Specify true to animate the scrolling behavior or false to adjust the CycleScrollView’s visible content immediately.
    /// 滚动到固定的cell
    open func scrollToItem(at index: Int, animated: Bool) {
        guard index < self.numberOfItems else {
            fatalError("index \(index) is out of range [0...\(self.numberOfItems-1)]")
        }
        let indexPath = { () -> IndexPath in
            if let indexPath = self.possibleTargetingIndexPath, indexPath.item == index {
                defer {
                    self.possibleTargetingIndexPath = nil
                }
                return indexPath
            }
            return self.isInfinite ? self.nearbyIndexPath(for: index) : IndexPath(item: index, section: 0)
        }()
        let contentOffset = self.collectionViewLayout.contentOffset(for: indexPath)
        self.collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    @objc(indexForCell:)
    /// Returns the index of the specified cell.
    ///
    /// - Parameter cell: The cell object whose index you want.
    /// - Returns: The index of the cell or NSNotFound if the specified cell is not in the CycleScrollView.
    open func index(for cell: CycleScrollViewCell) -> Int {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return NSNotFound
        }
        return indexPath.item
    }

}

// MARK: - Private functions
extension CycleScrollView{
    
    fileprivate func commonInit() {
        
        // Content View
        let contentView = UIView(frame:CGRect.zero)
        contentView.backgroundColor = UIColor.clear
        self.addSubview(contentView)
        self.contentView = contentView
        
        // UICollectionView
        let collectionViewLayout = CycleScrollViewLayout()
        let collectionView = CycleScrollViewCollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        self.contentView.addSubview(collectionView)
        self.collectionView = collectionView
        self.collectionViewLayout = collectionViewLayout
        
    }
    
    fileprivate func startTimer() {
        guard self.automaticSlidingInterval > 0 && self.timer == nil else {
            return
        }
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.automaticSlidingInterval), target: self, selector: #selector(self.flipNext(sender:)), userInfo: nil, repeats: true)
    }
    
    @objc
    fileprivate func flipNext(sender: Timer?) {
        guard let _ = self.superview, let _ = self.window, self.numberOfItems > 0, !self.isTracking else {
            return
        }
        self.scrollToItem(at: (self.currentIndex+1)%self.numberOfItems, animated: true)
    }
    
    fileprivate func cancelTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer!.invalidate()
        self.timer = nil
    }
    
    fileprivate func nearbyIndexPath(for index: Int) -> IndexPath {
        // Is there a better algorithm?
        let currentIndex = self.currentIndex
        let currentSection = self.centermostIndexPath.section
        if abs(currentIndex-index) <= self.numberOfItems/2 {
            return IndexPath(item: index, section: currentSection)
        } else if (index-currentIndex >= 0) {
            return IndexPath(item: index, section: currentSection-1)
        } else {
            return IndexPath(item: index, section: currentSection+1)
        }
    }
    
}

// MARK: - UICollectionViewDelegate
extension CycleScrollView : UICollectionViewDelegate{
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let function = self.delegate?.cycleScrollView(_:shouldHighlightItemAt:) else {
            return true
        }
        let index = indexPath.item % self.numberOfItems
        return function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.cycleScrollView(_:didHighlightItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let function = self.delegate?.cycleScrollView(_:shouldSelectItemAt:) else {
            return true
        }
        let index = indexPath.item % self.numberOfItems
        return function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.cycleScrollView(_:didSelectItemAt:) else {
            return
        }
        self.possibleTargetingIndexPath = indexPath
        defer {
            self.possibleTargetingIndexPath = nil
        }
        let index = indexPath.item % self.numberOfItems
        function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("\(indexPath.section)--------")
        guard let function = self.delegate?.cycleScrollView(_:willDisplay:forItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self,cell as! CycleScrollViewCell,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.cycleScrollView(_:didEndDisplaying:forItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self,cell as! CycleScrollViewCell,index)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.numberOfItems > 0 {
            // In case someone is using KVO
            print(Double(self.scrollOffset))
            
            let currentIndex = lround(Double(self.scrollOffset)) % self.numberOfItems
            if (currentIndex != self.currentIndex) {
                self.currentIndex = currentIndex
            }
        }
        guard let function = self.delegate?.cycleScrollViewDidScroll else {
            return
        }
        function(self)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let function = self.delegate?.cycleScrollViewWillBeginDragging(_:) {
            function(self)
        }
        if self.automaticSlidingInterval > 0 {
            self.cancelTimer()
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let function = self.delegate?.cycleScrollViewWillEndDragging(_:targetIndex:) {
            let contentOffset = self.scrollDirection == .horizontal ? targetContentOffset.pointee.x : targetContentOffset.pointee.y
            let targetItem = lround(Double(contentOffset/self.collectionViewLayout.itemSpacing))
            function(self, targetItem % self.numberOfItems)
        }
        if self.automaticSlidingInterval > 0 {
            self.startTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let function = self.delegate?.cycleScrollViewDidEndDecelerating {
            function(self)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let function = self.delegate?.cycleScrollViewDidEndScrollAnimation {
            function(self)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CycleScrollView : UICollectionViewDataSource{
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else {
            return 1
        }
        self.numberOfItems = dataSource.numberOfItems(in: self)
        guard self.numberOfItems > 0 else {
            return 0;
        }
        self.numberOfSections = self.isInfinite ? Int(Int16.max)/self.numberOfItems : 1
        print("\(self.numberOfSections)--------------")
        return self.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        self.dequeingSection = indexPath.section
        let cell = self.dataSource!.cycleScrollView(self, cellForItemAt: index)
        return cell
    }
}
