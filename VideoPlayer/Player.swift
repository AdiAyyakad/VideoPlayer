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

    private var scrubberView = UIScrollView()
    private var avPlayerLayer = AVPlayerLayer()
    private var overlayLayer = CALayer()
    private var textLayer = CATextLayer()

    private var scrubberViewFrame: CGRect {
        get {
            return CGRect(x: 0, y: bounds.midY + scrubberHeight, width: bounds.width, height: scrubberHeight)
        }
    }
    private var textLayerFrame: CGRect {
        get {
            return CGRect(origin: scrubberViewFrame.origin, size: CGSize(width: bounds.width, height: scrubberViewFrame.height))
        }
    }

    private var player = AVPlayer()

    private var isPlaying = false {
        didSet {
            overlayLayer.contents = UIImage(named: isPlaying ? "pause" : "play")?.CGImage
        }
    }
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

    public override func layoutSubviews() {

        avPlayerLayer.frame = bounds
        overlayLayer.frame = bounds
        scrubberView.frame = scrubberViewFrame
        textLayer.frame = textLayerFrame

    }

}

// MARK: - Private Setup

private extension Player {

    func setup() {
        setupPlayer()
        setupPlayerLayer()
        setupOverlayLayer()
        setupScrubberView()
        setupTextLayer()
        addTouchObservers()
    }

    func setupPlayer() {
        player.addPeriodicTimeObserverForInterval(CMTime(seconds: 1.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { [unowned self] cmtime in
            let time = Int(CMTimeGetSeconds(cmtime))
            let minutes = time/60
            let seconds = time%60
            self.textLayer.string = NSString(format: "%d:%02d", minutes, seconds) as String
            self.textLayer.layoutIfNeeded()
        }
    }

    func setupPlayerLayer() {

        avPlayerLayer.player = player
        avPlayerLayer.frame = bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        layer.addSublayer(avPlayerLayer)
        
    }

    func setupScrubberView() {

        scrubberView.frame = scrubberViewFrame
        scrubberView.backgroundColor = .clearColor()
        scrubberView.alwaysBounceHorizontal = true

        addSubview(scrubberView)

    }

    func setupTextLayer() {

        textLayer.frame = textLayerFrame
        textLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.font = UIFont(name: "Helvetica", size: 8)

        layer.addSublayer(textLayer)

    }

    func setupOverlayLayer() {

        overlayLayer.frame = bounds
        overlayLayer.contentsGravity = kCAGravityCenter
        overlayLayer.backgroundColor = UIColor.lightGrayColor().CGColor
        overlayLayer.opacity = 0.0

        layer.addSublayer(overlayLayer)

    }

    func addTouchObservers() {

        addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(didTapOverlay)) )
        
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

    // Executes play/pause
    @objc func didTapOverlay() {

        isPlaying ? pause() : play()
        isOverlayVisible = !isOverlayVisible

        if !isOverlayVisible {
            // Delay overlay disppear for 2 seconds
            performSelector(#selector(animateOverlay), withObject: nil, afterDelay: 2.0)
        } else {
            // Do no delay to make overlay appear
            animateOverlay()
        }

    }

}

// MARK: - Private Animations

private extension Player {

    @objc func animateOverlay() {

        overlayLayer.opacity = isOverlayVisible ? 0.5 : 0.0

        layoutIfNeeded()

    }

}

// MARK: - Public Actions

public extension Player {

    func play() {

        if player.currentTime() == player.currentItem?.duration {
            player.seekToTime(CMTime(seconds: 0, preferredTimescale: 1))
        }

        isPlaying = true
        player.play()
    }

    func pause() {
        isPlaying = false
        player.pause()
    }

}