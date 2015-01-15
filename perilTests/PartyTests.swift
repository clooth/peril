//
//  PartyTests.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Quick
import Nimble

import Peril
import Dollar

class PartySpec: QuickSpec {
  override func spec() {
    var party: Party!
    beforeEach {
      party = PartyFactory.party(4)
    }

    describe("querying units") {

      it("should return random units") {
        expect(party.randomUnit()).to(beAKindOf(Unit.self))
      }

      it("should find the weakest unit") {
        let jesus = Unit(name: "Jesus", constitution: 9001, strength: 1)
        party.units.append(jesus)

        expect(party.strongestUnit()).to(equal(jesus))
      }

      it("should find the strongest unit") {
        // Make sure other units are higher than 1 constitution
        for unit in party.units {
          unit.constitution = 10
        }

        let sheep = Unit(name: "Sheep", constitution: 1, strength: 1)
        party.units.append(sheep)

        expect(party.weakestUnit()).to(equal(sheep))
      }

      it("should allow subscripting units") {
        expect(party[0]).to(beAKindOf(Unit.self))
        expect(party[1]).to(beAKindOf(Unit.self))
      }

    }

  }
}
