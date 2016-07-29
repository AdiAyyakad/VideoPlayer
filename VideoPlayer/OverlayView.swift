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

    var isVisible: Bool {
        return !hidden
    }

    var isPlaying = false
    let textLabel = UILabel()
    let waveformView = WaveformView()
    let playPauseButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))

    private let waveformHeight: CGFloat = 80
    private let font: UIFont = .systemFontOfSize(30)
    private let panGestureRecognizer = UIPanGestureRecognizer()

    private var textLabelFrame: CGRect {
        return CGRect(origin: .zero, size: CGSize(width: bounds.width, height: waveformHeight/2))
    }
    private var waveformFrame: CGRect {
        return CGRect(x: 0, y: bounds.maxY-waveformHeight, width: bounds.width, height: waveformHeight)
    }

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

}

// MARK: - Private Setup

private extension OverlayView {

    func setup() {

        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        hidden = true

        setupPlayPauseButton()
        setupTextLabel()
        setupWaveformView()

    }

    func setupPlayPauseButton() {

        playPauseButton.tintColor = .whiteColor()
        changeImage(UIImage(assetIdentifier: .Play))

        playPauseButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
        playPauseButton.contentMode = .Center
        playPauseButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        playPauseButton.userInteractionEnabled = true

        addSubview(playPauseButton)

    }

    func setupTextLabel() {

        textLabel.font = font
        textLabel.textAlignment = .Center
        textLabel.textColor = .whiteColor()
        textLabel.frame = textLabelFrame
        
        addSubview(textLabel)

    }

    func setupWaveformView() {

        waveformView.frame = waveformFrame
        addSubview(waveformView)

        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)
        
    }

}

// MARK: - Gesture Recognizers

extension OverlayView {

    @objc func handlePanGesture(recognizer: UIGestureRecognizer) {

        print(recognizer.locationInView(self))

        guard let item = waveformView.player?.currentItem else {
            return
        }

        if isPlaying {
            pause()
        }

        let length = CMTimeGetSeconds(item.duration)
        let percentMoved = Double(recognizer.locationInView(self).x/bounds.width)

        var seconds = percentMoved*length

        if seconds < 0 {
            seconds = 0
        } else if seconds > length {
            seconds = length
        }

        textLabel.text = String(format: "%d:%02d", Int(seconds)/60, Int(seconds)%60)
        waveformView.updateProgress(percentMoved)

        waveformView.player?.seekToTime(CMTime(seconds: seconds, preferredTimescale: Int32(NSEC_PER_SEC)))

        if recognizer.state == .Ended {
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

}

// MARK: - Player Actions

extension OverlayView {

    func updatePlayer(player: AVPlayer) {
        waveformView.player = player
    }

    func didPressPlayPause() {

        isPlaying ? pause() : play()

    }

    func play() {
        waveformView.player?.play()
        changeImage(UIImage(assetIdentifier: .Pause))
        isPlaying = true
    }

    func pause() {
        waveformView.player?.pause()
        changeImage(UIImage(assetIdentifier: .Play))
        isPlaying = false
    }

}
