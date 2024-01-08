//
//  Collectibles.swift
//  Pokemon2DII
//
//  Created by Angel Cortes on 12/14/23.
//

import Foundation
import SpriteKit

class Collectibles {
    var identifier: String
    var sprite: SKSpriteNode
    
    init(identifier: String, sprite: SKSpriteNode) {
        self.identifier = identifier
        self.sprite = sprite
    }
}
