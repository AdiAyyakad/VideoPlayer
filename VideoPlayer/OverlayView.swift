//
//  OverlayView.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/29/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit
import AVFoundation
import SCWaveformView

class OverlayView: UIView {

    // MARK: - Overlay Properties

    var isVisible: Bool { return !hidden }
    var isPlaying = false
    var font: UIFont = .systemFontOfSize(30)
    var delay: Double = 3.0

    private let textLabel = UILabel()
    private let playPauseButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
    private var timerObserver: AnyObject?
    private var waveformObserver: AnyObject?
    private var relativeStartTime: CMTime? = nil

    private var textLabelFrame: CGRect {
        return CGRect(origin: CGPoint(x: 0, y: playPauseButton.frame.maxY+12), size: CGSize(width: bounds.width, height: 30))
    }
    private var waveformFrame: CGRect {
        return CGRect(x: 0, y: textLabelFrame.maxY, width: bounds.width, height: 80)
    }

    // MARK: - Waveform Properties

    var progressColor: UIColor = .redColor()
    private var waveformView = SCWaveformView()
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
        waveformView.frame = waveformFrame

    }

    deinit {

        if let timerObserver = timerObserver {
            player?.removeTimeObserver(timerObserver)
        }

        if let waveformObserver = waveformObserver {
            player?.removeTimeObserver(waveformObserver)
        }

    }

}

// MARK: - Private Setup

private extension OverlayView {

    func setup() {

        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
        hide()

        setupPlayPauseButton()
        setupWaveformView()
        setupTextLabel()
        setupGestureRecognizers()

    }

    func setupPlayPauseButton() {

        playPauseButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
        playPauseButton.contentMode = .Center
        playPauseButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]

        playPauseButton.tintColor = .whiteColor()
        changeImage(UIImage(assetIdentifier: .Play))
        playPauseButton.userInteractionEnabled = true

        addSubview(playPauseButton)

        playPauseButton.addTarget(self, action: #selector(didPressPlayPause), forControlEvents: .TouchUpInside)

    }

    func setupTextLabel() {

        textLabel.font = font
        textLabel.textAlignment = .Center
        textLabel.textColor = .whiteColor()

        addSubview(textLabel)

    }

    func setupWaveformView() {

        waveformView.lineWidthRatio = 0.5
        waveformView.normalColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        waveformView.progressColor = progressColor.colorWithAlphaComponent(0.5)

        addSubview(waveformView)
        
    }

    func setupGestureRecognizers() {

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)

    }

}

// MARK: - Gesture Recognizers

extension OverlayView {

    func handlePanGesture(recognizer: UIPanGestureRecognizer) {

        guard let item = player?.currentItem else {
            return
        }

        // set the relative time if not already set
        if relativeStartTime == nil {
            relativeStartTime = item.currentTime()
        }

        guard let panStartTime = relativeStartTime else {
            return
        }

        // Deal with the first ever instance of panning
        if isPlaying {
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hide), object: nil)
            pause()
        }

        let length = CMTimeGetSeconds(item.duration)
        let percentTranslated = Double(recognizer.translationInView(self).x/bounds.width)
        let seconds = clamp(item: percentTranslated*length + CMTimeGetSeconds(panStartTime), low: 0, high: length)

        // Update views with the seconds
        textLabel.text = String(format: "%d:%02d", Int(seconds)/60, Int(seconds)%60)
        updateWaveformProgress(CMTime(seconds: seconds, preferredTimescale: Int32(NSEC_PER_SEC)))

        player?.seekToTime(CMTime(seconds: seconds, preferredTimescale: Int32(NSEC_PER_SEC)))

        // Deal with if the panning has ended
        if recognizer.state == .Ended {
            relativeStartTime = nil
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

    func hideWithDelay() {

        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hide), object: nil)
        performSelector(#selector(hide), withObject: nil, afterDelay: delay)

    }

    func updateWaveformProgress(progressTime: CMTime) {

        waveformView.progressTime = progressTime

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

            self.updateWaveformProgress(cmtime)
        }

    }

    func updateAsset(asset: AVAsset) {

        waveformView.asset = asset
        waveformView.timeRange = CMTimeRange(start: kCMTimeZero, duration: asset.duration)
        setNeedsDisplay()

    }

    func didPressPlayPause() {

        isPlaying ? pause() : play()
        hideWithDelay()

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

// MARK: - Helpers

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
