//
//  Moves.swift
//  peril
//
//  Created by Nico Hämäläinen on 17/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation


public struct BoardMove: Printable, Hashable
{
  // MARK: Attributes

  let pieceA: Piece
  let pieceB: Piece

  // MARK: Initializers

  init(pieceA: Piece, pieceB: Piece) {
    self.pieceA = pieceA
    self.pieceB = pieceB
  }

  // MARK: Printable

  public var description: String {
    return "Swap \(pieceA) with \(pieceB)"
  }

  // MARK: Hashable

  public var hashValue: Int {
    return pieceA.hashValue ^ pieceB.hashValue
  }
}

public func ==(lhs: BoardMove, rhs: BoardMove) -> Bool {
  return (lhs.pieceA == rhs.pieceA && lhs.pieceB == rhs.pieceB) ||
    (lhs.pieceB == rhs.pieceA && lhs.pieceA == rhs.pieceB)
}
