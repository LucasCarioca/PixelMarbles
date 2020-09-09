//
//  Star.swift
//  PixelMarbles
//
//  Created by Lucas Desouza on 9/8/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//

import Foundation
import SpriteKit

class Star: GamePiece {
    
    init() {
        super.init(type: "starPink")
        if let particles = SKEmitterNode(fileNamed: "starSparkle") {
            self.addChild(particles)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
