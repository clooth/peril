//
//  BattleTests.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Peril

class BattleSpec: QuickSpec {
  override func spec() {
    var battle: Battle!
    beforeEach {
      battle = Battle(playerA: PlayerFactory.player(), playerB: PlayerFactory.player())
    }

    describe("setup") {

    }
  }
}