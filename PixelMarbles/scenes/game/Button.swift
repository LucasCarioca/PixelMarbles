//
//  GameButton.swift
//  PixelMarbles
//
//  Created by Lucas Desouza on 9/8/20.
//  Copyright © 2020 Lucas Desouza. All rights reserved.
//

import Foundation
import SpriteKit

class Button: SKSpriteNode {
    
    init(type: String) {
        let texture = SKTexture(imageNamed: type)
        super.init(texture: texture, color: .white, size: texture.size())
        self.zPosition = 100
        self.name = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
