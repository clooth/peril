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

public enum RarityEnum : Int, Printable {
    case Garbage = 0
    case Normal
    case Uncommon
    case Rare
    case Ebin
    case Legendary
    case Artifact
    
    public var description : String {
        switch self {
        case .Garbage: return "Garbage"
        case .Normal: return "Normal"
        case .Uncommon: return "Uncommon"
        case .Rare: return "Rare"
        case .Ebin: return "Epic"
        case .Legendary: return "Legendary"
        case .Artifact: return "Artifact"
        }
    }
}

// InventoryItems are any items that show up in an inventory
// TODO: handle item levels that controls max budgets

public class InventoryItem: NSObject, Printable {
    public var itemSequence: ItemSequence
    public var rarity: RarityEnum
    public var affixes: [ItemAffix] = []
    public var specialName: String?
    public var level: Int
    
    public init(itemSequence:ItemSequence, rarity:RarityEnum, affixes:[ItemAffix], level:Int) {
        self.itemSequence = itemSequence
        self.rarity = rarity
        self.affixes = affixes
        self.level = level
    }
    
    public override var description: String {
        if self.specialName != nil {
            return self.specialName!
        }
        return " ".join(self.affixes.filter({!$0.guaranteed}).map {$0.description} + [self.itemSequence.properName])
    }
}

// Base class for affixes. Affixes are event listeners.

public class ItemAffix: NSObject, Printable {
    public var value: Int
    public var prefix:String = "Placeholder"
    public var guaranteed:Bool = false
    
    required public init(value:Int) {
        self.value = value
    }
    
    public override convenience init() {
        self.init(value: -1)
    }
    
    public func clone(value:Int, guaranteed:Bool = false) -> ItemAffix {
        var ret = self.dynamicType(value: value)
        ret.guaranteed = guaranteed
        return ret
    }
    
    public func merge(other:ItemAffix) -> Bool {
        if self.dynamicType.hash() != other.dynamicType.hash() {
            return false
        }
        
        self.value += other.value
        self.guaranteed = self.guaranteed | other.guaranteed
        other.value = -1
        
        return true
    }
    
    public override var description : String { return self.prefix }
}

// Item sequence class. Describes a hierarchy of items.

let MAX_BUDGET_PER_LEVEL = 13

public class ItemSequence: NSObject, Printable {
    var parent: ItemSequence?
    public var children: [ItemSequence] = []
    var itemType: ItemTypeEnum
    var guaranteedAffixes: [(ItemAffix, Int, Double)] = []
    var affixTable: [AffixTableItem] = []
    public var properName: String
    var abstract: Bool
    
    public override var description : String { return self.properName }
    
    public init(properName:String,
        itemType :ItemTypeEnum,
        affixTable:[AffixTableItem],
        guaranteedAffixes:[(ItemAffix, Int, Double)],
        abstract:Bool = true) {
            // Root sequences
            self.properName = properName
            self.itemType = itemType
            self.abstract = abstract
            self.guaranteedAffixes = guaranteedAffixes
            self.affixTable = affixTable
    }
    
    public init(properName:String,
        parent:ItemSequence,
        affixTable:[AffixTableItem],
        guaranteedAffixes:[(ItemAffix, Int, Double)],
        abstract:Bool = true) {
            // Subsequence
            self.properName = properName
            self.parent = parent
            self.itemType = parent.itemType
            self.guaranteedAffixes = parent.guaranteedAffixes + guaranteedAffixes
            self.abstract = abstract
            self.affixTable = parent.affixTable + affixTable
            super.init()
            parent.children.append(self)
    }
    
    // Pick a non-abstract descendant for this sequence (including self)
    public func randomFamily() -> ItemSequence {
        var stack = [self]
        var family : [ItemSequence] = []
        
        while stack.count > 0 {
            var last = stack.removeLast()
            if !last.abstract {
                family.append(last)
            }
            stack.splice(last.children, atIndex: 0)
        }
        
        if family.count > 0 {
            let roll = Int(arc4random_uniform(UInt32(family.count)))
            return family[roll]
        }
        else {
            println("returning self, no (valid) children")
            return self
        }
    }
    
