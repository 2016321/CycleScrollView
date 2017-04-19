//
//  YYKitManager.swift
//  YYKitDemo
//
//  Created by 王昱斌 on 17/4/6.
//  Copyright © 2017年 ibireme. All rights reserved.
//

import Foundation
import YYKit

private let inlineThreshold  = 20480
private let Memory = YYKitManager.shareManager.memoryCache
private let Disk = YYKitManager.shareManager.diskCache

enum CacheType {
    case memory
    case disk
}

extension UILabel {
    
    /// 设置行间距
    ///
    /// - Parameter space: space description
    func changeLineSpace(space : CGFloat) -> Void {
        guard let text = self.text else {
            return
        }
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = space
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: NSRange(location: 0, length: text.characters.count))
        self.attributedText = attributedString
        self.sizeToFit()
        
    }
    
    /// 设置字间距
    ///
    /// - Parameter space: space description
    func changeWordSpace(space : CGFloat) -> Void {
        guard let text = self.text else {
            return
        }
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSKernAttributeName : NSNumber.init(value: Float(space))])
        let paragraphStyle = NSMutableParagraphStyle()
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: NSRange(location: 0, length: text.characters.count))
        self.attributedText = attributedString
        self.sizeToFit()
    }
    
    /// 设置行间距字间距
    ///
    /// - Parameters:
    ///   - lineSpace: lineSpace description
    ///   - wordSpace: wordSpace description
    func changeSpace(lineSpace : CGFloat , wordSpace : CGFloat) -> Void {
        guard let text = self.text else {
            return
        }
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSKernAttributeName : NSNumber.init(value: Float(wordSpace))])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: NSRange(location: 0, length: text.characters.count))
        self.attributedText = attributedString
        self.sizeToFit()
    }
}

class YYKitManager {
    
    /// 创建YYKit管理单例
    static let shareManager = YYKitManager()
    
    var memoryCache = YYMemoryCache()
    var diskCache = YYDiskCache(path: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0], inlineThreshold: UInt(inlineThreshold))
}

//MARK: - YYDiskCache
extension YYKitManager{
    
    func contains(key : String , completion :((_ key : String , _ contains : Bool) -> ())?) -> Bool {
        guard let disk = Disk else {
            return false
        }
        guard let completion = completion else {
            return disk.containsObject(forKey: key)
        }
        disk.containsObject(forKey: key, with: completion)
        return false
    }
    func object(key : String , completion :((_ key : String , _ obj : NSCoding?) -> ())?) -> NSCoding? {
        guard let disk = Disk else {
            return nil
        }
        guard let completion = completion else {
            return disk.object(forKey: key)
        }
        disk.object(forKey: key, with: completion)
        return nil
    }
    func aremove(key : String) -> Void {
        guard let disk = Disk else {
            return
        }
        disk.removeObject(forKey: key)
        
    }
}

//MARK: - memoryCache
extension YYKitManager{
    
    //MARK: - 设置内存缓存对象
    func setMemoryCache(obj : Any , key : String , cost : UInt?) -> Void {
        guard let cost = cost else {
            Memory.setObject(obj, forKey: key)
            return
        }
        Memory.setObject(obj, forKey: key, withCost: cost)
    }
    //MARK: - 设置磁盘缓存
    func setDiskCache(obj : NSCoding? , key : String ,  completion :(() -> ())?) -> Void {
        guard let disk = Disk else {
            return
        }
        guard let completion = completion else {
            disk.setObject(obj, forKey: key)
            return
        }
        disk.setObject(obj, forKey: key, with: completion)
    }
    //MARK: - 根据值判断缓存中是否有缓存的对象
    func contains(objFor key : String , type : CacheType = .memory , completion :((_ key : String , _ contains : Bool) -> ())?) -> Bool {
        //磁盘缓存
        if type == .disk {
            guard let disk = Disk else {
                return false
            }
            guard let completion = completion else {
                return disk.containsObject(forKey: key)
            }
            disk.containsObject(forKey: key, with: completion)
            return false
        }
        //内存缓存
        return Memory.containsObject(forKey: key)
    }
    //MARK: - 查询
    func object(key : String , type : CacheType = .memory , completion :((_ key : String , _ obj : NSCoding?) -> ())?) -> Any? {
        //result for Disk
        if type == .disk {
            guard let disk = Disk else {
                return nil
            }
            guard let completion = completion else {
                return disk.object(forKey: key)
            }
            disk.object(forKey: key, with: completion)
            return false
        }
        //result for Memory
        return Memory.object(forKey: key)
    }
    //MARK: - 删除
    func remove(key : String , type : CacheType = .memory , completion :((_ key : String) -> ())?) -> Void {
        if type == .disk {
            guard let disk = Disk else {
                return
            }
            guard let completion = completion else {
                disk.removeObject(forKey: key)
                return
            }
            disk.removeObject(forKey: key, with: completion)
            return
        }
        Memory.removeObject(forKey: key)
    }
    //MARK: - 全部清除
    func removeAll(type : CacheType = .memory , completion :(() -> ())?) -> Void {
        if type == .disk {
            guard let disk = Disk else {
                return
            }
            guard let completion = completion else {
                disk.removeAllObjects()
                return
            }
            disk.removeAllObjects(completion)
            return
        }
        Memory.removeAllObjects()
    }
    //MARK: - 清除全部缓存，并返回进度
    func removeAll(progressBlock : ((_ removedCount : Int32, _ totalCount : Int32) -> ())? , end : ((_ error : Bool) -> ())?) -> Void {
        guard let disk = Disk else {
            return
        }
        disk.removeAllObjects(progressBlock: progressBlock, end: end)
    }
}

