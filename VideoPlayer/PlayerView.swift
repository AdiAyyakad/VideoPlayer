//
//  PlayerView.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/15/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit
import AVFoundation

public class PlayerView: UIView {

    private var player = AVPlayer()
    private var avPlayerLayer = AVPlayerLayer()
    private var overlayView = OverlayView()
    private var timerObserver: AnyObject?
    private var waveformObserver: AnyObject?

    private let delay = 3.0

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public convenience init(frame: CGRect, contentURL url: NSURL) {
        self.init(frame: frame)

        addContentURL(url)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    deinit {

        guard let timerObserver = timerObserver, waveformObserver = waveformObserver else {
            return
        }

        player.removeTimeObserver(timerObserver)
        player.removeTimeObserver(waveformObserver)

    }
}

// MARK: - Overrides

public extension PlayerView {

    override func layoutSubviews() {

        avPlayerLayer.frame = bounds
        overlayView.frame = bounds

    }

}

// MARK: - Private Setup

private extension PlayerView {

    func setup() {
        setupPlayer()
        setupPlayerLayer()
        setupOverlayView()
        addTouchObservers()
    }

    func setupPlayer() {

        timerObserver = player.addPeriodicTimeObserverForInterval(CMTime(seconds: 1.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { [unowned self] cmtime in
            let time = Int(CMTimeGetSeconds(cmtime))
            self.overlayView.textLabel.text = String(format: "%d:%02d", time/60, time%60)
        }

        waveformObserver = player.addPeriodicTimeObserverForInterval(CMTime(seconds: 0.2, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { (cmtime) in
            guard let item = self.player.currentItem else {
                return
            }

            self.overlayView.updateWaveformProgress(CMTimeGetSeconds(cmtime)/CMTimeGetSeconds(item.duration))
        }

        overlayView.updatePlayer(player)

    }

    func setupPlayerLayer() {

        avPlayerLayer.player = player
        avPlayerLayer.frame = bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        layer.addSublayer(avPlayerLayer)
        
    }

    func addTouchObservers() {

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTouchOverlay(_:))))

    }

    func setupOverlayView() {

        overlayView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        overlayView.hide()
        overlayView.playPauseButton.addTarget(self, action: #selector(didPressPlayPause), forControlEvents: .TouchUpInside)

        addSubview(overlayView)

    }

}

// MARK: - Public Setup

public extension PlayerView {

    func addContentURL(url: NSURL) {

        player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: url))

    }

}

// MARK: - Public actions

public extension PlayerView {

    func play() {
        overlayView.play()
    }

    func pause() {
        overlayView.pause()
    }

}

// MARK: - Private actions

private extension PlayerView {

    /** Plays or pauses the video, depending on the current state */
    @objc func didPressPlayPause() {

        overlayView.didPressPlayPause()
        overlayView.hideWithDelay(delay)

    }

}

// MARK: - Private Animations

private extension PlayerView {

    /** Shows overlay or pans to specfic location if overlay is already visible */
    @objc func didTouchOverlay(recognizer: UIGestureRecognizer) {

        overlayView.isVisible ? overlayView.handlePanGesture(recognizer) : overlayView.show()
        overlayView.hideWithDelay(delay)

    }

}
