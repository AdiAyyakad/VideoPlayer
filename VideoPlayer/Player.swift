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

    public var scrubberHeight: CGFloat = 75.0

    private var playPauseImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
    private var avPlayerLayer = AVPlayerLayer()
    private var overlayView = OverlayView()
    private var textLabel = UILabel()

    private var scrubberViewFrame: CGRect {
        return CGRect(x: 0, y: bounds.midY + scrubberHeight, width: bounds.width, height: scrubberHeight)
    }
    private var textLabelFrame: CGRect {
        return CGRect(origin: scrubberViewFrame.origin, size: CGSize(width: bounds.width, height: scrubberViewFrame.height))
    }

    private var player = AVPlayer()

    private var isPlaying = false
    private var isOverlayVisible = false

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
        setupTextLabel()
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

    func setupTextLabel() {

        textLabel.frame = textLabelFrame
        textLabel.textAlignment = .Center
        textLabel.font = .systemFontOfSize(20)
        textLabel.textColor = .whiteColor()

        addSubview(textLabel)

    }

    func setupOverlayView() {

        overlayView.frame = bounds
        overlayView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        overlayView.hidden = true

        setupImageView()

        addSubview(overlayView)

    }

    func setupImageView() {

        playPauseImageView.tintColor = .whiteColor()
        getImage()

        playPauseImageView.center = CGPoint(x: overlayView.bounds.midX, y: overlayView.bounds.midY)
        playPauseImageView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        playPauseImageView.hidden = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressPlayPause))
        playPauseImageView.userInteractionEnabled = true
        playPauseImageView.addGestureRecognizer(tapGestureRecognizer)

        addSubview(playPauseImageView)
        
    }

    func addTouchObservers() {

        addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(didTapOverlay)) )
        
    }

    func getImage() {

        playPauseImageView.image = UIImage(assetIdentifier: isPlaying ? .Pause : .Play)?.imageWithRenderingMode(.AlwaysTemplate)

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

    /**
     Makes overlay visible, then invisible automatically after 3 seconds
     */
    @objc func didTapOverlay() {

        isOverlayVisible = true
        animateOverlay()
        animateOverlayDisappearance()

    }

    /**
     Plays or pauses the video, depending on the current state
    */
    @objc func didPressPlayPause() {
        isPlaying ? pause() : play()
        animateOverlayDisappearance()
    }

}

// MARK: - Private Animations

private extension Player {

    @objc func animateOverlay() {

        playPauseImageView.hidden = isOverlayVisible
        overlayView.hidden = !isOverlayVisible
        playPauseImageView.hidden = !isOverlayVisible
        isOverlayVisible = false

    }

    func animateOverlayDisappearance() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(animateOverlay), object: nil)
        performSelector(#selector(animateOverlay), withObject: nil, afterDelay: 3.0)
    }

}

// MARK: - Public Actions

public extension Player {

    func play() {

        if player.currentTime() == player.currentItem?.duration {
            player.seekToTime(CMTime(seconds: 0, preferredTimescale: 1))
        }

        isPlaying = true
        getImage()
        player.play()
    }

    func pause() {

        isPlaying = false
        getImage()
        player.pause()

    }

}
