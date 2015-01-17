//
//  Battles.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Dollar

public class Battle: NSObject {

  // MARK: Attributes

  // Player Management
  public var players: [Player] = []

  // The currently active player index
  public var currentPlayerIndex: Int = 0

  // MARK: Initializers

  public override init() {
    super.init()
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


// MARK: Players

public extension Battle {

  // The currently active player object
  public func currentPlayer() -> Player {
    return players[currentPlayerIndex]
  }

  // The currently opposing player
  public func currentOpponent() -> Player {
    return players[(currentPlayerIndex + 1 % players.count)]
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
    for player in players {
      player.fireEvent(.TURN_ENDED, params: nil)
      for unit in player.party.units {
        unit.fireEvent(.TURN_ENDED, params: nil)
      }
    }

    // Switch active player
    currentPlayerIndex = (currentPlayerIndex + 1) % (players.count)

    // Send beginning of turn events
    for player in players {
      player.fireEvent(.TURN_STARTED, params: nil)
      for unit in player.party.units {
        unit.fireEvent(.TURN_STARTED, params: nil)
      }
    }

    println("\(currentPlayer())'s turn begins")
  }

  public func handleDamage() {
    var dead: [Unit] = []

    for player in players {
      for unit in player.party.units {
        if unit.isDead {
          dead.append(unit)
        }
      }
    }

    for unit in dead {
      unit.owner!.party.removeUnit(unit)
      unit.fireEvent(.UNIT_DEATH, params: nil)
    }
  }

}


// MARK: Combat

public extension Battle {

  // Handle

}