extension YYKitManager{
    
    func totalCount(type : CacheType = .memory , completion :(( _ totalCount : NSInteger) -> ())?) -> NSInteger? {
        //磁盘count
        if type == .disk {
            guard let disk = Disk else {
                return nil
            }
            guard let completion = completion else {
                return disk.totalCount()
            }
            disk.totalCount(completion)
            return nil
        }
        return NSInteger(Memory.totalCount)
    }
    
    func totalCost(type : CacheType = .memory , completion :(( _ totalCount : NSInteger) -> ())?) -> NSInteger? {
        //磁盘cost
        if type == .disk {
            guard let disk = Disk else {
                return nil
            }
            guard let completion = completion else {
                return disk.totalCost()
            }
            disk.totalCost(completion)
            return nil
        }
        return NSInteger(Memory.totalCost)
    }
    
    func trim(count : UInt , type : CacheType = .memory , completion :(() -> ())?) -> Void {
        if type == .disk {
            guard let disk = Disk else {
                return
            }
            guard let completion = completion else {
                disk.trim(toCount: count)
                return
            }
            disk.trim(toCount: count, with: completion)
        }
        Memory.trim(toCount: count)
    }
    
    func trim(cost : UInt , type : CacheType = .memory , completion :(() -> ())?) -> Void {
        if type == .disk {
            guard let disk = Disk else {
                return
            }
            guard let completion = completion else {
                disk.trim(toCost: cost)
                return
            }
            disk.trim(toCost: cost, with: completion)
        }
        Memory.trim(toCost: cost)
    }
    func trim(age : TimeInterval , type : CacheType = .memory , completion :(() -> ())?) -> Void {
        if type == .disk {
            guard let disk = Disk else {
                return
            }
            guard let completion = completion else {
                disk.trim(toAge: age)
                return
            }
            disk.trim(toAge: age, with: completion)
        }
        Memory.trim(toAge: age)
    }
}


//YYWebImage
extension YYAnimatedImageView{
    func bingo_setImage(
        url : String! ,
        placeholder : UIImage? ,
        options : YYWebImageOptions! ,
        progress : YYWebImageProgressBlock? ,
        transform: YYWebImageTransformBlock? ,
        completion : YYWebImageCompletionBlock?) -> Void {
        self.setImageWith(URL(string : url), placeholder: placeholder, options: options, progress: progress , transform: transform, completion: completion)
    }
    
    /// 添加gif点击手势
    func bingo_addTap() -> Void {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer {
            [unowned self]
            (sender) in
            if self.isAnimating{
                self.stopAnimating()
            }else{
                self.startAnimating()
            }
            let op : UIViewAnimationOptions = [.curveEaseInOut,.allowAnimatedContent,.beginFromCurrentState]
            UIView.animate(withDuration: 0.1, delay: 0, options: op, animations: {
                self.layer.transformScale = 0.97
            }, completion: { (finish) in
                UIView.animate(withDuration: 0.1, delay: 0, options: op, animations: {
                    self.layer.transformScale = 1.008
                }, completion: { (finish) in
                    UIView.animate(withDuration: 0.1, delay: 0, options: op, animations: {
                        self.layer.transformScale = 1
                    }, completion: nil)
                })
            })
            
        }
        addGestureRecognizer(tap)
    }
    
    /// 添加gif快进手势
    func bingo_addPan() -> Void {
        self.isUserInteractionEnabled = true
        var previousIsPlaying : Bool = false
        
        let pan : UIPanGestureRecognizer = UIPanGestureRecognizer {
            [unowned self]
            (sender) in
            let image : YYAnimatedImage = self.image as! YYAnimatedImage
            if !image.conforms(to: YYAnimatedImage.self){
                return
            }
            let gestrue = sender as! UIPanGestureRecognizer
            let p = gestrue.location(in: gestrue.view)
            let progress = p.x / (gestrue.view?.width)!
            
            if gestrue.state == .began{
                previousIsPlaying = self.isAnimating
                self.stopAnimating()
                self.currentAnimatedImageIndex = image.animatedImageFrameCount() * UInt(progress)
            }else if gestrue.state == .ended || gestrue.state == .cancelled{
                if previousIsPlaying{
                    self.startAnimating()
                }
            }else{
                self.currentAnimatedImageIndex = image.animatedImageFrameCount() * UInt(progress)
            }
        }
        addGestureRecognizer(pan)
    }
}
