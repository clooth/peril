//
//  Loot.swift
//  peril
//
//  Created by Leo Honkanen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation

// Loot is a container of after-battle rewards

public class Loot: NSObject {
    var xpGain: Int = 0
    var coinGain: Int = 0
    var itemGain: [InventoryItem] = []
}

public enum ItemTypeEnum {
    case Equipment
    case Scroll
    case Potion
}

public enum RarityEnum {
    case Garbage
    case Normal
    case Uncommon
    case Rare
    case Ebin
    case Legendary
    case Artifact
}

// InventoryItems are any items that show up in an inventory

public class InventoryItem: NSObject, Printable {
    public var itemType: ItemTypeEnum
    public var itemSequence: ItemSequence
    public var rarity: RarityEnum = .Garbage
    public var affixes: [ItemAffix] = []
    public var specialName: String?
    
    public init(itemType:ItemTypeEnum, itemSequence:ItemSequence) {
        self.itemType = itemType
        self.itemSequence = itemSequence
    }
    
    public override var description: String {
        if self.specialName != nil {
            return self.specialName!
        }
        return " ".join(self.affixes.map {$0.description}) + " " + self.itemSequence.description
    }
}

// Base class for affixes. Affixes are event listeners.

public class ItemAffix: NSObject, Printable {
    public var value: Int
    public var prefix:String = "Placeholder"
    
    public init(value:Int) {
        self.value = value
    }
}

// Item sequence class. Describes a hierarchy of items.

public class ItemSequence: NSObject, Printable {
    var parent: ItemSequence?
    var affixTable: [AffixTableItem] = []
}

public class AffixTableItem: NSObject {
    public var affix: ItemAffix
    public var budgetFactor: Double = 1.0
    public var weightFactor: Double = 1.0
    
    public init(affix:ItemAffix) {
        self.affix = affix
    }
}

// Affix classes
// TODO: hook up event logic

public class XpBooster: ItemAffix {
    public override init(value:Int) {
        super.init(value: value)
        self.prefix = "Inspiring"
    }
}

public class CoinBooster: ItemAffix {
    public override init(value:Int) {
        super.init(value:value)
        self.prefix = "Glimmering"
    }
}

public class LootBooster: ItemAffix {
    public override init(value:Int) {
        super.init(value:value)
        self.prefix = "Prospecting"
    }
}

public class SpecialGenerator: ItemAffix {
    public override init(value:Int) {
        super.init(value:value)
        self.prefix = "Empowering"
    }
}

public class SpecialFactor: ItemAffix {
    public override init(value:Int) {
        super.init(value:value)
        self.prefix = "Heroic"
    }
}

public class FlatStrength: ItemAffix {
    public override init(value:Int) {
        super.init(value:value)
        self.prefix = "Powerful"
    }

public class FlatConstitution: ItemAffix {
    public override init(value:Int) {
        super.init(value:value)
        self.prefix = "Tough"
    }
}

public class FlatDexterity: ItemAffix {
    public override init(value:Int) {
        super.init(value:value)
        self.prefix = "Nimble"
    }
}

public class FlatIntelligence: ItemAffix {
    
    public override init(value:Int) {
        super.init(value:value)
        self.prefix = "Clever"
    }
}

public class FlatDamage: ItemAffix {
    public override init(value:Int) {
        super.init(value:value)
        self.prefix = "Deadly"
    }
}