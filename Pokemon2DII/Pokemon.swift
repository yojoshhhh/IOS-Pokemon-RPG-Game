//
//  Pokemon.swift
//  Pokemon2DII
//
//  Created by Angel Cortes on 12/9/23.
//

import Foundation
import SpriteKit

class Pokemon: SKSpriteNode {
    var capture: Bool = false
    
    init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        
        self.name = "pokemon"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

