//
//  EnemyNode.swift
//  Project8
//
//  Created by Paul Hudson on 08/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit
import UIKit

enum EnemyWave {
    case smallSmall, mediumSmall, largeSmall, smallMedium, mediumMedium, largeMedium, smallLarge, mediumLarge, largeLarge, flurrySmall, flurryMedium, flurryLarge
}

class EnemyNode: SKSpriteNode {
    var weaponType = ""
    var lastFireTime: Double = 0

    init(type: String, startPosition: CGPoint, xOffset: CGFloat, moveStraight: Bool) {
        weaponType = "\(type)Weapon"
        let texture = SKTexture(imageNamed: type)
        super.init(texture: texture, color: .white, size: texture.size())

        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody?.categoryBitMask = CollisionTypes.enemy.rawValue
        physicsBody?.collisionBitMask = CollisionTypes.playerWeapon.rawValue | CollisionTypes.player.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.playerWeapon.rawValue | CollisionTypes.player.rawValue
        name = type
        position = CGPoint(x: startPosition.x + xOffset, y: startPosition.y)

        configureMovement(moveStraight)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configureMovement(_ moveStraight: Bool) {
        let path = UIBezierPath()
        path.move(to: .zero)

        if moveStraight {
            path.addLine(to: CGPoint(x: -10000, y: 0))
        } else {
            path.addCurve(to: CGPoint(x: -3500, y: 0), controlPoint1: CGPoint(x: 0, y: -position.y * 4), controlPoint2: CGPoint(x: -1000, y: -position.y))
        }

        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 600)
        let sequence = SKAction.sequence([movement, SKAction.removeFromParent()])
        run(sequence)
    }

    func fire() {
        let weapon = SKSpriteNode(imageNamed: weaponType)
        weapon.name = weaponType
        weapon.position = position
        weapon.zRotation = zRotation
        parent?.addChild(weapon)

        weapon.physicsBody = SKPhysicsBody(rectangleOf: weapon.size)
        weapon.physicsBody?.categoryBitMask = CollisionTypes.enemyWeapon.rawValue
        weapon.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        weapon.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue

        let speed: CGFloat = 20
        let adjustedRotation = zRotation + (CGFloat.pi / 2)
        let dx = speed * cos(adjustedRotation)
        let dy = speed * sin(adjustedRotation)
        weapon.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
    }
}
