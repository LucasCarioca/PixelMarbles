//
//  Game.swift
//  PixelMarbles
//
//  Created by Lucas Desouza on 9/8/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//

import Foundation
import SpriteKit

class GameScore {
    private var scene: GameScene
    private var score = 0 {
        didSet {
            var highScoreObject = HighScoreController.getHighScore()
            if scene.difficulty.level == DifficultyLevel.easy.rawValue {
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
            self.scene.scoreLabel.text = "SCORE: \(formattedScore)"
        }
    }
    
    private var highScore = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: highScore as NSNumber) ?? "0"
            scene.highScoreLabel.text = "HIGH SCORE: \(formattedScore)"
        }
    }
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    public func getScore() -> Int {
        return score
    }
 
    public func addPoints(matches: Int) {
        self.score = score + Int(pow(2, Double(min(matches, 16))))
    }
    
    public func reset() {
        score = 0
        let highScoreObject = HighScoreController.getHighScore()
        if scene.difficulty.level == DifficultyLevel.easy.rawValue {
            highScore = highScoreObject.easy.score
        } else {
            highScore = highScoreObject.hard.score
        }
    }
}
