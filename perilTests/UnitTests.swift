//
//  CharacterTests.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Peril

class UnitSpec: QuickSpec {
  override func spec() {
    var unit: Unit!
    beforeEach { unit = Unit(name: "Jeeves", constitution: 10, strength: 4) }

    describe("setup") {

      it("sets up initial attributes correctly") {
        expect(unit.name).to(equal("Jeeves"))
        expect(unit.constitution).to(equal(10))
        expect(unit.maxConstitution).to(equal(10))
        expect(unit.strength).to(equal(4))
      }

    }

    describe("damaging") {

      it("should reduce constitution when attacked") {
        unit.damage(4)

        expect(unit.constitution).to(equal(6))
        expect(unit.maxConstitution).to(equal(10))
        expect(unit.isDamaged).to(equal(true))
      }

      it("should be dead when constitution reaches 0 (or less)") {
        unit.damage(11)

        expect(unit.constitution).to(equal(0))
        expect(unit.maxConstitution).to(equal(10))
        expect(unit.isDead).to(equal(true))
      }

    }

    describe("healing") {

      it("should restore constitution when healed") {
        unit.damage(4)
        unit.heal(2)

        expect(unit.constitution).to(equal(8))
        expect(unit.isDamaged).to(equal(true))

        unit.heal(2)
        expect(unit.constitution).to(equal(10))
        expect(unit.isDamaged).to(equal(false))
      }

      it("shouldn't heal over maximum") {
        unit.heal(20)
        expect(unit.constitution).to(equal(unit.maxConstitution))
      }
    }

  }
}