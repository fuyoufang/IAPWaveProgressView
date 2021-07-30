//
//  ProgressContentView.swift
//  WaveProgress
//
//  Created by fuyoufang on 2021/7/28.
//

import UIKit

class ProgressContentView: UIView {
    
    // MARK: Properties
    var waveProgressInsets: CGFloat = 6 {
        didSet {
            waveProgressView.snp.updateConstraints {
                $0.edges.equalTo(UIEdgeInsets(top: waveProgressInsets,
                                              left: waveProgressInsets,
                                              bottom: waveProgressInsets,
                                              right: waveProgressInsets))
            }
        }
    }
    
    // MARK: UI
    
    /// 圆圈进度
    lazy var circleProgressView = ContentCircleProgressView()
    
    /// 波纹动画
    lazy var waveProgressView = ContentWaveProgressView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        addSubview(circleProgressView)
        addSubview(waveProgressView)
        circleProgressView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        waveProgressView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsets(top: waveProgressInsets,
                                          left: waveProgressInsets,
                                          bottom: waveProgressInsets,
                                          right: waveProgressInsets))
        }
    }
}

