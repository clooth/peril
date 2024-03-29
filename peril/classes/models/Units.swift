//
//  Units.swift
//  peril
//
//  Created by Nico Hämäläinen on 14/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Dollar


// Each ally hero as well as enemy mob is an Unit and they all include
// mostly the same type of data for use in the gameplay.

public class Unit: GameObject, Printable
{

  // MARK: Attributes
  public var name: String

  // Unique ID
  public let id: String = NSUUID().UUIDString

  // Constitution has two different attributes, for tracking the max value 
  // as well.
  public var constitution: Int
  public var maxConstitution: Int

  // Strength determines how much damage we deal in combat
  public var strength: Int

  // MARK: Initializers

  public init(name: String, constitution: Int, strength: Int, owner: Player) {
    self.name = name
    self.constitution = constitution
    self.maxConstitution = constitution
    self.strength = strength

    super.init(battle: owner.battle)
  }

  // MARK: Protocols

  public override var description: String {
    return "\(name)"
  }

}

// MARK: Combat

public extension Unit {

  // Whether or not the unit has been damaged in combat
  public var isDamaged: Bool {
    get {
      return constitution < maxConstitution
    }
  }

  // Whether or not the unit is dead and cannot do anything
  public var isDead: Bool {
    get {
      return constitution <= 0
    }
  }

  public func damage(amount: Int, source: Unit?) {
    // We can only go down to 0 health
    constitution = max(constitution - amount, 0)

    NSLog("Unit \(name) takes \(amount) damage from \(source?.name).")

    if constitution == 0 {
      NSLog("Unit \(name) has died.")
    }

    fireEvent(GameEvent.UNIT_DAMAGED, params: nil)

    battle.handleDamage()
  }

  public func heal(amount: Int) {
    // Check what the maximum heal amount is (up to maxConstitution)
    let realAmount = min(amount, max(maxConstitution - constitution, 0))

    // If we're actually healing any
    if realAmount > 0 {
      NSLog("Unit \(name) healed by \(amount) constitution.")

      constitution += realAmount
    }
  }

  public func destroy() {
    damage(maxConstitution, source: nil)
  }

}


public func == (lhs: Unit, rhs: Unit) -> Bool {
  return (lhs.id == rhs.id)
}
