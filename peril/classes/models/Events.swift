//
//  Events.swift
//  peril
//
//  Created by Nico Hämäläinen on 15/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Dollar

public enum GameEvent: Int, Printable
{
  case UNKNOWN = 0

  // MARK: Battle Events
  case BATTLE_STARTED
  case BATTLE_ENDED

  // MARK: Turns
  case TURN_STARTED
  case TURN_ENDED

  // MARK: Board Events
  case BOARD_MOVE_STARTED
  case BOARD_MOVE_MATCHED
  case BOARD_MOVE_FAILED
  case BOARD_MOVE_ENDED

  // MARK: Unit Events
  case UNIT_ATTACKED
  case UNIT_DAMAGED
  case UNIT_HEALED
  case UNIT_DEATH

  // MARK: Printable
  public var description: String {
    switch self {

    case .UNKNOWN: return "Unknown"
    case .BATTLE_STARTED: return "Battle Started"
    case .BATTLE_ENDED: return "Battle Ended"

    case .TURN_STARTED: return "Turn Started"
    case .TURN_ENDED: return "Turn Ended"

    case .BOARD_MOVE_STARTED: return "Board Move Started"
    case .BOARD_MOVE_MATCHED: return "Board Move Matched"
    case .BOARD_MOVE_FAILED: return "Board Move Failed"
    case .BOARD_MOVE_ENDED: return "Board Move Ended"

    case .UNIT_ATTACKED: return "Unit Attacked"
    case .UNIT_DAMAGED: return "Unit Damaged"
    case .UNIT_DEATH: return "Unit Died"
    case .UNIT_HEALED: return "Unit Healed"

    }
  }
}
