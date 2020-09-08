//
//  Difficulty.swift
//  StellarQuest
//
//  Created by Lucas Desouza on 9/6/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//

import Foundation

enum DifficultyLevel: String {
    case easy = "EASY"
    case hard = "HARD"
}


class DifficultyController {
    
    private static let DIFFICULTY_KEY = "DIFFICULTY"
    private static let DEFAULT_DIFFICULTY: Difficulty = .easy

    public static func setDifficulty(profile: Difficulty){
        let defaults = UserDefaults.standard
        defaults.set(profile, forKey: DIFFICULTY_KEY)
    }

    public static func getDifficulty() -> Difficulty {
        let defaults = UserDefaults.standard
        if let difficulty = defaults.object(forKey: DIFFICULTY_KEY) as? Difficulty{
            return difficulty
        }
        setDifficulty(profile: .easy)
        return .easy
    }

}

class Difficulty
