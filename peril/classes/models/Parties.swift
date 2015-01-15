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

  public var units: [Unit]

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
}