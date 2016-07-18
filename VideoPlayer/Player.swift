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
    private var player = AVPlayer()
    private var overlayLayer = CALayer()
    private var imageLayerFrame: CGRect {
        get {
            let width: CGFloat = 40.0
            let height: CGFloat = 44.0

            return CGRect(x: bounds.midX - width/2.0, y: bounds.midY - height/2.0, width: width, height: height)
        }
    }

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

    }

}

// MARK: - Private Setup

private extension Player {

    func setup() {
        setupPlayer()
        createOverlayView()
        addTouchObservers()
    }

    func createOverlayView() {

        overlayLayer.frame = bounds
        overlayLayer.contentsGravity = kCAGravityCenter
        overlayLayer.backgroundColor = UIColor.lightGrayColor().CGColor
        overlayLayer.opacity = 0.0

        layer.addSublayer(overlayLayer)

    }

    func setupPlayer() {

        avPlayerLayer.player = player
        avPlayerLayer.frame = bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        layer.addSublayer(avPlayerLayer)

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

        UIView.animateWithDuration(1.0,
                                   delay: 0.0, // ineffective as it is a layer animation and so it just goes
                                   options: .CurveEaseIn,
                                   animations: { [unowned self] in
                                    self.layoutIfNeeded()
            }, completion: nil)

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
