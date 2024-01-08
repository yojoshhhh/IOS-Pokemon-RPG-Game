//
//  GameScene.swift
//  Pokemon2DII
//
//  Created by Angel & Joshua 12/9/23.
//

import SpriteKit
import GameplayKit
import Subsonic

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()
    var capturedPokemon: [SKSpriteNode] = []
    // time tracker for updates
    private var lastUpdateTime: TimeInterval = 0
    // reference to player node
    private var player: Player?

    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        physicsWorld.contactDelegate = self
    }
    
    override func didMove(to view: SKView) {
        // get player node from scene
        player = childNode(withName: "player") as? Player
        // set physics body for player
        player?.physicsBody?.categoryBitMask = PhysicsCategory.player
        player?.physicsBody?.collisionBitMask = PhysicsCategory.pokemon | PhysicsCategory.pokeball
        player?.physicsBody?.contactTestBitMask = PhysicsCategory.pokemon | PhysicsCategory.pokeball
        
        // set physics body for all pokemons
        enumerateChildNodes(withName: "pokemon") { node, _ in
            if let pokemon = node as? Pokemon {
                pokemon.physicsBody?.categoryBitMask = PhysicsCategory.pokemon
                pokemon.physicsBody?.collisionBitMask = PhysicsCategory.player
                pokemon.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.pokeball
            }
        }
        
        // set physics body for all pokeballs
        enumerateChildNodes(withName: "pokeball") { node, _ in
            if let pokeball = node as? Pokeballs {
                pokeball.physicsBody?.categoryBitMask = PhysicsCategory.pokeball
                pokeball.physicsBody?.collisionBitMask = PhysicsCategory.player
                pokeball.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.pokemon
            }
        }

        physicsWorld.contactDelegate = self
        
        spawnPokemon()
        spawnPokeballs()
        playBackgroundMusic()
    }
    
    // play sound effect
    func playSoundEffect() {
            run(SKAction.playSoundFileNamed("pokemonsound.mp3", waitForCompletion: false))
        }
    
    // play background music
    func playBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "Pokemon Instrumental", withExtension: "mp3") {
            let backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
    }
    
    // spawns pokemon randomly
    func spawnPokemon() {
        // random number generator for pokemon image
        let randomPokemonNumber = Int.random(in: 1...151)
        let pokemon = Pokemon(imageNamed: "\(randomPokemonNumber)")
        pokemon.name = "pokemon"

        // calculate random position within visible area
        let minX = -self.size.width / 2 + pokemon.size.width / 2
        let maxX = self.size.width / 2 - pokemon.size.width / 2
        let minY = -self.size.height / 2 + pokemon.size.height / 2
        let maxY = self.size.height / 2 - pokemon.size.height / 2

        var randomX = CGFloat.random(in: minX...maxX)
        var randomY = CGFloat.random(in: minY...maxY)

        // checks if pokemon overlaps with or spawns on tree image
        while isPokemonOverlappingTree(at: CGPoint(x: randomX, y: randomY)) {
            // if does reposition the pokemon until no longer on tree image
            randomX = CGFloat.random(in: minX...maxX)
            randomY = CGFloat.random(in: minY...maxY)
        }

        // set final random position
        pokemon.position = CGPoint(x: randomX, y: randomY)

        pokemon.zPosition = 1
        addChild(pokemon)
        
        // respawn timer
        let delay = SKAction.wait(forDuration: 10.0)
        let spawnNextPokemon = SKAction.run { [weak self] in
            self?.spawnPokemon()
        }
        run(SKAction.sequence([delay, spawnNextPokemon]))
    }
    
    // spawn pokeballs randomly
    func spawnPokeballs() {
        let pokeball = Pokeballs()
        
        let scaledSize = CGSize(width: 30, height: 30)
        pokeball.size = scaledSize
        
        // set random position
        let minX = -self.size.width / 2 + pokeball.size.width / 2
        let maxX = self.size.width / 2 - pokeball.size.width / 2
        let minY = -self.size.height / 2 + pokeball.size.height / 2
        let maxY = self.size.height / 2 - pokeball.size.height / 2

        let randomX = CGFloat.random(in: minX...maxX)
        let randomY = CGFloat.random(in: minY...maxY)

        pokeball.position = CGPoint(x: randomX, y: randomY)
        pokeball.zPosition = 1
        
        pokeball.physicsBody?.categoryBitMask = PhysicsCategory.pokeball
        pokeball.physicsBody?.collisionBitMask = PhysicsCategory.player
        pokeball.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        addChild(pokeball)
        // respawn timer
        let delay = SKAction.wait(forDuration: 5.0)
        let spawnNextPokeball = SKAction.run { [weak self] in
            self?.spawnPokeballs()
                }
        run(SKAction.sequence([delay, spawnNextPokeball]))
    }

    func isPokemonOverlappingTree(at position: CGPoint) -> Bool {
        let nodes = nodes(at: position).filter { $0.name == "tree" }
        return !nodes.isEmpty
    }

