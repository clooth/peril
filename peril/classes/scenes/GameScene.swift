//
//  GameScene.swift
//  peril
//
//  Created by Nico Hämäläinen on 14/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

  // MARK: Attributes

  var battle: Battle = Battle()

  // MARK: Initializers

  override init(size: CGSize) {
    super.init(size: size)
    postInit()
  }

  override init() {
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    postInit()
  }

  func postInit() {
    var playerA = Player(battle: battle, party: Party(units: []))
    playerA.party.units.append(Unit(name: "Jesus", constitution: 10, strength: 10, owner: playerA))

    var playerB = Player(battle: battle, party: Party(units: []))
    playerB.party.units.append(Unit(name: "Sheep", constitution: 10, strength: 10, owner: playerB))

    battle.players.append(playerA)
    battle.players.append(playerB)

    battle.setup()
    battle.start()
    
    playerA.party.randomUnit()
  }
}
