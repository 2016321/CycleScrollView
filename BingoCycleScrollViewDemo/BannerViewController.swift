//
//  BannerViewController.swift
//  BingoCycleScrollViewDemo
//
//  Created by 王昱斌 on 17/6/7.
//  Copyright © 2017年 Qtin. All rights reserved.
//

import UIKit

class BannerViewController: UIViewController ,CycleScrollViewDataSource,CycleScrollViewDelegate{
    fileprivate let imageNames = ["1","2","3"]
    fileprivate let webImageName = [
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1493185391&di=08762b39321f5ab3020446c0b8d0eaad&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.ctolib.com%2FuploadImg%2FAED45344E96ABCF311C2C7421134D170%2F90.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1492590673378&di=3060d99cddba7fefed58ca2f4b046d5b&imgtype=0&src=http%3A%2F%2Fassets.warpspire.com%2Fimages%2Fgithub%2Foctocat.png",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1492590673377&di=b005c11d2624f4d1c556663341399910&imgtype=0&src=http%3A%2F%2Fp1.qhimg.com%2Ft011f9e05890e3df463.png"
    ]
    fileprivate let webImageNamebingo = [
        "http://img0.178.com/dota/201006/71088244422/71103483998.jpg",
        "http://cdn.duitang.com/uploads/item/201310/17/20131017124254_KzjVs.thumb.700_0.jpeg",
        "http://tupian.enterdesk.com/2013/lxy/12/9/3/5.jpg"
    ]
    
    fileprivate let titleNames = [
        "2017里屋酒店咨询设计论坛，酒店设计的蜂缠蝶恋",
        "2016里屋酒店咨询设计论坛，酒店设计的蜂缠蝶恋",
        "2015里屋酒店咨询设计论坛，酒店设计的蜂缠蝶恋"
    ]

    var bingoView : CycleScrollView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setUI()
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bingoView.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.width * 0.3)
        bingoView.collectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width * 0.3)
    }
    func setUI() -> Void {
        self.bingoView = CycleScrollView(frame: .zero)
        self.view.addSubview(bingoView)
        self.bingoView.register(CycleScrollViewCell.self, forCellWithReuseIdentifier: "cell")
        self.bingoView.imageNames = webImageName
        self.bingoView.titleNames = titleNames
        //        self.bingoView.itemSize = self.bingoView.frame.size.applying(transform)
        self.bingoView.backgroundColor = UIColor.white
        self.bingoView.tag = 9999
        self.bingoView.delegate = self
        self.bingoView.dataSource = self
        //        self.bingoView.transformer = CycleScrollViewTransformer(type: .linear)
//                self.collectionView.frame = CGRect(x: 0, y: TopSpace, width: CycleScrollViewWidth, height: CycleScrollViewCollectionHeight)
        self.bingoView.itemSize = CGSize(width: self.view.frame.width - 48, height: self.view.frame.width * 0.3)
        self.bingoView.interitemSpacing = 12
        self.bingoView.isInfinite = false
//        bingoView.collectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width * 0.3)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfItems(in cycleScrollView: CycleScrollView) -> Int {
        return imageNames.count
    }
    
    
    func cycleScrollView(_ cycleScrollView: CycleScrollView, cellForItemAt index: Int) -> CycleScrollViewCell {
        let cell = bingoView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        //        cell.imageView?.image = UIImage(named: self.imageNames[index])
        //        cell.imageView?.contentMode = .scaleAspectFill
        //        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    func cycleScrollView(_ cycleScrollView: CycleScrollView, didSelectItemAt index: Int) {
        bingoView.deselectItem(at: index, animated: true)
        bingoView.scrollToItem(at: index, animated: true)
        let vc = BannerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.bingoView.imageNames = webImageNamebingo
    }
}
