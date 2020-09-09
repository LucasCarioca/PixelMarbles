//
//  GameScene.swift
//  StellarQuest
//
//  Created by Lucas Desouza on 9/1/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//
import CoreMotion
import SpriteKit

class GameScene: SKScene {
    var gameScore: GameScore?
    var gamePieces: GamePieceList?
    var motionManager: CMMotionManager?
    var matchedGamePieces = Set<GamePiece>()
    let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    let highScoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    let resetButton = Button(type: "reset")
    let hardButton = Button(type: "hard")
    let easyButton = Button(type: "easy")
    var bombed = false
    var starCount = 0
    var bombCount = 0
    var difficulty: Difficulty = DifficultyController.loadDifficulty()
    
    override func didMove(to view: SKView) {
        gameScore = GameScore(scene: self)
        gamePieces = GamePieceList(difficulty: difficulty)
        
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
        resetButton.position = CGPoint(x: frame.width - 40, y: 50)
        addChild(resetButton)
        
        hardButton.position = CGPoint(x: frame.width - 100, y: 70)
        addChild(hardButton)
        
        easyButton.position = CGPoint(x: frame.width - 100, y: 30)
        addChild(easyButton)
        
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPoint(x: 15, y: 70)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        highScoreLabel.fontSize = 20
        highScoreLabel.position = CGPoint(x: 15, y: 30)
        highScoreLabel.text = "HIGH SCORE: 0"
        highScoreLabel.zPosition = 100
        highScoreLabel.horizontalAlignmentMode = .left
        addChild(highScoreLabel)
        
        setup()
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)))
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    func setup() {
        starCount = 0
        bombCount = 0
        gameScore?.reset()
    
        for node in children {
            guard let ball = node as? GamePiece else { continue }
            ball.removeFromParent()
        }
        
        let exampleGamePiece = GamePiece(type: "ballBlue")
        let gamePieceRadius = exampleGamePiece.frame.width / 2.0
        
        for i in stride(from: gamePieceRadius, to: view?.bounds.width ?? 0 - gamePieceRadius, by: exampleGamePiece.frame.width){
            for j in stride(from: 100, to: view?.bounds.height ?? 0 - gamePieceRadius, by: exampleGamePiece.frame.height) {
                if gamePieces?.hasNextPiece() ?? false {
                    guard let type = gamePieces?.getNextPiece() else { continue }
                    let ball: GamePiece = getGamePiece(as: type)
                    ball.position = CGPoint(x: i, y: j)
                    addChild(ball)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager?.accelerometerData{
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 50, dy: accelerometerData.acceleration.y * 50)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let position = touches.first?.location(in: self) else { return }
        if let tappedPiece = nodes(at: position).first(where: { $0 is GamePiece}) as? GamePiece {
            gamePieceTapped(tappedPiece)
        } else if let button = nodes(at: position).first(where: { $0 is Button}) as? Button {
            buttonTapped(button)
        }
    }
    
    func buttonTapped(_ button: Button) {
        if button.name == "hard"{
            difficulty = DifficultyController.saveDifficulty(difficultyLevel: .hard)
            gamePieces?.changeDifficulty(to: difficulty)
        } else if button.name == "easy" {
            difficulty = DifficultyController.saveDifficulty(difficultyLevel: .easy)
            gamePieces?.changeDifficulty(to: difficulty)
        }
        gamePieces?.reset()
        setup()
    }
    
    func gamePieceTapped(_ tappedPiece: GamePiece) {
        matchedGamePieces.removeAll(keepingCapacity: true)
        bombed = false
        getMatches(from: tappedPiece)
        
        if matchedGamePieces.count >= 3 {
            if !bombed {
                gameScore?.addPoints(matches: matchedGamePieces.count)
            }
            for piece in matchedGamePieces {
                let particleType = bombed ? "bombExplosion" : "explosion"
                if let particles = SKEmitterNode(fileNamed: particleType) {
                    particles.position = piece.position
                    addChild(particles)
                    let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
                    particles.run(removeAfterDead)
                }
                piece.removeFromParent()
            }
        }
        
        if matchedGamePieces.count >= 5 && !bombed{
            let wow = SKSpriteNode(imageNamed: "wowx3")
            wow.position = CGPoint(x: frame.midX, y: frame.midY)
            wow.zPosition = 100
            wow.xScale = 0.001
            wow.yScale = 0.001
            addChild(wow)

            let appear = SKAction.group([SKAction.scale(to: 1.5, duration: 0.25), SKAction.fadeIn(withDuration: 0.25)])
            let disappear = SKAction.group([SKAction.scale(to: 2, duration: 0.25), SKAction.fadeOut(withDuration: 0.25)])
            let sequence = SKAction.sequence([appear, SKAction.wait(forDuration: 0.25), disappear, SKAction.removeFromParent()])
            wow.run(sequence)
        }
    }
    
    func getMatches(from startPiece: GamePiece, star: Bool = false) {
        
        for node in children {
            guard let gamePiece = node as? GamePiece else { continue }
            guard !matchedGamePieces.contains(gamePiece) else { continue }
            guard startPiece.isTouching(gamePiece) else { continue }
            if gamePiece.isBomb() {
                bombed = true
            }
            if (star || gamePiece.isMatch(to: startPiece) || !gamePiece.isBall()){
                    matchedGamePieces.insert(gamePiece)
                    getMatches(from: gamePiece, star: !gamePiece.isBall())
            }
        }
    }
}
