//
//  ButtonNode.swift
//  Project8
//
//  Created by Paul Hudson on 08/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit
import UIKit

class ButtonNode: SKSpriteNode {
    var focusedImage: SKTexture!
    var unfocusedImage: SKTexture!

    override var canBecomeFocused: Bool {
        return true
    }

    func setFocusedImage(named name: String) {
        focusedImage = SKTexture(imageNamed: name)
        unfocusedImage = self.texture!
        isUserInteractionEnabled = true
    }

    func didGainFocus() {
        texture = focusedImage
    }

    func didLoseFocus() {
        texture = unfocusedImage
    }
}
