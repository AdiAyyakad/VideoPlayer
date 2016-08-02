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

    var delay = 3.0 {
        didSet {
            overlayView.delay = delay
        }
    }

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

        overlayView.updatePlayer(player)
        setupPlayerLayer()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTouchOverlay(_:))))
        addSubview(overlayView)
    }

    func setupPlayerLayer() {

        avPlayerLayer.player = player
        avPlayerLayer.frame = bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        layer.addSublayer(avPlayerLayer)
        
    }

}

// MARK: - Public Setup

public extension PlayerView {

    func addContentURL(url: NSURL) {

        let item = AVPlayerItem(URL: url)
        player.replaceCurrentItemWithPlayerItem(item)
        overlayView.updateAsset(item.asset)

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

// MARK: - Private Animations

private extension PlayerView {

    /** Shows overlay or pans to specfic location if overlay is already visible */
    @objc func didTouchOverlay(recognizer: UITapGestureRecognizer) {

        overlayView.show()
        overlayView.hideWithDelay()

    }

}
