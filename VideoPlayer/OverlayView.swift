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

    var isVisible: Bool { return !hidden }
    var isPlaying = false
    var font: UIFont = .systemFontOfSize(30)
    var delay: Double = 3.0

    private let panGestureRecognizer = UIPanGestureRecognizer()
    private let textLabel = UILabel()
    private let playPauseButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
    private var timerObserver: AnyObject?
    private var waveformObserver: AnyObject?

    private var textLabelFrame: CGRect {
        return CGRect(origin: CGPoint(x: 0, y: playPauseButton.frame.maxY+12), size: CGSize(width: bounds.width, height: 30))
    }
    private var waveformLayerFrame: CGRect {
        return CGRect(origin: textLabelFrame.origin, size: CGSize(width: bounds.width, height: 80))
    }

    // MARK: - Waveform Properties

    var fillColor: UIColor = .redColor()
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

    deinit {

        guard let timerObserver = timerObserver, waveformObserver = waveformObserver else {
            return
        }

        player?.removeTimeObserver(timerObserver)
        player?.removeTimeObserver(waveformObserver)

    }

}

// MARK: - Private Setup

private extension OverlayView {

    func setup() {

        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.1)
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

        playPauseButton.addTarget(self, action: #selector(didPressPlayPause), forControlEvents: .TouchUpInside)

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
        let percentMoved = clamp(item: Double(recognizer.locationInView(self).x/bounds.width), low: 0, high: 1)
        let seconds = percentMoved*length

        textLabel.text = String(format: "%d:%02d", Int(seconds)/60, Int(seconds)%60)
        updateWaveformProgress(CGFloat(percentMoved))

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

    func updateWaveformProgress(progress: CGFloat) {

        let path = UIBezierPath(rect: CGRect(origin: .zero, size: CGSize(width: progress*waveformLayerFrame.width, height: waveformLayerFrame.height)))
        waveformLayer.path = path.CGPath
        
    }

}

// MARK: - Player Actions

extension OverlayView {

    func updatePlayer(player: AVPlayer) {

        self.player = player

        timerObserver = player.addPeriodicTimeObserverForInterval(CMTime(seconds: 1.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { [unowned self] cmtime in
            let time = Int(CMTimeGetSeconds(cmtime))
            self.textLabel.text = String(format: "%d:%02d", time/60, time%60)
        }

        waveformObserver = player.addPeriodicTimeObserverForInterval(CMTime(seconds: 0.2, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { (cmtime) in
            guard let item = self.player?.currentItem else {
                return
            }

            self.updateWaveformProgress(CGFloat(CMTimeGetSeconds(cmtime)/CMTimeGetSeconds(item.duration)))
        }

    }

    func didPressPlayPause() {

        isPlaying ? pause() : play()
        hideWithDelay(delay)

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

// MARK: - Helper

extension OverlayView {

    func clamp(item item: Double, low: Double, high: Double) -> Double {

        if item < low {
            return low
        } else if item > high {
            return high
        } else {
            return item
        }
    }

}
