//
//  IAPWaveProgressView.swift
//  LiveBee
//
//  Created by fuyoufang on 2021/7/22.
//

import UIKit
import Then
import SnapKit

/// IAP 支付的状态
public enum IAPProgressStatus {
    /// 准备支付
    ///    - tipMessage: 提示文案
    ///    - progress: 进度，会影响外面的圆圈的进度
    case prapare(tipMessage: String, progress: CGFloat)
    /// 支付中 / 验证中
    ///    - tipMessage: 提示文案
    ///    - progress: 进度，会影响中间波纹的进度
    case paying(tipMessage: String, progress: CGFloat)
    
    /// 支付完成
    ///    - tipMessage: 提示文案
    case complete(tipMessage: String)
}

/// 过度动画状态
public enum ProgressAnimation {
    /// 准备支付
    case prapare
    /// 支付中 / 验证中
    case paying
    /// 支付完成
    case complete
}

public class IAPWaveProgressView: UIView {
    
    // MARK: UI 配置属性
    
    /// 波动的上下浮动的速度，也就是波纹左右移动的速度
    public var speed: CGFloat {
        get {
            return progressContentView.waveProgressView.speed
        }
        set {
            progressContentView.waveProgressView.speed = newValue
        }
    }
    
    /// 波纹颜色
    public var waveColor: UIColor? {
        get {
            return progressContentView.waveProgressView.waveColor
        }
        set {
            progressContentView.waveProgressView.waveColor = newValue
        }
    }
    /// 波纹波动高度
    public var waveHeight: CGFloat {
        get {
            return progressContentView.waveProgressView.waveHeight
        }
        set {
            progressContentView.waveProgressView.waveHeight = newValue
        }
    }
    
    /// 最小路径颜色 / 已完成进度的颜色
    public var minimumTrackColor: UIColor {
        get {
            return progressContentView.circleProgressView.minimumTrackColor
        }
        set {
            progressContentView.circleProgressView.minimumTrackColor = newValue
        }
    }
    
    /// 最大路径颜色 / 未完成进度的颜色
    public var maximumTrackColor: UIColor {
        get {
            return progressContentView.circleProgressView.maximumTrackColor
        }
        set {
            progressContentView.circleProgressView.maximumTrackColor = newValue;
            
        }
    }
    
    /// 进度条线的宽度
    public var lineWidth: CGFloat {
        get {
            return progressContentView.circleProgressView.lineWidth
        }
        set {
            progressContentView.circleProgressView.lineWidth = newValue
        }
    }
    
    /// 进度动画的宽度
    public var progressViewWidth: CGFloat = 150 {
        didSet {
            progressContentView.snp.updateConstraints {
                $0.size.equalTo(CGSize(width: progressViewWidth,
                                       height: progressViewWidth))
            }
        }
    }
    
    /// 完成标识（对号）颜色
    public var complateMarkColor: UIColor = UIColor.clear
    /// 完成标识（对号）的时间
    public var completeMarkAnimation: TimeInterval = 1
    /// 完成标识（对号）的宽度
    public var completeMarkLineWidth: CGFloat = 5
    
    /// 波纹动画的内边距
    public var waveProgressInsets: CGFloat {
        get {
            return progressContentView.waveProgressInsets
        }
        set {
            progressContentView.waveProgressInsets = newValue
        }
    }
    
    // MARK: 属性
    
    /// 支付进度动画结束代码块
    public var statusAnimationEnd: ((ProgressAnimation) -> Void)?
    
    /// 设置更新支付状态
    public var payStatus: IAPProgressStatus = .prapare(tipMessage: "支付准备，请稍后...", progress: 0) {
        didSet {
            switch payStatus {
            case let .prapare(tipMessage, _),
                 let .paying(tipMessage, _),
                 let .complete(tipMessage):
                statusLabel.text = tipMessage
            }
            progressContentView.circleProgressView.isHidden = false
            startProgressAnimation()
        }
    }
    
    // MARK:  UI
    
