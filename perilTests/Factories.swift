//
//  Factories.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Peril


var unitFactoryCounter: Int = 0

class UnitFactory: NSObject {

  class func unit() -> Unit {
    let unit = Unit(name: "Jones #\(unitFactoryCounter)", constitution: Int(arc4random_uniform(100) + 1), strength: Int(arc4random_uniform(20) + 1))
    unitFactoryCounter++
    return unit
  }

  class func units(amount: Int) -> [Unit] {
    var units = [Unit]()
    for i in 1...amount {
      units.append(self.unit())
    }
    return units
  }

}


class PartyFactory: NSObject {

  class func party(unitCount: Int) -> Party {
    return Party(units: UnitFactory.units(unitCount))
  }


}