//
//  Battles.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation


class Battle: NSObject {

  // MARK: Attributes

  var playerA: Player
  var playerB: Player

  // MARK: Initializers

  init(playerA: Player, playerB: Player) {
    self.playerA = playerA
    self.playerB = playerB

    super.init()
  }

}
