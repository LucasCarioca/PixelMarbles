//
//  HighScore.swift
//  StellarQuest
//
//  Created by Lucas Desouza on 9/6/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//

import Foundation

struct Score: Codable {
    var score: Int
    var name: String
}

struct HighScore: Codable {
    var hard: Score
    var easy: Score
}

class HighScoreController {
    private static let KEY = "HIGH_SCORE"
    
    public static func setHighScore(_ score: HighScore) -> HighScore{
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(score){
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: KEY)
        }
        return score
    }
    
    public static func getHighScore() -> HighScore {
        let defaults = UserDefaults.standard
        if let highScore = defaults.object(forKey: KEY) as? Data{
            let decoder = JSONDecoder()
            if let loadedHighScore = try? decoder.decode(HighScore.self, from: highScore){
                return loadedHighScore
            }
        }
        return setHighScore(HighScore(hard: Score(score: 0, name: ""), easy: Score(score: 0, name: "")))
    }
}


