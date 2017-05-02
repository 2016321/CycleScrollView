//
//  KingfisherManger.swift
//  SexyVC
//
//  Created by 王昱斌 on 17/5/2.
//  Copyright © 2017年 Qtin. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImageView{
    func setImage(with resource: Resource?,
                  placeholder: Image? = nil,
                  options: KingfisherOptionsInfo? = nil,
                  progressBlock: DownloadProgressBlock? = nil,
                  completionHandler: CompletionHandler? = nil){
        kf.setImage(with: resource, placeholder: placeholder, options: options, progressBlock: progressBlock, completionHandler: completionHandler)
    }
}

extension UIButton{
    func setImage(with resource: Resource?,
                  state: UIControlState,
                  placeholder: Image? = nil,
                  options: KingfisherOptionsInfo? = nil,
                  progressBlock: DownloadProgressBlock? = nil,
                  completionHandler: CompletionHandler? = nil){
        kf.setImage(with: resource, for: state, placeholder: placeholder, options: options, progressBlock: progressBlock, completionHandler: completionHandler)
    }
}



