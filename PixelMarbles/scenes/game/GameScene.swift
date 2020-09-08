//
//  GameScene.swift
//  StellarQuest
//
//  Created by Lucas Desouza on 9/1/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//
import CoreMotion
import SpriteKit

class Ball: SKSpriteNode { }
class Button: SKSpriteNode { }

class GameScene: SKScene {
    var balls: GameBallList?
    var motionManager: CMMotionManager?
    var matchedBalls = Set<Ball>()
    let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    let highScoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    let resetButton = Button(imageNamed: "reset")
    let hardButton = Button(imageNamed: "hard")
    let easyButton = Button(imageNamed: "easy")
    var bombed = false
    var starCount = 0
    var bombCount = 0
    var score = 0 {
        didSet {
            var highScoreObject = HighScoreController.getHighScore()
            if DifficultyController.difficultyLevel(at: difficulty.level) == .easy {
                if score > highScoreObject.easy.score {
                    highScoreObject.easy.score = score
                    highScore = score
                }
            } else {
                if score > highScoreObject.hard.score {
                    highScoreObject.hard.score = score
                    highScore = score
                }
            }
            _ = HighScoreController.setHighScore(highScoreObject)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "SCORE: \(formattedScore)"
        }
    }
    var highScore = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: highScore as NSNumber) ?? "0"
            highScoreLabel.text = "HIGH SCORE: \(formattedScore)"
        }
    }

    var difficulty: Difficulty = DifficultyController.loadDifficulty()
    
    override func didMove(to view: SKView) {
        balls = GameBallList(difficulty: difficulty)
        
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
        resetButton.name = "reset"
        resetButton.position = CGPoint(x: frame.width - 40, y: 50)
        resetButton.zPosition = 100
        addChild(resetButton)
        
        hardButton.name = "hard"
        hardButton.position = CGPoint(x: frame.width - 100, y: 70)
        hardButton.zPosition = 100
        addChild(hardButton)
        
        easyButton.name = "easy"
        easyButton.position = CGPoint(x: frame.width - 100, y: 30)
        easyButton.zPosition = 100
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
        score = 0
        starCount = 0
        bombCount = 0
        let highScoreObject = HighScoreController.getHighScore()
        if DifficultyController.difficultyLevel(at: difficulty.level) == .easy {
            highScore = highScoreObject.easy.score
        } else {
            highScore = highScoreObject.hard.score
        }
        let ball = SKSpriteNode(imageNamed: "ballBlue")
        ball.xScale = 1.25
        ball.yScale = 1.25
        let ballRadius = ball.frame.width / 2.0
        for node in children {
            guard let ball = node as? Ball else { continue }
            ball.removeFromParent()
        }
        for i in stride(from: ballRadius, to: view?.bounds.width ?? 0 - ballRadius, by: ball.frame.width){
            for j in stride(from: 100, to: view?.bounds.height ?? 0 - ballRadius, by: ball.frame.height) {
                if balls?.hasNext() ?? false {
                    guard let ballType = balls?.getNextBall() else { continue }
                    let ball = Ball(imageNamed: ballType)
                    ball.xScale = 1.25
                    ball.yScale = 1.25
                    ball.position = CGPoint(x: i, y: j)
                    ball.name = ballType
                    
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
                    ball.physicsBody?.allowsRotation = false
                    ball.physicsBody?.restitution = 0
                    ball.physicsBody?.friction = 0
                    if ball.name == "bomb"{
                        if let particles = SKEmitterNode(fileNamed: "bombSmoke") {
                            ball.addChild(particles)
                        }
                    }
                    if ball.name == "starPink"{
                        if let particles = SKEmitterNode(fileNamed: "starSparkle") {
                            ball.addChild(particles)
                        }
                    }
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
        if let tappedBall = nodes(at: position).first(where: { $0 is Ball}) as? Ball {
            matchedBalls.removeAll(keepingCapacity: true)
            bombed = false
            
            getMatches(from: tappedBall)
            
            if matchedBalls.count >= 3 {
                if !bombed {
                    score += Int(pow(2, Double(min(matchedBalls.count, 16))))
                }
                for ball in matchedBalls {
                    var particleType = "explosion"
                    if bombed {
                        particleType = "bombExplosion"
                    }
                    if let particles = SKEmitterNode(fileNamed: particleType) {
                        particles.position = ball.position
                        addChild(particles)
                        let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
                        particles.run(removeAfterDead)
                    }
                    ball.removeFromParent()
                }
            }
            
            if matchedBalls.count >= 5 && !bombed{
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
        } else if let button = nodes(at: position).first(where: { $0 is Button}) as? Button {
            if button.name == "hard"{
                difficulty = DifficultyController.saveDifficulty(difficultyLevel: .hard)
                balls?.changeDifficulty(to: difficulty)
            } else if button.name == "easy" {
                difficulty = DifficultyController.saveDifficulty(difficultyLevel: .easy)
                balls?.changeDifficulty(to: difficulty)
            }
            balls?.reset()
            setup()
        }
    }
    
    func distance(from: Ball, to: Ball) -> CGFloat {
        return (from.position.x - to.position.x) * (from.position.x - to.position.x) + (from.position.y - to.position.y) * (from.position.y - to.position.y)
    }
    
    func getMatches(from startBall: Ball, star: Bool = false) {
        let matchWidth = startBall.frame.width * startBall.frame.width * 1.1
        if star {
            for node in children {
                guard let ball = node as? Ball else { continue }
                let dist = distance(from: startBall, to: ball)
                guard dist < matchWidth else { continue }
                if ball.name == "bomb" {
                    bombed = true
                }
                if !matchedBalls.contains(ball) {
                    matchedBalls.insert(ball)
                    getMatches(from: ball, star: (ball.name == "starPink" || ball.name == "bomb"))
                    
                }
            }
        } else {
            for node in children {
                guard let ball = node as? Ball else { continue }
                let dist = distance(from: startBall, to: ball)
                guard dist < matchWidth else { continue }
                if ball.name == "bomb" {
                    bombed = true
                }
                if ball.name == startBall.name || ball.name == "starPink" || ball.name == "bomb" {
                    if !matchedBalls.contains(ball) {
                        matchedBalls.insert(ball)
                        getMatches(from: ball, star: (ball.name == "starPink" || ball.name == "bomb"))
                    }
                }
            }
        }
    }
}
