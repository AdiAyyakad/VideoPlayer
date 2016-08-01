//
//  OverlayView.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/29/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit
import AVFoundation

class OverlayView: UIView {

    // MARK: - Overlay Properties

    var isVisible: Bool {
        return !hidden
    }

    var isPlaying = false
    let textLabel = UILabel()
    var font: UIFont = .systemFontOfSize(30)
    let playPauseButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))

    private var delay: Double = 3.0
    private let panGestureRecognizer = UIPanGestureRecognizer()

    private var textLabelFrame: CGRect {
        return CGRect(origin: CGPoint(x: 0, y: playPauseButton.frame.maxY+12), size: CGSize(width: bounds.width, height: 30))
    }
    private var waveformLayerFrame: CGRect {
        return CGRect(origin: textLabelFrame.origin, size: CGSize(width: bounds.width, height: 80))
    }

    // MARK: - Waveform Properties

    var fillColor: UIColor = .redColor()
    var borderColor: UIColor = .blackColor()
    var waveformLayer = CAShapeLayer()
    weak var player: AVPlayer?

    init() {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initWithCoder not implemented")
    }

    override func layoutSubviews() {

        textLabel.frame = textLabelFrame
        waveformLayer.frame = waveformLayerFrame

    }

}

// MARK: - Private Setup

private extension OverlayView {

    func setup() {

        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        hidden = true

        setupPlayPauseButton()
        setupWaveformView()
        setupTextLabel()

    }

    func setupPlayPauseButton() {

        playPauseButton.tintColor = .whiteColor()
        changeImage(UIImage(assetIdentifier: .Play))

        playPauseButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
        playPauseButton.contentMode = .Center
        playPauseButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        playPauseButton.userInteractionEnabled = true

        addSubview(playPauseButton)

    }

    func setupTextLabel() {

        textLabel.font = font
        textLabel.textAlignment = .Center
        textLabel.textColor = .whiteColor()
        textLabel.frame = textLabelFrame
        
        addSubview(textLabel)

    }

    func setupWaveformView() {

        waveformLayer.frame = waveformLayerFrame
        waveformLayer.path = UIBezierPath(rect: CGRect(origin: bounds.origin, size: CGSize(width: 0, height: bounds.height))).CGPath
        waveformLayer.fillColor = fillColor.CGColor
        waveformLayer.borderColor = borderColor.CGColor
        waveformLayer.borderWidth = 1.0

        layer.addSublayer(waveformLayer)

        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)
        
    }

}

// MARK: - Gesture Recognizers

extension OverlayView {

    @objc func handlePanGesture(recognizer: UIGestureRecognizer) {

        guard let item = player?.currentItem else {
            return
        }

        if isPlaying {
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hide), object: nil)
            pause()
        }

        let length = CMTimeGetSeconds(item.duration)
        let percentMoved = Double(recognizer.locationInView(self).x/bounds.width)

        var seconds = percentMoved*length

        if seconds < 0 {
            seconds = 0
        } else if seconds > length {
            seconds = length
        }

        textLabel.text = String(format: "%d:%02d", Int(seconds)/60, Int(seconds)%60)
        updateWaveformProgress(percentMoved)

        player?.seekToTime(CMTime(seconds: seconds, preferredTimescale: Int32(NSEC_PER_SEC)))

        if recognizer.state == .Ended {
            performSelector(#selector(hide), withObject: nil, afterDelay: delay)
            if !isPlaying {
                play()
            }
        }
        
    }

}

// MARK: - Visual Actions

extension OverlayView {

    func changeImage(image: UIImage?) {
        playPauseButton.setImage(image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    }

    func show() {
        hidden = false
    }

    func hide() {
        hidden = true
    }

    func hideWithDelay(delay: Double) {

        self.delay = delay
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hide), object: nil)
        performSelector(#selector(hide), withObject: nil, afterDelay: delay)

    }

    func updateWaveformProgress(progress: Double) {

        waveformLayer.path = UIBezierPath(rect: CGRect(origin: .zero, size: CGSize(width: CGFloat(progress)*waveformLayerFrame.width, height: waveformLayerFrame.height))).CGPath
        
    }

}

// MARK: - Player Actions

extension OverlayView {

    func updatePlayer(player: AVPlayer) {

        self.player = player

    }

    func didPressPlayPause() {

        isPlaying ? pause() : play()

    }

    func play() {
        player?.play()
        changeImage(UIImage(assetIdentifier: .Pause))
        isPlaying = true
    }

    func pause() {
        player?.pause()
        changeImage(UIImage(assetIdentifier: .Play))
        isPlaying = false
    }

}
