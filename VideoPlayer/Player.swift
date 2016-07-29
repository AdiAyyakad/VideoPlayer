//
//  Player.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/15/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit
import AVFoundation
import FDWaveformView

public class Player: UIView {

    private var avPlayerLayer = AVPlayerLayer()
    private var overlayView = OverlayView()
    private var player = AVPlayer()
    private var waveformView = WaveformView()

    private var isPlaying = false
    private let panGestureRecognizer = UIPanGestureRecognizer()

    private let waveformHeight: CGFloat = 40
    private var waveformFrame: CGRect {
        return CGRect(x: 0, y: bounds.maxY-waveformHeight, width: bounds.width, height: waveformHeight)
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public convenience init(frame: CGRect, contentURL url: NSURL) {
        self.init(frame: frame)

        setupContentURL(url)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }
}

// MARK: - Overrides

public extension Player {

    override func layoutSubviews() {

        avPlayerLayer.frame = bounds
        overlayView.frame = bounds

    }

}

// MARK: - Private Setup

private extension Player {

    func setup() {
        setupPlayer()
        setupPlayerLayer()
        setupOverlayView()
        setupWaveformView()
        addTouchObservers()
    }

    func setupPlayer() {

        player.addPeriodicTimeObserverForInterval(CMTime(seconds: 1.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { [unowned self] cmtime in
            let time = Int(CMTimeGetSeconds(cmtime))
            self.overlayView.textLabel.text = String(format: "%d:%02d", time/60, time%60)

            guard let item = self.player.currentItem else {
                return
            }

            self.waveformView.updateProgress(CMTimeGetSeconds(cmtime)/CMTimeGetSeconds(item.duration))
        }

    }

    func setupPlayerLayer() {

        avPlayerLayer.player = player
        avPlayerLayer.frame = bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        layer.addSublayer(avPlayerLayer)
        
    }

    func addTouchObservers() {

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTouchOverlay(_:))))

        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.enabled = false
        addGestureRecognizer(panGestureRecognizer)

    }

    func setupOverlayView() {

        overlayView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        overlayView.hide()
        overlayView.playPauseButton.addTarget(self, action: #selector(didPressPlayPause), forControlEvents: .TouchUpInside)

        addSubview(overlayView)

    }

    func setupWaveformView() {

        waveformView.frame = waveformFrame
        overlayView.addSubview(waveformView)

    }

}

// MARK: - Public Setup

public extension Player {

    func setupContentURL(url: NSURL) {

        player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: url))

    }

}

// MARK: - Private actions

private extension Player {

    /** Plays or pauses the video, depending on the current state */
    @objc func didPressPlayPause() {

        isPlaying ? pause() : play()
        delayOverlayDisappearance()

    }

    @objc func handlePanGesture(recognizer: UIGestureRecognizer) {

        guard let item = player.currentItem else {
            return
        }

        if isPlaying {
            pause()
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(animateOverlayDisappearance), object: nil)
        }

        let length = CMTimeGetSeconds(item.duration)
        let percentMoved = Double(recognizer.locationInView(self).x/bounds.width)

        var seconds = percentMoved*length

        if seconds < 0 {
            seconds = 0
        } else if seconds > length {
            seconds = length
        }
        overlayView.textLabel.text = String(format: "%d:%02d", Int(seconds)/60, Int(seconds)%60)
        waveformView.updateProgress(percentMoved)

        player.seekToTime(CMTime(seconds: seconds, preferredTimescale: Int32(NSEC_PER_SEC)))

        if recognizer.state == .Ended {
            if !isPlaying {
                play()
            }

            performSelector(#selector(animateOverlayDisappearance), withObject: nil, afterDelay: 3.0)
        }

    }

}

// MARK: - Private Animations

private extension Player {

    /** Shows overlay or pans to specfic location if overlay is already visible */
    @objc func didTouchOverlay(recognizer: UIGestureRecognizer) {

        if overlayView.isVisible {
            handlePanGesture(recognizer)
        } else {
            overlayView.show()
            panGestureRecognizer.enabled = true

            delayOverlayDisappearance()
        }

    }

    /** Makes overlay disappear */
    @objc func animateOverlayDisappearance() {

        overlayView.hide()
        panGestureRecognizer.enabled = false

    }

    /** Makes overlay disappear after 3 seconds. Resets timer if overlay was told to disappear previously */
    func delayOverlayDisappearance() {

        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(animateOverlayDisappearance), object: nil)
        performSelector(#selector(animateOverlayDisappearance), withObject: nil, afterDelay: 3.0)

    }

}

// MARK: - Public Actions

public extension Player {

    func play() {

        if player.currentTime() == player.currentItem?.duration {
            player.seekToTime(CMTime(seconds: 0, preferredTimescale: 1))
        }

        isPlaying = true
        overlayView.changeImage(UIImage(assetIdentifier: .Pause))
        player.play()
    }

    func pause() {

        isPlaying = false
        overlayView.changeImage(UIImage(assetIdentifier: .Play))
        player.pause()

    }

}
