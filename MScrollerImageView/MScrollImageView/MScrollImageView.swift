//
//  MScrollImageView.swift
//  MScrollerImageView
//
//  Created by Micheal on 2016/11/28.
//  Copyright © 2016年 Micheal. All rights reserved.
//

import UIKit

// MARK: - 图片点击delegate
protocol ScrollerImageViewDelegate {
    
    func didSelectedScrollImage(_ scrollImage: MScrollImageView, atIndex:Int)
}

class MScrollImageView: UIView,UIScrollViewDelegate,UIGestureRecognizerDelegate {
    /**代理 */
    var delegate:ScrollerImageViewDelegate?
    /**多少个Imgae循环滚动，默认为0 */
    var bannerCount:Int = 0
    /**滚动图片的数组 */
    var images:Array<String>? = []
    /**滚动scroller */
    fileprivate var bannerScrollView:UIScrollView?
    /**页数 */
    fileprivate var pageControl:UIPageControl?
    /**定时器 */
    fileprivate var timer:Timer?
    /**传入数组是否为url */
    fileprivate var isUrl:Bool?
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - frame: 位置
    ///   - images: 图片数组
    ///   - isUrl: 是否是URL
    init(frame: CGRect, images:Array<String>, isUrl:Bool) {
        super.init(frame: frame)
        
        self.frame = frame
        self.isUserInteractionEnabled = true
        self.images = images
        self.isUrl = isUrl
        self.bannerCount = self.images!.count

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 添加新视图时调用（在一个子视图将要被添加到另一个视图的时候发送此消息）
    ///
    /// - Parameter newSuperview:
    override func willMove(toSuperview newSuperview: UIView?) {
        
        if newSuperview == nil {
            return
        }
        setup()
        //  2s定时器
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MScrollImageView.autoChangeBanner), userInfo: nil, repeats: true)
        super.willMove(toSuperview: newSuperview)
    }
    
    /// 控件初始化
    @objc fileprivate func setup() {
        
        if self.frame.size.width == 0 || self.frame.size.height == 0 {
            print("未设置frame， 或者frame设置错误")
        }
        bannerScrollView = UIScrollView(frame: self.bounds)
        bannerScrollView!.autoresizingMask = .flexibleWidth
        bannerScrollView!.autoresizingMask = .flexibleHeight
        bannerScrollView!.delegate = self
        bannerScrollView!.isPagingEnabled = true
        bannerScrollView!.showsHorizontalScrollIndicator = false
        bannerScrollView!.contentSize = CGSize(width: self.bounds.size.width*CGFloat(bannerCount+2), height: self.bounds.size.height)
        bannerScrollView!.contentOffset = CGPoint(x: self.bounds.size.width, y: 0.0)
        for index in -1...bannerCount {
            
            let imageWith = bannerScrollView!.frame.size.width
            let imageHeight = bannerScrollView!.frame.size.height
            let imageButton = UIButton(frame: CGRect(x: imageWith*CGFloat(index+1), y: 0.0, width: imageWith, height: imageHeight))
            bannerScrollView!.addSubview(imageButton)
            let temp = index == -1 ? bannerCount-1 : (index == bannerCount ? 0 : index)
            imageButton.tag = index
            imageButton.addTarget(self, action: #selector(MScrollImageView.imageButtonClick(button:)), for: .touchUpInside)
            imageButton.autoresizingMask = .flexibleWidth
            imageButton.autoresizingMask = .flexibleHeight
            //  添加图片
            let buttonBackImage = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: imageButton.frame.size.width, height: imageButton.frame.size.height))
            if isUrl! {
                let imageData = try! Data(contentsOf: URL(string: images![temp])!)
                buttonBackImage.image = UIImage(data: imageData)
            }else {
                buttonBackImage.image = UIImage(named: images![temp])
            }
            imageButton.addSubview(buttonBackImage)
        }
        self.addSubview(bannerScrollView!)
        pageControl = UIPageControl(frame: CGRect(x: 0.0, y: bannerScrollView!.frame.size.height-20.0, width: self.bounds.size.width, height: 19.0))
        pageControl!.numberOfPages = bannerCount
        pageControl!.currentPage = 0
        pageControl!.pageIndicatorTintColor = .lightGray
        pageControl!.currentPageIndicatorTintColor = .red
        pageControl!.autoresizingMask = .flexibleWidth
        pageControl!.autoresizingMask = .flexibleHeight
        self.addSubview(pageControl!)
        if images!.count <= 1 {
            pageControl!.isHidden = true
        }
    }
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !scrollView.isKind(of: UITableView.self) {
            
            if scrollView.contentOffset.x <= 0.0 {
                
                scrollView.setContentOffset(CGPoint(x:CGFloat(bannerCount)*self.bounds.size.width, y:0.0), animated: false)
                pageControl!.currentPage = bannerCount;
            }else if scrollView.contentOffset.x >= CGFloat(bannerCount+1)*self.bounds.size.width {
                
                scrollView.setContentOffset(CGPoint(x:self.bounds.size.width, y:0.0), animated: false)
                pageControl!.currentPage = 0;
            }else if Int(scrollView.contentOffset.x) % Int(self.bounds.size.width) == 0 {
                
                if pageControl != nil {
                    pageControl!.currentPage = Int(scrollView.contentOffset.x/self.bounds.size.width)-1;
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if !scrollView.isKind(of: UITableView.self) {
            
            timer!.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MScrollImageView.autoChangeBanner), userInfo: nil, repeats: true)
            let offsetX = scrollView.contentOffset.x == 0 ? CGFloat(bannerCount)*self.bounds.size.width : scrollView.contentOffset.x == CGFloat(bannerCount+1)*self.bounds.size.width ? self.bounds.size.width : scrollView.contentOffset.x
            scrollView.setContentOffset(CGPoint(x: offsetX,y: 0.0), animated: false)
            pageControl!.currentPage = Int(offsetX/self.bounds.size.width)-1
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        if !scrollView.isKind(of: UITableView.self) {
            
            let offsetX = scrollView.contentOffset.x == 0 ? CGFloat(bannerCount)*self.bounds.size.width : scrollView.contentOffset.x == CGFloat(bannerCount+1)*self.bounds.size.width ? self.bounds.size.width : scrollView.contentOffset.x
            scrollView.setContentOffset(CGPoint(x: offsetX,y: 0.0), animated: false)
            pageControl!.currentPage = Int(offsetX/self.bounds.size.width)-1
        }
    }
    // MARK: - Action
    @objc fileprivate func autoChangeBanner() {
        
        if images!.count > 1 {
            bannerScrollView!.setContentOffset(CGPoint(x: bannerScrollView!.contentOffset.x+self.bounds.size.width, y: 0.0), animated: true)
        }
    }
    
    @objc fileprivate func imageButtonClick(button:UIButton) {
        //  响应事件
        delegate!.didSelectedScrollImage(self, atIndex: button.tag)
    }
    
    deinit {
        timer!.invalidate()
        timer = nil
    }
}