    /// 模糊背景
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .extraLight)
        return UIVisualEffectView(effect: blurEffect).then {
            $0.alpha = 0.88
        }
    }()
    
    lazy var progressContentView = ProgressContentView().then {
        $0.circleProgressView.progressViewOver = { [weak self] in
            self?.statusAnimationEnd?(.prapare)
        }
    }
    
    /// 支付状态标签
    public var statusLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textAlignment = .center
    }
    
    /// 加载支付完成动画
    private var animationLayer: CALayer?
    
    private var checkLayer: CAShapeLayer?
    
    /// 定时器
    private var link: CADisplayLink?
    
   
    /// 初始化支付进度视图
    /// @param frame frame
    /// @param progressViewWidth 进度宽度
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blurView)
        addSubview(progressContentView)
        addSubview(statusLabel)
        
        let content = UILayoutGuide()
        addLayoutGuide(content)
        
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        content.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        progressContentView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: progressViewWidth, height: progressViewWidth))
            $0.top.equalTo(content)
            $0.centerX.equalTo(content)
        }
        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(progressContentView.snp.bottom).offset(22)
            $0.left.equalTo(10)
            $0.right.equalTo(-10)
            $0.bottom.equalTo(content)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopProgressAnimation()
    }
    
    // MARK: - 动画
    
    /// 开始进度动画
    func startProgressAnimation() {
        // 相对于NSTimer CADisplayLink更准确,每一帧调用一次.
        guard link == nil else {
            return
        }
        let link = CADisplayLink(target: self, selector: #selector(progressAnimation))
        link.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        self.link = link
    }
    
    /// 停止进度动画
    func stopProgressAnimation() {
        link?.invalidate()
        link = nil
    }
    
    /// 进度动画实现
    @objc func progressAnimation() {
        DispatchQueue.main.async {
            self.updateProgressAnimation()
        }
    }
    
    func updateProgressAnimation() {
        
        switch payStatus {
        case var .prapare(_, progress):
            progress = max(1, min(0, progress))
            var circleProgress = progressContentView.circleProgressView.progress + 0.005
            circleProgress = min(circleProgress, progress)
            
            progressContentView.waveProgressView.do {
                $0.progress = 0.0
                $0.isHidden = true
            }
            
            progressContentView.circleProgressView.progress = circleProgress
            
            guard circleProgress >= progress else {
                return
            }
            stopProgressAnimation()
              
        case var .paying(_, progress):
            progress = max(1, min(0, progress))
            var waveProgress = progressContentView.waveProgressView.progress + 0.005
            waveProgress = min(waveProgress, progress)
            
            progressContentView.waveProgressView.do {
                $0.progress = waveProgress
                $0.isHidden = false
            }
            
            progressContentView.circleProgressView.progress = 1.0
            
            guard waveProgress >= progress else {
                return
            }
            stopProgressAnimation()
            guard progress == 1.0 else {
                return
            }
            statusAnimationEnd?(.paying)
        case .complete:
            progressContentView.waveProgressView.do {
                $0.progress = 1
                $0.isHidden = false
            }
            progressContentView.circleProgressView.progress = 1.0
            stopProgressAnimation()
            loadCompleteAnimation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + completeMarkAnimation + 1) {
                self.animationLayer?.removeFromSuperlayer()
                self.animationLayer = nil
                self.checkLayer?.removeFromSuperlayer()
                self.checkLayer = nil
                self.progressContentView.circleProgressView.progress = 0
                self.progressContentView.waveProgressView.isHidden = true
                self.progressContentView.waveProgressView.progress = 0
                self.statusAnimationEnd?(.complete)
            }
        }
    }
    
    /// 加载完成对号动画
    func loadCompleteAnimation() {
        guard self.checkLayer == nil else {
            return
        }
        let animationLayer = CALayer().then {
            $0.bounds = progressContentView.waveProgressView.bounds
            $0.position = CGPoint(x: progressContentView.waveProgressView.bounds.size.width / 2,
                                  y: progressContentView.waveProgressView.bounds.size.height / 2)
        }
        
        let checkLayer = CAShapeLayer().then {
            let width = animationLayer.bounds.size.width;
            $0.path = UIBezierPath()
                .then {
                    $0.move(to: CGPoint(x: width*2.63/10, y: width*4.95/10))
                    $0.addLine(to: CGPoint(x: width*4.31/10, y: width*6.26/10))
                    $0.addLine(to: CGPoint(x: width*7.35/10, y: width*3.59/10))
                }.cgPath
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = complateMarkColor.cgColor
            $0.lineWidth = completeMarkLineWidth
            $0.lineCap = CAShapeLayerLineCap.round
            $0.lineJoin = CAShapeLayerLineJoin.round
            $0.strokeStart = 0
            $0.strokeEnd = 0
        }
        
        let checkAnimation = CABasicAnimation(keyPath: "strokeEnd").then {
            $0.duration = CFTimeInterval(completeMarkAnimation)
            $0.fromValue = 0.0
            $0.toValue = 1.0
            $0.delegate = self
            $0.setValue("checkAnimation", forKey: "animationName")
            $0.isRemovedOnCompletion = false
            $0.fillMode = CAMediaTimingFillMode.forwards
        }
        
        checkLayer.add(checkAnimation, forKey: nil)
        animationLayer.addSublayer(checkLayer)
        progressContentView.waveProgressView.layer.addSublayer(animationLayer)
        
        self.checkLayer = checkLayer
        self.animationLayer = animationLayer
    }
    
    /// 隐藏所以支付进度视图
    public func hide() {
        removeFromSuperview()
    }
    
    public func show(in view: UIView) {
        view.addSubview(self)
        self.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension IAPWaveProgressView: CAAnimationDelegate {
    
}
