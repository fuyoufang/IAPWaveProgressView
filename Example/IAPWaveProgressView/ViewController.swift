//
//  ViewController.swift
//  WaveProgress
//
//  Created by fuyoufang on 2021/7/28.
//

import UIKit
import IAPWaveProgressView

class ViewController: UIViewController {
    
    var progressViewWidth: CGFloat = 200
    var waveHeight: CGFloat = 5.0
    var speed: CGFloat = 3.0
    var waveProgressInsets: CGFloat = 10
    var lineWidth: CGFloat = 3.0
    
    @IBAction func changeProgressViewWidth(_ sender: UISlider) {
        progressViewWidth = view.frame.size.width * CGFloat(sender.value)
    }
    
    @IBAction func changeWaveHeight(_ sender: UISlider) {
        waveHeight = 20 * CGFloat(sender.value)
    }
    
    @IBAction func changeSpeed(_ sender: UISlider) {
        speed = 10 * CGFloat(sender.value)
    }
    
    @IBAction func changeWaveProgressInsets(_ sender: UISlider) {
        waveProgressInsets = 50 * CGFloat(sender.value)
    }
    
    @IBAction func changeLineWidth(_ sender: UISlider) {
        lineWidth = 10 * CGFloat(sender.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    var progress: IAPWaveProgressView?
    
    @IBAction func beginHud(_ sender: Any) {
        
        let progress = IAPWaveProgressView()
            .then {
                // 进度 view 的宽度
                $0.progressViewWidth = progressViewWidth
                
                // 波纹波动高度
                $0.waveHeight = waveHeight
                // 波动的上下浮动的速度
                $0.speed = 3.0
                // 波纹动画的内边距
                $0.waveProgressInsets = waveProgressInsets
                // 进度条线的宽度
                $0.lineWidth = lineWidth
                $0.completeMarkLineWidth = 8
                
                // 最小路径颜色 / 已完成进度的颜色
                $0.minimumTrackColor = UIColor.black.withAlphaComponent(0.05)
                // 最大路径颜色 / 未完成进度的颜色
                $0.maximumTrackColor = UIColor(red: 114.0 / 255, green: 114.0 / 255, blue: 240.0 / 255, alpha: 1)
                // 波纹颜色
                $0.waveColor = UIColor(red: 114.0 / 255, green: 114.0 / 255, blue: 240.0 / 255, alpha: 1)
                // 完成标识的颜色
                $0.complateMarkColor = .white
            }
        progress.statusAnimationEnd = { [weak progress] (status) in
            switch status {
            case .complete:
                progress?.hide()
            default:
                break
            }
            debugPrint("pay end, status: \(status)")
        }
        
        progress.show(in: view)
        progress.payStatus = .prapare(tipMessage: "支付准备，请稍后...", progress: 0)
            
        var time: DispatchTime = .now() + 1
        DispatchQueue.main.asyncAfter(deadline: time) {
            progress.payStatus = .prapare(tipMessage: "支付准备，请稍后...", progress: 1)
        }
        time = time + 1
        DispatchQueue.main.asyncAfter(deadline: time) {
            progress.payStatus = .paying(tipMessage: "支付中，请稍后...", progress: 0.2)
        }
        time = time + 1
        DispatchQueue.main.asyncAfter(deadline: time) {
            progress.payStatus = .paying(tipMessage: "支付中，请稍后...", progress: 0.6)
        }
        time = time + 2
        DispatchQueue.main.asyncAfter(deadline: time) {
            progress.payStatus = .paying(tipMessage: "支付成功，正在验证...", progress: 0.9)
        }
        time = time + 2
        DispatchQueue.main.asyncAfter(deadline: time) {
            progress.payStatus = .complete(tipMessage: "恭喜！支付完成")
        }
    }

}

