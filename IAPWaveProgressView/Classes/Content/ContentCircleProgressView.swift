//
//  ContentCircleProgressView.swift
//  WaveProgress
//
//  Created by fuyoufang on 2021/7/28.
//

import UIKit

class ContentCircleProgressView: UIView {
    
    /// 进度到达最大点，value等于1的时候的代理
    var progressViewOver: (() -> Void)?
    
    ///进度条的宽度
    var lineWidth: CGFloat = 3 {
        didSet {
            lineWidth = max(lineWidth, 0)
            self.frontFillLayer.lineWidth = self.lineWidth
            self.backgroundLayer.lineWidth = self.lineWidth
        }
    }
    
    /// 进度值0-1.0之间
    var progress: CGFloat = 0 {
        didSet {
            progress = max(0, min(progress, 1))
            guard progress != oldValue else {
                return
            }
            
            updateFrontFillLayer()
        }
    }
    
    func updateFrontFillLayer() {
        DispatchQueue.main.async {
            
            let width = self.bounds.size.width
            
            let frontFillBezierPath = UIBezierPath(arcCenter: CGPoint(x: width/2.0, y: width/2.0),
                                                   radius: (width - self.lineWidth)/2,
                                                   startAngle: -0.25 * 2 * Double.pi.cf,
                                                   endAngle: (2 * Double.pi.cf) * self.progress - 0.25 * 2 * Double.pi.cf,
                                                   clockwise: true)
            
            
            self.frontFillLayer.path = frontFillBezierPath.cgPath
            if self.progress == 1 {
                self.progressViewOver?()
             }
        }
    }

    /// 最小路径颜色 / 已完成进度的颜色
    var minimumTrackColor: UIColor = UIColor(red: 190/255.0, green: 1, blue: 167/255.0, alpha: 1) {
        didSet {
            backgroundLayer.strokeColor = minimumTrackColor.cgColor;
        }
    }
    
    /// 最大路径颜色 / 未完成进度的颜色
    var maximumTrackColor: UIColor = UIColor(red: 78/255.0, green: 194/255.0, blue: 0, alpha: 1) {
        didSet {
            frontFillLayer.strokeColor = maximumTrackColor.cgColor
        }
    }
    
    /// 背景图层
    private let backgroundLayer = CAShapeLayer().then {
        $0.fillColor = nil
    }
    /// 填充的图层
    private let frontFillLayer = CAShapeLayer().then {
        $0.fillColor = nil
    }
    
    private var frontFillBezierPath: UIBezierPath?   //用来填充的贝赛尔曲线

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(frontFillLayer)
        
        backgroundLayer.strokeColor = minimumTrackColor.cgColor
        frontFillLayer.strokeColor = maximumTrackColor.cgColor
        // 设置线宽
        self.frontFillLayer.lineWidth = self.lineWidth
        self.backgroundLayer.lineWidth = self.lineWidth
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            let width = self.bounds.size.width
            
            let layBorderWidth = self.lineWidth
            let backGroundBezierPath = UIBezierPath(arcCenter: CGPoint(x: width / 2.0, y: width / 2.0),
                                                     radius: (width - layBorderWidth) / 2,
                                                     startAngle: 0,
                                                     endAngle: Double.pi.cf * 2,
                                                     clockwise: true)
                
            self.backgroundLayer.do {
                $0.frame = self.bounds
                $0.path = backGroundBezierPath.cgPath
            }
            self.frontFillLayer.frame = self.bounds
        }
    }
}
