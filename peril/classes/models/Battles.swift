//
//  Battles.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Dollar


public enum TargetFilterType: Int {
  case ENEMY_UNIT
  case FRIENDLY_UNIT
}

typealias TargetFilterFunction = (object: AnyObject) -> Bool

public class Battle: NSObject {

  // MARK: Attributes

  // Player Management
  public var players: [Player] = []

  // The currently active player index
  public var currentPlayerIndex: Int = 0

  // Target filter functions
  private var targetFilters: [TargetFilterType: TargetFilterFunction] = [:]

  // MARK: Initializers

  public override init() {
    super.init()
  }

  // Setup default target filters
  public func setupTargetFilters() {
    targetFilters[.ENEMY_UNIT] = { (object: AnyObject) -> Bool in
      if let unit = object as? Unit {
        return unit.owner == self.currentOpponent()
      }

      return false
    }

    targetFilters[.FRIENDLY_UNIT] = { (object: AnyObject) -> Bool in
      if let unit = object as? Unit {
        return unit.owner == self.currentPlayer()
      }

      return false
    }
  }

  // MARK: Setting up the battle

  // Set up initial attributes required
  public func setup() {
    currentPlayerIndex = 0

    currentPlayer().opponent   = currentOpponent()
    currentOpponent().opponent = currentPlayer()
  }

  // Begin the battle
  public func start() {
    println("\(currentPlayer())'s turn begins")

    endTurn()
  }

}


// MARK: Players and Units

public extension Battle {

  // The currently active player object
  public func currentPlayer() -> Player {
    return players[currentPlayerIndex]
  }

  // The currently opposing player
  public func currentOpponent() -> Player {
    return players[((currentPlayerIndex + 1) % players.count)]
  }

  // Whether or not the battle has alive units left
  public func hasAliveUnits() -> Bool {
    return $.every(players.map() { $0.party }) { $0.isDead() } == false
  }

}


// MARK: Turns

public extension Battle {

  // Ending a turn
  public func endTurn() {
    println("\(currentPlayer())'s turn ends")

    // Send end of turn events
    forEachUnit { (unit) -> Void in
      unit.fireEvent(.TURN_ENDED)
    }

    // Switch active player
    currentPlayerIndex = (currentPlayerIndex + 1) % (players.count)

    // Send beginning of turn events
    forEachUnit { (unit) -> Void in
      unit.fireEvent(.TURN_STARTED)
    }

    println("\(currentPlayer())'s turn begins")
  }

  public func handleDamage() {
    // Remove dead units from the battle
    forEachDeadUnit { (unit) -> Void in
      unit.owner?.party.removeUnit(unit)
      unit.fireEvent(.UNIT_DEATH)
    }
  }

  public func handleEvent(event: GameEvent, params: [String: AnyObject]) {

  }

  public func handleMoveStarted(move: BoardMove) {
    println("Moving: \(move.pieceA) <-> \(move.pieceB)")
    forEachUnit { (unit) -> Void in
      unit.fireEvent(.BOARD_MOVE_STARTED, params: ["pieceA": move.pieceA, "pieceB": move.pieceB])
    }
  }

  public func handleMatchedChain(chain: Chain) {
    if let type = chain.pieces.first?.type {
      println("Matched: \(chain.length) x \(chain)")
      forEachUnit { (unit) -> Void in
        unit.fireEvent(GameEvent.BOARD_MOVE_MATCHED, params: ["chain": chain])
      }
    }
  }

}


// MARK: Running actions on objects

public extension Battle
{

  public func forEachUnit(callback: (unit: Unit) -> Void)
  {
    for player in players {
      for unit in player.party.units {
        callback(unit: unit)
      }
    }
  }

  public func forEachDeadUnit(callback: (unit: Unit) -> Void)
  {
    forEachUnit { (unit) -> Void in
      if unit.isDead {
        callback(unit: unit)
      }
    }
  }

  public func forEachWithUnitWithFilter(type: TargetFilterType,
    callback: (unit: Unit) -> Void)
  {
    forEachUnit { (unit) -> Void in
      var filterFunc: TargetFilterFunction = self.targetFilters[type]!
      if filterFunc(object: unit) == true {
        callback(unit: unit)
      }
    }
  }

}
