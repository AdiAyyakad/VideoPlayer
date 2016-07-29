//
//  Player.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/15/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit
import AVFoundation

public class Player: UIView {

    private var avPlayerLayer = AVPlayerLayer()
    private var overlayView = OverlayView()
    private var player = AVPlayer()

    private var isPlaying = false

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
        addTouchObservers()
    }

    func setupPlayer() {

        player.addPeriodicTimeObserverForInterval(CMTime(seconds: 1.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { [unowned self] cmtime in
            let time = Int(CMTimeGetSeconds(cmtime))
            let minutes = time/60
            let seconds = time%60
            self.overlayView.textLabel.text = String(format: "%d:%02d", minutes, seconds)
        }

    }

    func setupPlayerLayer() {

        avPlayerLayer.player = player
        avPlayerLayer.frame = bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        layer.addSublayer(avPlayerLayer)
        
    }

    func addTouchObservers() {

        addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(didTapOverlay)) )

    }
}

// MARK: - Private Overlay Setup

private extension Player {

    func setupOverlayView() {

        overlayView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        overlayView.hide()
        overlayView.playPauseButton.addTarget(self, action: #selector(didPressPlayPause), forControlEvents: .TouchUpInside)

        addSubview(overlayView)

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

    /** Makes overlay visible, then invisible automatically after 3 seconds */
    @objc func didTapOverlay() {

        animateOverlay()

    }

    /** Plays or pauses the video, depending on the current state */
    @objc func didPressPlayPause() {

        isPlaying ? pause() : play()
        delayOverlayDisappearance()

    }

}

// MARK: - Private Animations

private extension Player {

    /** Shows overlay */
    func animateOverlay() {

        overlayView.show()
        delayOverlayDisappearance()

    }

    /** Makes overlay disappear */
    @objc func animateOverlayDisappearance() {

        overlayView.hide()

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
