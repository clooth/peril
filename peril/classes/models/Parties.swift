//
//  Parties.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Dollar

// Units are always part of a Party when in a battle, fighting another Party

public class Party: NSObject, Printable
{
  // MARK: Attributes

  // All the units in this party
  public var units: [Unit]

  // Owning player
  public var owner: Player?

  // MARK: Initializers

  public init(units: [Unit]) {
    self.units = units
    super.init()
  }

  // MARK: Protocols

  public override var description: String {
    let unitStrings = ", ".join(units.map { $0.description })
    return "[Party] \(unitStrings)"
  }
}

// MARK: Querying Party Units

public extension Party {

  public func randomUnit() -> Unit {
    return $.sample(units)
  }

  public func randomDamagedUnit() -> Unit {
    return $.sample(damagedUnits())
  }

  public func damagedUnits() -> [Unit] {
    return units.filter({ (unit: Unit) -> Bool in
      return unit.isDamaged
    })
  }

  public func weakestUnit() -> Unit {
    return units.reduce(units[0]) {
      ($0.constitution < $1.constitution) ? $0 : $1
    }
  }

  public func strongestUnit() -> Unit {
    return units.reduce(units[0]) {
      ($0.constitution > $1.constitution) ? $0 : $1
    }
  }

  public func isDead() -> Bool {
    return $.every(units) { $0.isDead }
  }

  public subscript(index: Int) -> Unit {
    get {
      assert(index < units.count, "Index out of range")
      return units[index]
    }

    set {
      assert(index < units.count, "Index out of range")
      units[index] = newValue
    }
  }

  public func addUnit(unit: Unit) {
    unit.owner = self.owner
    println(unit.owner)
    self.units.append(unit)
  }

  public func removeUnit(unit: Unit) {
    units = units.filter( {$0 != unit} )
  }

  // MARK: Helpers

  public func forEachUnit(callback: (unit: Unit) -> Void) -> Void {
    units.map(callback)
  }
}