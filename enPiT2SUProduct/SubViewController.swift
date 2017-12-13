//
//  SubViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/11/05.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import AVKit
import MaterialComponents

class SubViewController: UIViewController {
	
	var receivedVideoInfo: VideoInfo!
	var receivedTranslation: String!
    
    var player: AVPlayer!
    var timeSlider: MDCSlider!
    var timeObserverToken: Any!
    var isPlaying = false
    
    var isFinished: Bool {
        return currentTime == duration
    }
    
    var currentTime: Double {
        get {
            return player.currentTime().seconds
        }
        set {
            let newTime = CMTimeMakeWithSeconds(newValue, 1000)
            
            player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    var duration: Double {
        guard let currentItem = player.currentItem else { return 0.0 }
        
        return CMTimeGetSeconds(currentItem.asset.duration)
    }
	
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var translation: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
	override func viewDidLoad() {
		super.viewDidLoad()
        print("ViewController/viewDidLoad/インスタンス化された直後（初回に一度のみ）")
        
        // DocumentDirectoryのPath
        let documentPath: String = FileManager.documentDir
        
        // 動画のURL
        let url = URL(fileURLWithPath: documentPath + "/" + receivedVideoInfo.name + ".mp4")
        
        // AVPlayerを生成
        player = AVPlayer(url: url)
        
        // 動画の時間を初期化
        currentTime = 0.0
        
        // AVPlayerViewControllerの設定
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height/2)
        playerViewController.showsPlaybackControls = false
        
        // TimeObserverを設定
        addPeriodicTimeObserver()
        
        // AVPlayerViewControllerをViewControllerに追加
        addChildViewController(playerViewController)
        
        // 最大画面になった時、これが使用される感じ
        view.addSubview(playerViewController.view)
        
        // 字幕のLabelのサイズを設定
        caption.frame = CGRect(x: 10, y: view.bounds.size.height*2/5, width: view.bounds.size.width-20, height: view.bounds.size.height/5)
        
        // 翻訳のLabelのサイズを設定
		translation.frame = CGRect(x: 10, y: view.bounds.size.height*3/5, width: view.bounds.size.width-20, height: view.bounds.size.height/5)
        
        // 字幕を表示
        caption.text = ""
		
		// 翻訳結果を表示
		translation.text = receivedTranslation
        
        // ボタンをクリックしたときに呼び出すメソッドを指定
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)

        // スライダーの設定
        timeSlider = MDCSlider(frame: CGRect(x: playButton.frame.size.width+30, y: view.bounds.size.height-105,
                                             width: view.bounds.size.width-playButton.frame.size.width-60, height: 5))
        timeSlider.minimumValue = 0.0
        timeSlider.maximumValue = CGFloat(duration)
        timeSlider.isContinuous = true
        timeSlider.isThumbHollowAtStart = false
        timeSlider.color = MDCPalette.orange.tint500
        
        // スライダーの値が変わったときに呼び出すメソッドを指定
        timeSlider.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        timeSlider.addTarget(self, action: #selector(timeSliderTapped), for: .touchUpInside)
        
        view.addSubview(timeSlider)
	}
    
    /* 再生・停止ボタンが押されたとき */
    @objc func playButtonTapped(sender: UIButton) {
        // 再生・停止の切り替え
        isPlaying = !isPlaying
        
        if isPlaying {
            if isFinished {
                currentTime = 0.0
            }
            
            play()
        } else {
            pause()
        }
    }
    
    /* 動画を再生する */
    func play() {
        // 再生
        print("再生")
        player.play()
        
        // 背景画像をPauseに変える
        playButton.setImage(UIImage(named: "Pause"), for: .normal)
    }
    
    /* 動画を一時停止する */
    func pause() {
        // 停止
        print("停止")
        player.pause()
        
        // 背景画像をPlayに変える
        playButton.setImage(UIImage(named: "Play"), for: .normal)
    }
    
    /* スライダーの値が変わったとき */
    @objc func timeSliderChanged(sender: MDCSlider) {
        print("スライダーの値が変わった")
        
        // 動画の時間をスライダーの値にする
        currentTime = Double(sender.value)
    }
    
    /* スライダーがタップされたとき */
    @objc func timeSliderTapped(sender: MDCSlider) {
        print("スライダーがタップされた")
        
        if isPlaying {
            player.pause()
            currentTime = Double(sender.value)
            player.play()
        } else {
            currentTime = Double(sender.value)
        }
    }
    
    /* 一定時間ごとに動画の再生状態を監視する */
    func addPeriodicTimeObserver() {
        // 監視の時間間隔
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        // メインスレッド
        let mainQueue = DispatchQueue.main
        
        // TimeObserverを生成
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            guard let wself = self else { return }
            
            // 動画の再生が終わっているとき
            if wself.isFinished {
                // 動画を一時停止中にする
                wself.isPlaying = false
                wself.playButton.setImage(UIImage(named: "Play"), for: .normal)
            }
            
            // Sliderの値を変える
            wself.timeSlider.setValue(CGFloat(wself.currentTime), animated: true)
            print(wself.currentTime)
            
            // 字幕を適切なタイミングで表示
            if let captions = wself.receivedVideoInfo.caption {
                for caption in captions.sentences {
                    if wself.currentTime >= caption.startTime && wself.currentTime <= caption.endTime {
                        wself.caption.text = caption.sentence + "。"
                        break
                    }
                }
            } else {
                wself.caption.text = "Caption is nil."
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController/viewWillAppear/画面が表示される直前")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewController/viewDidAppear/画面が表示された直後")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController/viewWillDisappear/別の画面に遷移する直前")
        
        // 動画の再生を止める
        player.pause()
        
        // TimeObserverを廃棄
        timeObserverToken = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController/viewDidDisappear/別の画面に遷移した直後")
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
        print("ViewController/didReceiveMemoryWarning/メモリが足りないので開放される")
	}
}
