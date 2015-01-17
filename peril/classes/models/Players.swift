//
//  Players.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation


public class Player: GameObject, Printable {

  // MARK: Attributes

  // The unique ID of the player
  public var id: String

  // A player can have one team to use in their battles
  public var party: Party

  // Current opponent, if any
  public var opponent: Player?

  // MARK: Initializers

  public init(battle: Battle, party: Party) {
    self.id = NSUUID().UUIDString
    self.party = party

    super.init(battle: battle)

    // MARK: Default Events
    self.bindEvent(.TURN_STARTED, handler: { (battle, params) -> Void in
      println("TURN STARTED YO")
    })
  }

  // MARK: Protocols

  public override var description: String {
    return "Player #\(id)"
  }

}

