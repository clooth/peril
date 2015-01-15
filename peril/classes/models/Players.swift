//
//  Players.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation


public class Player: NSObject, Printable {

  // MARK: Attributes

  // The unique ID of the player
  public var id: String

  // A player can have one team to use in their battles
  public var party: Party

  // MARK: Initializers

  public init(party: Party) {
    self.id = NSUUID().UUIDString
    self.party = party

    super.init()
  }

  // MARK: Protocols

  public override var description: String {
    return "[Player #\(id)] \(party)"
  }

}

