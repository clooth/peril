//
//  Pieces.swift
//  peril
//
//  Created by Nico Hämäläinen on 17/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import SpriteKit

public enum PieceType: Int, Printable
{
  case Unknown = 0
  case Melee
  case Ranged
  case Healing
  case Magic
  case Coin

  var name: String {
    let pieceNames = [
      "melee", "ranged", "healing", "magic", "coin"
    ]

    return pieceNames[rawValue - 1]
  }

  static func random() -> PieceType {
    return PieceType(rawValue: Int(arc4random_uniform(5)) + 1)!
  }

  public var description: String {
    return name
  }
}


public class Piece: Printable, Hashable
{
  // MARK: Attributes

  // Position on the board
  public var column: Int
  public var row: Int

  // Type of Piece
  public var type: PieceType
  public var sprite: SKSpriteNode?

  // MARK: Initializers

  init(column: Int, row: Int, type: PieceType) {
    self.column = column
    self.row = row
    self.type = type
  }

  // MARK: Printable

  public var description: String {
    return "\(type)(\(column),\(row))"
  }

  // MARK: Hashable

  public var hashValue: Int {
    return row * 10 + column + type.rawValue
  }
}

public func == (lhs: Piece, rhs: Piece) -> Bool {
  return lhs.column == rhs.column && lhs.row == rhs.row && lhs.type == rhs.type
}
