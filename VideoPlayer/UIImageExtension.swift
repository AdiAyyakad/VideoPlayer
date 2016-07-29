//
//  UIImageExtension.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/29/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit

extension UIImage {

    enum AssetIdentifier: String {
        // Image Names of Minions
        case Play = "play"
        case Pause = "pause"
    }

    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}