    // Generate a random loot item
    public func generate(level:Int) -> InventoryItem {
        // 1. pick item rarity
        // note: we do not actually roll garbage items, that would be mean
        var rarity = RarityEnum.Garbage
        var rarityRoll = 0
        do {
            var rarityRoll = arc4random_uniform(10)
            var newRarity = RarityEnum(rawValue: rarity.rawValue + 1)
            if newRarity != nil {
                rarity = newRarity!
            } else {
                break
            }
        } while rarityRoll == 9
        
        
        var affixes : [ItemAffix] = []
        
        let BASE_BUDGET : UInt32 = 100
        
        // 2. Pick guaranteed affixes
        
        for (affixType, minBudget, budgetFactor) in self.guaranteedAffixes {
            var base_budget = minBudget + Int(arc4random_uniform(max(0, BASE_BUDGET-UInt32(minBudget))))
            var budget : Int = Int(Double(budgetFactor) * Double(base_budget))
            affixes.append(affixType.clone(budget, guaranteed: true))
        }
        
        // 3. Pick the randomly selected affixes
        var affixCount : Int
        switch rarity {
        case .Uncommon:
            affixCount = 1
        case .Rare:
            affixCount = 3
        case .Ebin:
            affixCount = 8
        case .Legendary:
            affixCount = 15
        case .Artifact:
            affixCount = 30
        default:
            affixCount = 0
        }
        
        var weightSum : UInt32 = {
            var sum = 0
            for affix in self.affixTable {
                sum += affix.weight
            }
            return UInt32(sum)
            }()
        
        for index in 0...affixCount {
            var base_budget = arc4random_uniform(BASE_BUDGET)
            var pick = arc4random_uniform(weightSum)
            
            var affixType:ItemAffix!
            var budget:Int!
            
            for choice in self.affixTable {
                if pick < UInt32(choice.weight) {
                    affixType = choice.affixType
                    budget = Int(Double(choice.budgetFactor) * Double(base_budget))
                    break
                }
                pick -= choice.weight
            }
            
            affixes.append(affixType.clone(budget))
        }
        
        // 4. TODO: Combine identical affixes into just one affix with the sum of their budgets
        
        for i in 0...affixes.count-1 {
            var affix = affixes[i]
            for j in i...affixes.count-1 {
                var other = affixes[j]
                if affix.dynamicType.hash() == other.dynamicType.hash() {
                    affix.merge(other)
                }
            }
        }
        
        affixes = affixes.filter{ $0.value > 0 }
        
        // 5. Construct the item
        return InventoryItem(
            itemSequence: self,
            rarity: rarity,
            affixes: affixes,
            level: level
        )
    }
}


public class AffixTableItem: NSObject {
    public var affixType: ItemAffix
    public var budgetFactor: Double
    public var weight: Int
    
    public init(affixType:ItemAffix, budgetFactor:Double = 1.0, weight:Int = 1) {
        self.affixType = affixType
        self.budgetFactor = budgetFactor
        self.weight = weight
    }
}

// Affix classes
// TODO: hook up event logic

public class XpBooster: ItemAffix {
    public required init(value:Int) {
        super.init(value: value)
        self.prefix = "Inspiring"
    }
}

public class CoinBooster: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Glimmering"
    }
}

public class LootBooster: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Prospecting"
    }
}

public class SpecialGenerator: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Empowering"
    }
}

public class SpecialFactor: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Heroic"
    }
}

public class FlatStrength: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Powerful"
    }
}

public class FlatConstitution: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Tough"
    }
}

public class FlatDexterity: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Nimble"
    }
}

public class FlatIntelligence: ItemAffix {
    
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Clever"
    }
}

public class FlatDamage: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Deadly"
    }
}

public class FlatArmor: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Impervious"
    }
}

public class HealthRegen: ItemAffix {
    public required init(value:Int) {
        super.init(value:value)
        self.prefix = "Refreshing"
    }
}

// Creates the initial set of item sequences

let sequences : [ItemSequence] = {
    var weapon = ItemSequence(
        properName: "Weapon",
        itemType: ItemTypeEnum.Equipment,
        affixTable: [
            AffixTableItem(affixType: FlatDamage()),
        ],
        guaranteedAffixes: [(FlatDamage(), 1, 1.5)],
        abstract: true)
    
    var sword = ItemSequence(
        properName: "Sword",
        parent: weapon,
        affixTable: [
            AffixTableItem(affixType: FlatStrength())
        ],
        guaranteedAffixes: [
            (FlatDamage(), 5, 1.9)
        ],
        abstract: false)
    
    var dagger = ItemSequence(
        properName: "Dagger",
        parent: weapon,
        affixTable: [
            AffixTableItem(affixType: FlatDexterity())
        ],
        guaranteedAffixes: [(FlatDamage(), 10, 1.1)],
        abstract:false
    )
    
    var shield = ItemSequence(
        properName: "Shield",
        itemType: ItemTypeEnum.Equipment,
        affixTable: [
            AffixTableItem(affixType: FlatConstitution()),
            AffixTableItem(affixType: FlatIntelligence()),
            AffixTableItem(affixType: FlatStrength())
        ],
        guaranteedAffixes: [(FlatArmor(), 10, 1.5)],
        abstract: false)
    
    var boost_scroll = ItemSequence(
        properName: "Boost Scroll",
        itemType: ItemTypeEnum.Scroll,
        affixTable: [
            AffixTableItem(affixType: XpBooster()),
            AffixTableItem(affixType: CoinBooster()),
            AffixTableItem(affixType: LootBooster())
        ],
        guaranteedAffixes: [(XpBooster(), 10, 1.5)],
        abstract: false)
    
    var red_potion = ItemSequence(
        properName: "Red Potion",
        itemType: ItemTypeEnum.Potion,
        affixTable: [
            AffixTableItem(affixType: FlatConstitution())
        ],
        guaranteedAffixes: [(HealthRegen(), 10, 1.5)],
        abstract: false)
    
    return [weapon, sword, shield, boost_scroll, red_potion]
    }()

// Breadth first search of the sequence tree

func getSequenceByName(properName:String) -> ItemSequence? {
    var stack = Array(sequences)
    
    while stack.count > 0 {
        var last = stack.removeLast()
        
        if last.properName == properName {
            return last
        }
        
        stack.splice(last.children, atIndex: 0)
    }
    
    return nil
}

/*
Usage:

var item = getSequenceByName("Weapon")!.randomFamily().generate(5)

println(item)
println(item.rarity.description)
for affix in item.affixes {
    println("\(affix.prefix) (\(affix.value))")
}
*/