/*
    // checks to see if pokemon is caught
    func checkForPokemonCapture() {
        enumerateChildNodes(withName: "pokemon") { node, _ in
            if let pokemon = node as? Pokemon, let playerNode = self.player {
                if playerNode.frame.intersects(pokemon.frame), !pokemon.capture {
                    // player caught pokemon
                    pokemon.capture = true
                    print("Player caught a Pokemon!")
                    self.playSoundEffect()

                    // Store captured pokemon images
                    if let pokemonName = pokemon.name {
                        let capturedImage = SKSpriteNode(imageNamed: pokemonName)
                        self.capturedPokemon.append(capturedImage)
                    }

                    pokemon.removeFromParent()
                    self.spawnPokemon()
                }
            }
        }
    }*/
    
    override func update(_ currentTime: TimeInterval) {
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }

        let dt = currentTime - self.lastUpdateTime

        for entity in self.entities {
            entity.update(deltaTime: dt)
        }

        self.lastUpdateTime = currentTime

      //  checkForPokemonCapture()
    }
}

// helps handle physics contact
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
     //   print("Contact detected")
        let firstNode = contact.bodyA.node
        let secondNode = contact.bodyB.node

        if let playerNode = player,
           (firstNode == playerNode || secondNode == playerNode) {

            if let pokemonNode = (firstNode == playerNode) ? secondNode : firstNode,
               pokemonNode.name == "pokemon",
               let pokemon = pokemonNode as? Pokemon,
               !pokemon.capture {
                
                print("Player hit Pokemon")
                self.playSoundEffect()

                pokemon.capture = true
                print("Player caught a Pokemon!")

                pokemon.removeFromParent()
            }

            if let pokeballNode = (firstNode == playerNode) ? secondNode : firstNode,
               pokeballNode.name == "pokeball",
                let pokeball = pokeballNode as? Pokeballs,
                !pokeball.collected {
                            
                print("Player collected a Pokeball!")
                pokeball.collected = true

                pokeball.removeFromParent()
            }
        }
    }
}


// handles touch input
extension GameScene {
    func touchDown(atPoint pos: CGPoint) {
        print("touch down")
        let nodeAtPoint = atPoint(pos)
        if let touchedNode = nodeAtPoint as? SKSpriteNode {
            if touchedNode.name?.starts(with: "controller_") == true {
                let direction = touchedNode.name?.replacingOccurrences(of: "controller_", with: "")
                player?.move(Direction(rawValue: direction ?? "stop")!)
        }
    }
}
    
    func touchMoved(toPoint pos: CGPoint) {
        // handle touch moved
    }
    
    func touchUp(atPoint pos: CGPoint) {
        // handle touch up
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchDown(atPoint: touch.location(in: self))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
        }
    }
    
}
