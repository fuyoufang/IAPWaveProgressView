//
//  ContentWaveProgressView.swift
//  WaveProgress
//
//  Created by fuyoufang on 2021/7/28.
//

import UIKit

/// 水波动画 view
/// 水波动画的关键点就在于正余弦函数，使用两条正余弦函数进行周期性变化，就会产生所谓的波纹动画。
class ContentWaveProgressView: UIView {
    
    /// 波纹进度
    /// 波纹占比 0 - 1
    var progress: CGFloat = 0 {
        didSet {
            progress = max(0, min(progress, 1))

            guard progress != oldValue else {
                return
            }
            
            //由于y坐标轴的方向是由上向下,逐渐增加的,所以这里对于y坐标进行处理
            self.yHeight = self.bounds.size.height * (1 - progress)
            //先停止动画,然后在开始动画,保证不会有什么冲突和重复.
            stopWaveAnimation()
            startWaveAnimation()
        }
    }
    
    /// 波动的速度
    var speed: CGFloat = 1
    
    /// 波纹颜色，默认值 UIColor.blue
    var waveColor: UIColor? {
        get {
            guard let waveColor = waveLayer.fillColor else {
                return nil
            }
            return UIColor(cgColor: waveColor)
        }
        set {
            self.waveLayer.fillColor = newValue?.cgColor
        }
    }
    
    /// 波纹波动高度
    var waveHeight: CGFloat = 5.0
    
    // MARK: private

    /// 当前进度对应的y值，由于y是向下递增，所以要注意
    private var yHeight: CGFloat = 0
    /// 偏移量，决定了这个点在y轴上的位置，以此来实现动态效果
    private var offset: CGFloat = 0
    /// 定时器
    private var link: CADisplayLink?
    /// 水波的layer
    private var waveLayer = CAShapeLayer().then {
        $0.fillColor = UIColor.blue.cgColor
    }
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.do {
            $0.masksToBounds = true
            $0.borderColor = UIColor.clear.cgColor
            $0.borderWidth = 0.0
            $0.cornerRadius = min(frame.size.width, frame.size.height) * 0.5
        }
        
        self.yHeight = self.bounds.size.height
        self.layer.addSublayer(waveLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        waveLayer.frame = bounds
        layer.cornerRadius = min(frame.size.width, frame.size.height) * 0.5
    }

    // MARK: - 波动动画
    
    /// 开始波动动画
    func startWaveAnimation() {
        guard self.link == nil else {
            return
        }
        
        let link = CADisplayLink(target: self, selector: #selector(waveAnimation))
        link.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        self.link = link
    }

    /// 停止波动动画
    func stopWaveAnimation() {
        link?.invalidate()
        link = nil
    }

    /// 波动动画实现
    @objc func waveAnimation() {
        DispatchQueue.main.async {
            let waveHeight: CGFloat
            // 如果是0或者1,则不需要wave的高度,否则会看出来一个小的波动.
            if self.progress == 0 || self.progress == 1 {
                waveHeight = 0
            } else {
                waveHeight = self.waveHeight
            }
            // 累加偏移量,这样就可以通过speed来控制波动的速度了.
            // 对于正弦函数中的各个参数,你可以通过底部的注释进行了解.
            self.offset += self.speed

            // 周期
            let ω = Double.pi.cf * 2 / self.bounds.size.width
            // 初相位
            let φ = self.offset * ω
            let startOffY = waveHeight * sinf(φ.f).cf + self.yHeight
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: startOffY))
            
            var orignOffY: CGFloat = 0
            for i in 1...Int(self.bounds.size.width) {
                orignOffY = waveHeight * sinf((ω * i.cf + φ).f).cf + self.yHeight
                path.addLine(to: CGPoint(x: i.cf, y: orignOffY))
            }
            
            // 连接四个角和以及波浪,共同组成水波.
            path.addLine(to: CGPoint(x: self.bounds.size.width, y: orignOffY))
            path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
            path.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
            path.addLine(to: CGPoint(x: 0, y: startOffY))
            
            self.waveLayer.path = path
        }
    }

    deinit {
        stopWaveAnimation()
    }
}
/*
 正弦型函数解析式：y = A * sin(ω * x + φ) + h
 各常数值对函数图像的影响：
 A：决定峰值（即纵向拉伸压缩的倍数）
 ω：决定周期（最小正周期T=2π/|ω|）
 φ：初相位，决定波形与X轴位置关系或横向移动距离（左加右减）
 h：表示波形在Y轴的位置关系或纵向移动距离（上加下减）
 */
/*
 如果想绘制出来一条正弦函数曲线，可以沿着假想的曲线绘制许多个点，然后把点逐一用直线连在一起，如果点足够多，就可以得到一条满足需求的曲线，这也是一种微分的思想。而这些点的位置可以通过正弦函数的解析式求得。
 假如水波的峰值是1，周期是2π，初相位是0，h位移也是0。那么计算各个点的坐标公式就是y = sin(x);
 获得各个点的坐标之后，使用CGPathAddLineToPoint这个函数，把这些点逐一连成线，就可以得到最后的路径。

 如果想要得到一个动态的波纹,随着时间的变化,我们如果假定每个点的x位置没有变化,那么只要让其y随着时间有规律的变化就可以让人觉得是在有规律的动.
 需要注意UIKit的坐标系统y轴是向下延伸。
 如果想在0到2π这个距离显示2个完整的波曲线，那么周期就是π.如果每次增加π/4,则4s就会完成一个周期.
 如果想要在宽度 width 上展示2个周期的水波,则周期是waveWidth / 2,w = 2 * M_PI / waveWidth
 */
