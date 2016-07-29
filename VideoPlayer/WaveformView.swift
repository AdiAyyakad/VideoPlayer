//
//  WaveformView.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/29/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit
import AVFoundation

class WaveformView: UIView {

    var fillColor: UIColor = .redColor()
    var borderColor: UIColor = .blackColor()
    var progressLayer = CAShapeLayer()
    weak var player: AVPlayer?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    convenience init() {
        self.init(frame: .zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initWithCoder not implemented")
    }
}

// MARK: - Private Setup

private extension WaveformView {

    func setup() {

        progressLayer.path = UIBezierPath(rect: CGRect(origin: bounds.origin,
                                                               size: CGSize(width: 0, height: bounds.height))).CGPath
        progressLayer.fillColor = fillColor.CGColor
        progressLayer.borderColor = borderColor.CGColor
        progressLayer.borderWidth = 1.0

        layer.addSublayer(progressLayer)
    }

}

// MARK: - Actions

extension WaveformView {

    func updateProgress(progress: Double) {

        progressLayer.path = UIBezierPath(rect: CGRect(origin: bounds.origin,
                                                       size: CGSize(width: CGFloat(progress)*bounds.width, height: bounds.height))).CGPath
        progressLayer.didChangeValueForKey("path")
    }

}
