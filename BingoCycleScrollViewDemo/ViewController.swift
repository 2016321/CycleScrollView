//
//  ViewController.swift
//  BingoCycleScrollViewDemo
//
//  Created by 王昱斌 on 17/4/14.
//  Copyright © 2017年 Qtin. All rights reserved.
//

import UIKit

class ViewController: UIViewController,CycleScrollViewDataSource,CycleScrollViewDelegate{


    @IBOutlet weak var bingoView: CycleScrollView!
    fileprivate let imageNames = ["1","2","3"]
    
 
    
//    var bingoView : BingoCycleScrollView = BingoCycleScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 3 / 5))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bingoView.register(CycleScrollViewCell.self, forCellWithReuseIdentifier: "cell")
        
        let transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        self.bingoView.itemSize = self.bingoView.frame.size.applying(transform)
        self.bingoView.backgroundColor = UIColor.white
        self.bingoView.tag = 9999
        self.bingoView.delegate = self
        self.bingoView.dataSource = self
        self.bingoView.transformer = CycleScrollViewTransformer(type: .linear)
        self.bingoView.interitemSpacing = 20
        self.bingoView.isInfinite = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func numberOfItems(in cycleScrollView: CycleScrollView) -> Int {
        return imageNames.count
    }
    
    
    func cycleScrollView(_ cycleScrollView: CycleScrollView, cellForItemAt index: Int) -> CycleScrollViewCell {
        let cell = bingoView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    func cycleScrollView(_ cycleScrollView: CycleScrollView, didSelectItemAt index: Int) {
        bingoView.deselectItem(at: index, animated: true)
        bingoView.scrollToItem(at: index, animated: true)
    }
    
}
