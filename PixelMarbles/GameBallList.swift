//
//  GameBallList.swift
//  StellarQuest
//
//  Created by Lucas Desouza on 9/6/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//

import Foundation

class GameBallList {
    var list: [String]
    var difficulty: Difficulty
    static let balls = ["ballBlue", "ballGreen", "ballPurple", "ballRed", "ballYellow"]
    
    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        self.list = GameBallList.generateList(difficulty)
    }
    
    static func generateList(_ difficulty: Difficulty) -> [String] {
        var newList: [String] = []
        for _ in 0..<difficulty.bombCount {
            newList.append("bomb")
        }
        for _ in 0..<difficulty.starCount {
            newList.append("starPink")
        }
        for _ in 0..<200 {
            newList.append(balls.randomElement()!)
        }
        return newList
    }
    
    func reset() {
        self.list = GameBallList.generateList(difficulty)
    }
    
    func changeDifficulty(to difficulty: Difficulty) {
        self.difficulty = difficulty
        self.list = GameBallList.generateList(difficulty)
    }
    
    func hasNext() -> Bool {
        return list.count >= 1
    }
    
    func getNextBall() -> String {
        list.shuffle()
        return list.removeLast()
    }
}
