//
//  Pokeballs.swift
//  Pokemon2DII
//
//  Created by Angel Cortes on 12/14/23.
//

import Foundation
import SpriteKit

class Pokeballs: SKSpriteNode {
    var collected: Bool = false
    
    init() {
        let texture = SKTexture(imageNamed: "redPokeBall")
     //   _ = CGSize(width: 30, height: 30)
//super.init(texture: texture, color: .clear, size: texture.size())
        super.init(texture: texture, color: .clear, size: CGSize(width: 30, height: 30))

        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        
        self.name = "pokeball"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
