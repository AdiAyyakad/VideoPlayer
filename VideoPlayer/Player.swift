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
    private var playPauseImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
    private var textLabel = UILabel()

    private var textLabelFrame: CGRect {
        return CGRect(origin: .zero, size: CGSize(width: bounds.width, height: 75))
    }

    private var player = AVPlayer()
    private var isPlaying = false

    private let largeFont: UIFont = .systemFontOfSize(20)
    private let smallFont: UIFont = .systemFontOfSize(30)

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
        textLabel.frame = textLabelFrame

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
            self.textLabel.text = String(format: "%d:%02d", minutes, seconds)
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

        overlayView.frame = bounds
        overlayView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        overlayView.hidden = true

        setupImageView()
        setupTextLabel()

        addSubview(overlayView)

    }

    func setupImageView() {

        playPauseImageView.tintColor = .whiteColor()
        playPauseImageView.image = UIImage(assetIdentifier: .Play)?.imageWithRenderingMode(.AlwaysTemplate)

        playPauseImageView.center = CGPoint(x: overlayView.bounds.midX, y: overlayView.bounds.midY)
        playPauseImageView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressPlayPause))
        playPauseImageView.userInteractionEnabled = true
        playPauseImageView.addGestureRecognizer(tapGestureRecognizer)

        overlayView.addSubview(playPauseImageView)
        
    }

    func setupTextLabel() {

        textLabel.frame = textLabelFrame
        textLabel.textAlignment = .Center
        textLabel.font = smallFont
        textLabel.textColor = .whiteColor()

        overlayView.addSubview(textLabel)
        
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

        overlayView.hidden = false
        textLabel.font = largeFont

        delayOverlayDisappearance()

    }

    /** Makes overlay disappear */
    @objc func animateOverlayDisappearance() {

        overlayView.hidden = true
        textLabel.font = smallFont

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
        playPauseImageView.image = UIImage(assetIdentifier: .Pause)?.imageWithRenderingMode(.AlwaysTemplate)
        player.play()
    }

    func pause() {

        isPlaying = false
        playPauseImageView.image = UIImage(assetIdentifier: .Play)?.imageWithRenderingMode(.AlwaysTemplate)
        player.pause()

    }

}
