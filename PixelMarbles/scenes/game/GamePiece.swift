//
//  GamePiece.swift
//  PixelMarbles
//
//  Created by Lucas Desouza on 9/8/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//

import Foundation
import SpriteKit

class GamePiece: SKSpriteNode {
    
    init(type: String) {
        let texture = SKTexture(imageNamed: type)
        super.init(texture: texture, color: .white, size: texture.size())
        self.xScale = 1.25
        self.yScale = 1.25
        let radius = self.frame.width / 2.0
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0
        self.name = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func isMatch(to piece: GamePiece) -> Bool {
        self.name == piece.name
    }
    
    public func isStar() -> Bool {
        self.name == "starPink"
    }
    
    public func isBomb() -> Bool {
        self.name == "bomb"
    }
    
    public func isBall() -> Bool {
        !(isStar() || isBomb())
    }
    
    public func isTouching(_ piece: GamePiece) -> Bool {
        let matchWidth = self.frame.width * self.frame.width * 1.1
        let dist = distance(from: self, to: piece)
        return dist < matchWidth
    }
    
    private func distance(from: GamePiece, to: GamePiece) -> CGFloat {
        return (from.position.x - to.position.x) * (from.position.x - to.position.x) + (from.position.y - to.position.y) * (from.position.y - to.position.y)
    }
    
}

func getGamePiece(as type: String) -> GamePiece {
    switch(type) {
        case "bomb":
            return Bomb()
        case "starPink":
            return Star()
        default:
            return GamePiece(type: type)
    }
}
