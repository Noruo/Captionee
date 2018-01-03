//
//  OnboadingViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2018/01/02.
//  Copyright © 2018年 enPiT2SU. All rights reserved.
//

import UIKit
import MaterialComponents

class OnboadingViewController: UIViewController, UIScrollViewDelegate {
    
    var window: UIWindow?
    let pageControl = MDCPageControl()
    var scrollView: UIScrollView!
    let pages = NSMutableArray()
    let getStartedButton = MDCRaisedButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ページごとの背景色
        let pageColors = [MDCPalette.blue.tint500, MDCPalette.blue.tint600, MDCPalette.blue.tint700]
        let pageImages = ["Subtitles", "Translate", "Happy"]
        
        // ScrollViewを作成
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: view.bounds.width*CGFloat(pageColors.count), height: view.bounds.height)
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        // ページごとの設定
        for i in 0..<pageColors.count {
            // ページフレームの設定
            let pageFrame = view.bounds.offsetBy(dx: CGFloat(i)*view.bounds.width, dy: 0)
            
            let pageImage = UIImageView(frame: pageFrame)
            let image = UIImage(named: pageImages[i])
            pageImage.image = image
            pageImage.tintColor = UIColor.black
            pageImage.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
            scrollView.addSubview(pageImage)
            
            /*
            // ページラベルの設定
            let pageLabel = UILabel(frame: pageFrame)
            pageLabel.text = "Page \(i)"
            pageLabel.font = MDCTypography.body1Font()
            pageLabel.textAlignment = .center
            pageLabel.backgroundColor = pageColors[i]
            pageLabel.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
            scrollView.addSubview(pageLabel)
            pages.add(pageLabel)
            */
        }
        
        // ページ数
        pageControl.numberOfPages = 3
        
        // PageControlの設定
        let pageControlSize = pageControl.sizeThatFits(view.bounds.size)
        pageControl.frame = CGRect(x: 0, y: view.bounds.height - pageControlSize.height, width: view.bounds.width, height: pageControlSize.height)
        pageControl.addTarget(self, action: #selector(didChangePage), for: .valueChanged)
        pageControl.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        view.addSubview(pageControl)
        
        // GetStartedButtonの設定
        getStartedButton.setTitle("GET STARTED", for: .normal)
        getStartedButton.setBackgroundColor(UIColor.white)
        getStartedButton.setTitleFont(MDCTypography.buttonFont(), for: .normal)
        getStartedButton.setTitleColor(MDCPalette.blue.tint500, for: .normal)
        getStartedButton.addTarget(self, action: #selector(getStarted), for: .touchUpInside)
        view.addSubview(getStartedButton)
        
        // GetStartedButtonの制約を設定
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44).isActive = true
        getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        getStartedButton.widthAnchor.constraint(equalToConstant: 132).isActive = true
        getStartedButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    /*
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let pageBeforeChange = pageControl.currentPage
        let pageCount = pages.count
        
        for i in 0..<pageCount {
            let page: UILabel = pages.object(at: i) as! UILabel
            page.frame = view.bounds.offsetBy(dx: CGFloat(i)*view.bounds.width, dy: 0)
        }
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        
        var offset = scrollView.contentOffset
        offset.x = CGFloat(pageBeforeChange) * view.bounds.width
        scrollView.setContentOffset(offset, animated: false)
        
        let standardizedFrame = view.frame.standardized
        pageControl.sizeThatFits(standardizedFrame.size)
        
        var edgeInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            edgeInsets = view.safeAreaInsets
        }
        
        let yOffset = view.frame.height - pageControl.frame.height - edgeInsets.bottom
        pageControl.frame = CGRect(x: 0, y: yOffset, width: view.frame.width, height: pageControl.frame.height)
        
        nextButton.sizeToFit()
        let buttonCenterX = view.bounds.width - nextButton.frame.width / 2 - 16 - edgeInsets.right
        nextButton.center = CGPoint(x: buttonCenterX, y: pageControl.center.y)
    }
    */
    
    @objc func didChangePage(sender: MDCPageControl){
        print("Page changed.")
        
        var offset = scrollView.contentOffset
        offset.x = CGFloat(sender.currentPage) * scrollView.bounds.size.width;
        scrollView.setContentOffset(offset, animated: true)
    }
    
    @objc func getStarted(sender: MDCRaisedButton) {
        print("Get started!")
        
        //dismiss(animated: true, completion: nil)
        
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //MainViewcontrollerを指定
        let initialViewController = storyboard.instantiateInitialViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        //rootViewControllerに入れる
        window?.rootViewController = initialViewController
        //MainVCを表示
        window?.makeKeyAndVisible()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("DidScroll")
        
        pageControl.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("DidEndDecelerating")
        
        pageControl.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("EndScrollingAnimation")
        
        pageControl.scrollViewDidEndScrollingAnimation(scrollView)
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

}
