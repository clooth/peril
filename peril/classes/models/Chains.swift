//
//  Chains.swift
//  peril
//
//  Created by Nico Hämäläinen on 17/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation


public enum ChainType: Printable
{
  case Horizontal
  case Vertical
  case Mixed

  public var description: String {
    switch self {
    case .Horizontal: return "Horizontal"
    case .Vertical: return "Vertical"
    case .Mixed: return "Mixed"
    }
  }
}


public class Chain: NSObject, Hashable, Printable
{
  // MARK: Attributes

  // The Pieces that are part of this chain.
  var pieces = [Piece]()

  // Whether this chain is horizontal or vertical.
  var chainType: ChainType

  // MARK: Initializers

  init(chainType: ChainType) {
    self.chainType = chainType
  }

  func addPiece(piece: Piece) {
    pieces.append(piece)
  }

  func firstPiece() -> Piece {
    return pieces[0]
  }

  func lastPiece() -> Piece {
    return pieces[pieces.count - 1]
  }

  var length: Int {
    return pieces.count
  }

  // MARK: Printable

  public override var description: String {
    return "type: \(chainType) pieces: \(pieces)"
  }

  // MARK: Hashable

  public override var hashValue: Int {
    return reduce(pieces, 0) { $0.hashValue ^ $1.hashValue }
  }
}

public func ==(lhs: Chain, rhs: Chain) -> Bool {
  return lhs.pieces == rhs.pieces
}
