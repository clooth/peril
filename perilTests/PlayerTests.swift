//
//  PlayerTests.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Peril

class PlayerSpec: QuickSpec {
  override func spec() {
    var player: Player!
    beforeEach {
      player = Player(party: PartyFactory.party(4))
    }

    describe("setup") {

      it("should have a party in storage") {
        expect(player.party).to(beAKindOf(Party.self))
      }

      it("should have a unique ID") {
        expect(player.id).toNot(beNil())
      }

    }
  }
}