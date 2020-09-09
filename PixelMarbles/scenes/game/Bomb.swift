//
//  Bomb.swift
//  PixelMarbles
//
//  Created by Lucas Desouza on 9/8/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//

import Foundation
import SpriteKit

class Bomb: GamePiece {

    init() {
        super.init(type: "bomb")
        if let particles = SKEmitterNode(fileNamed: "bombSmoke") {
            self.addChild(particles)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
