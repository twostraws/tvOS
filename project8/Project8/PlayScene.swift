//
//  PlayScene.swift
//  Project8
//
//  Created by Paul Hudson on 08/05/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit
import UIKit

enum CollisionTypes: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}

class PlayScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "player")

    let levelWaves: [EnemyWave] = [.smallSmall, .mediumSmall, .smallSmall, .largeSmall, .flurrySmall, .smallMedium, .mediumMedium, .largeMedium, .largeSmall, .mediumMedium, .smallLarge, .largeSmall, .largeLarge]
    var levelPosition = 0
    var playerIsAlive = true

    let enemyOffsetX: CGFloat = 100
    static let enemyStartX = 1100

    let positions = [
        CGPoint(x: enemyStartX, y: 400),
        CGPoint(x: enemyStartX, y: 300),
        CGPoint(x: enemyStartX, y: 200),
        CGPoint(x: enemyStartX, y: 100),
        CGPoint(x: enemyStartX, y: 0),
        CGPoint(x: enemyStartX, y: -100),
        CGPoint(x: enemyStartX, y: -200),
        CGPoint(x: enemyStartX, y: -300),
        CGPoint(x: enemyStartX, y: -400)
    ]

    let music = SKAudioNode(fileNamed: "cyborgNinja.mp3")
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        addChild(music)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -2
        background.blendMode = .replace
        addChild(background)

        if let particles = SKEmitterNode(fileNamed: "starfield") {
            particles.position = CGPoint(x: 1080, y: 0)
            particles.advanceSimulationTime(60)
            addChild(particles)
        }

        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.enemy.rawValue | CollisionTypes.enemyWeapon.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.enemy.rawValue | CollisionTypes.enemyWeapon.rawValue
        player.name = "player"
        player.position.x = -700
        player.zPosition = 1
        addChild(player)

        scoreLabel.position = CGPoint(x: 0, y: 400)
        scoreLabel.fontSize = 96
        scoreLabel.zPosition = -1
        addChild(scoreLabel)

        score = 0
    }

    func movePlayer(_ delta: CGPoint) {
        player.position.y -= delta.y * 2

        if player.position.y < -500 {
            player.position.y = -500
        } else if player.position.y > 500 {
            player.position.y = 500
        }
    }

    func createWave() {
        guard playerIsAlive else { return }
        guard levelPosition < levelWaves.count else { return }

        switch levelWaves[levelPosition] {
        case .smallSmall:
            addChild(EnemyNode(type: "enemy1", startPosition: positions[0], xOffset: enemyOffsetX * 2, moveStraight: true))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[4], xOffset: 0, moveStraight: true))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[8], xOffset: enemyOffsetX * 2, moveStraight: true))

        case .mediumSmall:
            addChild(EnemyNode(type: "enemy1", startPosition: positions[2], xOffset: 0, moveStraight: false))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[1], xOffset: enemyOffsetX * 2, moveStraight: false))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[0], xOffset: enemyOffsetX * 4, moveStraight: false))

            addChild(EnemyNode(type: "enemy1", startPosition: positions[6], xOffset: enemyOffsetX, moveStraight: false))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[7], xOffset: enemyOffsetX * 3, moveStraight: false))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[8], xOffset: enemyOffsetX * 5, moveStraight: false))

        case .largeSmall:
            addChild(EnemyNode(type: "enemy1", startPosition: positions[4], xOffset: 0, moveStraight: true))

            addChild(EnemyNode(type: "enemy1", startPosition: positions[3], xOffset: enemyOffsetX, moveStraight: true))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[2], xOffset: enemyOffsetX * 2, moveStraight: true))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[1], xOffset: enemyOffsetX * 3, moveStraight: true))

            addChild(EnemyNode(type: "enemy1", startPosition: positions[5], xOffset: enemyOffsetX, moveStraight: true))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[6], xOffset: enemyOffsetX * 2, moveStraight: true))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[7], xOffset: enemyOffsetX * 3, moveStraight: true))

            addChild(EnemyNode(type: "enemy1", startPosition: positions[2], xOffset: enemyOffsetX * 8, moveStraight: false))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[1], xOffset: enemyOffsetX * 8, moveStraight: false))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[0], xOffset: enemyOffsetX * 8, moveStraight: false))

            addChild(EnemyNode(type: "enemy1", startPosition: positions[6], xOffset: enemyOffsetX * 9, moveStraight: false))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[7], xOffset: enemyOffsetX * 9, moveStraight: false))
            addChild(EnemyNode(type: "enemy1", startPosition: positions[8], xOffset: enemyOffsetX * 9, moveStraight: false))

        default:
            let randomPositions = positions.shuffled()

            for (index, position) in randomPositions.enumerated() {
                addChild(EnemyNode(type: "enemy1", startPosition: position, xOffset: enemyOffsetX * CGFloat(index * 3), moveStraight: true))
            }
        }
        
        levelPosition += 1
    }

    override func update(_ currentTime: TimeInterval) {
        for child in children {
            if child.frame.maxX < 0 {
                if !frame.intersects(child.frame) {
                    child.removeFromParent()
                }
            }
        }

        let enemies = children.compactMap { $0 as? EnemyNode }

        if enemies.isEmpty {
            createWave()
        }

        for enemy in enemies {
            if enemy.lastFireTime + 1 < currentTime {
                enemy.lastFireTime = currentTime

                if Bool.random() {
                    enemy.fire()
                }
            }
        }
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard playerIsAlive else { return }
        guard let press = presses.first else { return }

        if press.type == .playPause {
            let shot = SKSpriteNode(imageNamed: "playerWeapon")
            shot.name = "playerWeapon"
            shot.position = player.position
            shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
            shot.physicsBody?.categoryBitMask = CollisionTypes.playerWeapon.rawValue
            shot.physicsBody?.contactTestBitMask = CollisionTypes.enemy.rawValue
            shot.physicsBody?.collisionBitMask = CollisionTypes.enemy.rawValue
            addChild(shot)

            let movement = SKAction.move(to: CGPoint(x: 1900, y: shot.position.y), duration: 1)
            let sequence = SKAction.sequence([movement, SKAction.removeFromParent()])
            shot.run(sequence)
            score -= 1

            run(SKAction.playSoundFileNamed("playerWeapon.wav", waitForCompletion: false))
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA.name == "player" || nodeB.name == "player" {
            guard playerIsAlive else { return }
            gameOver()
        } else {
            if let explosion = SKEmitterNode(fileNamed: "explosion") {
                if nodeA.name == "playerWeapon" {
                    explosion.position = nodeB.position
                } else {
                    explosion.position = nodeA.position
                }

                run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
                addChild(explosion)
                score += 10
            }
        }

        nodeA.removeFromParent()
        nodeB.removeFromParent()
    }

    func gameOver() {
        playerIsAlive = false

        if let explosion = SKEmitterNode(fileNamed: "explosion") {
            explosion.position = player.position
            addChild(explosion)
        }

        run(SKAction.playSoundFileNamed("gameOver.wav", waitForCompletion: false))
        music.run(SKAction.stop())
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        addChild(gameOver)
    }

    func quitGame() {
        let menu = GameScene(size: size)
        menu.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let transition = SKTransition.doorsCloseVertical(withDuration: 1)
        view?.presentScene(menu, transition: transition)

        menu.run(SKAction.wait(forDuration: 0.1)) {
            menu.view?.window?.rootViewController?.setNeedsFocusUpdate()
        }
    }
}
