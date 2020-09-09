//
//  Difficulty.swift
//  StellarQuest
//
//  Created by Lucas Desouza on 9/6/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//

import Foundation

enum DifficultyLevel: Int {
    case easy = 3
    case medim = 2
    case hard = 1
}

struct Difficulty: Codable {
    var starCount: Int
    var bombCount: Int
    var level: Int
}

class DifficultyController {
    
    private static let DIFFICULTY_KEY = "DIFFICULTY"
    private static let DEFAULT_STAR_COUNT = 100

    public static func saveDifficulty(difficultyLevel: DifficultyLevel) -> Difficulty{
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(createDifficulty(difficultyLevel)){
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: DIFFICULTY_KEY)
        }
        return createDifficulty(difficultyLevel)
    }

    public static func loadDifficulty() -> Difficulty{
        let defaults = UserDefaults.standard
        if let difficulty = defaults.object(forKey: DIFFICULTY_KEY) as? Data{
            let decoder = JSONDecoder()
            if let loadedDifficulty = try? decoder.decode(Difficulty.self, from: difficulty){
                return loadedDifficulty
            }
        }
        return saveDifficulty(difficultyLevel: .easy)
    }
    
    public static func createDifficulty(_ difficultyLevel: DifficultyLevel) -> Difficulty {
        switch difficultyLevel {
        case .easy:
            return Difficulty(starCount: 10, bombCount: 0,  level: difficultyLevel.rawValue)
        case .hard:
            return Difficulty(starCount: 4, bombCount: 2, level: difficultyLevel.rawValue)
        default:
            return Difficulty(starCount: 10, bombCount: 0,  level: difficultyLevel.rawValue)
        }
    }
    
    public static func difficultyLevel(at level: Int) -> DifficultyLevel {
        switch level {
        case DifficultyLevel.easy.rawValue:
            return .easy
        case DifficultyLevel.hard.rawValue:
            return .hard
        default:
            return .easy
        }
    }
}
