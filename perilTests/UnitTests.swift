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
    beforeEach { unit = UnitFactory.unit() }

    describe("setup") {

      it("sets up initial attributes correctly") {
        expect(unit.constitution).to(beGreaterThanOrEqualTo(1))
        expect(unit.constitution).to(beLessThanOrEqualTo(100))
        expect(unit.maxConstitution).to(equal(unit.constitution))
        expect(unit.strength).to(beGreaterThanOrEqualTo(1))
      }

    }

    describe("damaging") {

      it("should reduce constitution when attacked") {
        unit.damage(4)

        expect(unit.constitution).to(equal(unit.maxConstitution - 4))
        expect(unit.isDamaged).to(equal(true))
      }

      it("should be dead when constitution reaches 0 (or less)") {
        unit.damage(unit.constitution)

        expect(unit.constitution).to(equal(0))
        expect(unit.isDead).to(equal(true))
      }

    }

    describe("healing") {

      it("should restore constitution when healed") {
        unit.damage(4)
        unit.heal(2)

        expect(unit.constitution).to(equal(unit.maxConstitution - 2))
        expect(unit.isDamaged).to(equal(true))

        unit.heal(2)
        expect(unit.constitution).to(equal(unit.maxConstitution))
        expect(unit.isDamaged).to(equal(false))
      }

      it("shouldn't heal over maximum") {
        unit.heal(20)
        expect(unit.constitution).to(equal(unit.maxConstitution))
      }
    }

  }
}