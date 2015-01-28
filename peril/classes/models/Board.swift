//
//  Board.swift
//  peril
//
//  Created by Nico Hämäläinen on 17/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Dollar

public let BoardColumns = 6
public let BoardRows    = 6


public class Board: NSObject
{
  // MARK: Attributes

  // Size of the board
  public var columns: Int = BoardColumns
  public var rows: Int    = BoardRows

  // Pieces 2D Array
  public var pieces = Array2D<Piece>(columns: BoardColumns, rows: BoardRows)

  // Currently possible moves
  public var possibleMoves: Set<BoardMove> {
    get {
      var moves = detectPossibleMoves()
      return moves
    }
  }

  // MARK: Initializers

  public override init()
  {
    super.init()
  }
}

// MARK: Manipulating the Board

public extension Board
{
  public func shuffle() -> Set<Piece>
  {
    var set = Set<Piece>()

    do {
      pieces.array = $.shuffle(pieces.array)
    } while self.hasMatches()

    for row in 0..<columns {
      for col in 0..<rows {
        pieces[col, row]?.column = col
        pieces[col, row]?.row = row
        set.addElement(pieces[col, row]!)
      }
    }

    return set
  }

  public func hasMatches() -> Bool {
    var hasMatches: Bool = false

    for row in 0..<columns {
      for col in 0..<rows {
        var type: PieceType = pieces[col, row]!.type

        if ((col >= 2 &&
          pieces[col - 1, row]?.type == type &&
          pieces[col - 2, row]?.type == type)
        ||
        (row >= 2 &&
          pieces[col, row - 1]?.type == type &&
          pieces[col, row - 2]?.type == type)) {
            hasMatches = true
            break
        }
      }
    }

    return hasMatches
  }

  public func reset() -> Set<Piece>
  {
    var set = Set<Piece>()

    for row in 0..<columns {
      for col in 0..<rows {
        // Pick a random piece type
        var type: PieceType
        do {
          type = PieceType.random()
        } while (col >= 2 &&
          pieces[col - 1, row]?.type == type &&
          pieces[col - 2, row]?.type == type)
          ||
          (row >= 2 &&
            pieces[col, row - 1]?.type == type &&
            pieces[col, row - 2]?.type == type)

        // Create new piece and add it to the array
        let piece = Piece(column: col, row: row, type: type)
        pieces[col, row] = piece
        set.addElement(piece)
      }
    }

    println("Reset board:")
    println(pieces)

    return set
  }

  // MARK: Performing Moves

  public func performMove(move: BoardMove)
  {
    let (columnA, rowA) = (move.pieceA.column, move.pieceA.row)
    let (columnB, rowB) = (move.pieceB.column, move.pieceB.row)

    pieces[columnA, rowA] = move.pieceB
    move.pieceB.column = columnA
    move.pieceB.row = rowA

    pieces[columnB, rowB] = move.pieceA
    move.pieceA.column = columnB
    move.pieceA.row = rowB
  }

  // MARK: Removing matches from the board

  public func removeMatches() -> Set<Chain>
  {
    var horizontalChains = horizontalMatches()
    var verticalChains   = verticalMatches()
    var mixedChains      = Set<Chain>()

    // Mixed matches
    // TODO: Move into own method
    for horzChain in horizontalChains {
      for vertChain in verticalChains {
        var intersection = $.intersection(horzChain.pieces, vertChain.pieces)
        if intersection.count > 0 {
          var chain = Chain(chainType: .Mixed)
          chain.pieces = $.union(horzChain.pieces, vertChain.pieces)
          mixedChains.addElement(chain)

          horizontalChains.removeElement(horzChain)
          verticalChains.removeElement(vertChain)
        }
      }
    }

    let chains = mixedChains.unionSet(horizontalChains).unionSet(verticalChains)
    removeChains(chains)

    return chains
  }

  // Remove all the pieces from the board in the given chains
  private func removeChains(chains: Set<Chain>)
  {
    for chain in chains {
      for piece in chain.pieces {
        pieces[piece.column, piece.row] = nil
      }
    }
  }

  // MARK: Filling the board

  // Detects where there are holes and shifts any pieces down to fill up those
  // holes.
  public func fillBoardHoles() -> [[Piece]]
  {
    // The columns where we have holes
    var cols = [[Piece]]()

    // Loop through the rows, from bottom to top. It's handy that our row 0 is
    // at the bottom already. Because we're scanning from bottom to top, this
    // automatically causes an entire stack to fall down to fill up a hole.
    // We scan one column at a time.
    for column in 0..<columns {
      var array = [Piece]()

      // Go through each row
      for row in 0..<rows {
        // If there's no piece at this location
        if pieces[column, row] == nil {
          // Scan upwards
          for lookup in (row + 1)..<rows {
            if let piece = pieces[column, lookup] {
              // Swap piece with hole
              pieces[column, lookup] = nil
              pieces[column, row] = piece
              piece.row = row

              // Return an array of pieces that have fallen down.
              // Array is ordered for animation purposes.
              array.append(piece)

              // No need to scan up more
              break
            }
          }
        }
      }

      if !array.isEmpty {
        cols.append(array)
      }
    }

    return cols
  }

  // MARK: Create new pieces to fill up holes at the top
  public func fillUpPieces() -> [[Piece]]
  {
    var cols: [[Piece]] = [[Piece]]()
    var type: PieceType = .Unknown

    for col in 0..<columns {
      var array = [Piece]()

      // Scan top to bottom
      for var row = rows - 1; row >= 0 && pieces[col, row] == nil; --row {
        // If slot is empty
        if pieces[col, row] == nil {
          // Create random piece type
          var pieceType: PieceType
          do {
            pieceType = PieceType.random()
          } while pieceType == type

          // Create piece
          let piece = Piece(column: col, row: row, type: pieceType)
          pieces[col, row] = piece
          array.append(piece)
        }
      }

      if !array.isEmpty {
        cols.append(array)
      }
    }

    return cols
  }
}

// MARK: Querying the board

public extension Board
{
  // MARK: Finding pieces

  // Get a piece from a specific column and row
  public func pieceAtColumn(column: Int, row: Int) -> Piece?
  {
    assert(column >= 0 && column < columns)
    assert(row >= 0 && row < rows)
    return pieces[column, row]
  }

  // MARK: Finding possible moves

  // Find all possible moves the board allows
  public func detectPossibleMoves() -> Set<BoardMove>
  {
    var set = Set<BoardMove>()

    for row in 0..<rows {
      for col in 0..<columns {
        // If there's a piece there
        if let piece = pieces[col, row] {

          // Can we swap this with the one above?
          if col < columns - 1 {
            // Is there a piece in this spot?
            if let other = pieces[col + 1, row] {
              // Swap them
              pieces[col, row] = other
              pieces[col + 1, row] = piece

              // Is either of them part of the chain?
              if hasChainAtColumn(col + 1, row: row) || hasChainAtColumn(col, row: row) {
                set.addElement(BoardMove(pieceA: piece, pieceB: other))
              }

              // Swap them back
              pieces[col, row] = piece
              pieces[col + 1, row] = other
            }
          }

          // Can we swap this with the one above?
          if row < rows - 1 {
            if let other = pieces[col, row + 1] {
              // Swap them
              pieces[col, row] = other
              pieces[col, row + 1] = piece

              // Is either of them part of the chain?
              if hasChainAtColumn(col, row: row + 1) || hasChainAtColumn(col, row: row) {
                set.addElement(BoardMove(pieceA: piece, pieceB: other))
              }

              // Swap them back
              pieces[col, row] = piece
              pieces[col, row + 1] = other
            }
          }

        }
      }
    }

    return set
  }

  // Validate a given BoardMove
  public func isPossibleMove(move: BoardMove) -> Bool
  {
    return possibleMoves.containsElement(move)
  }

  // Whether or not we have possible moves left on the board
  public func hasPossibleMoves() -> Bool
  {
    return possibleMoves.count > 0
  }

  // MARK: Finding chains

  private func hasChainAtColumn(column: Int, row: Int) -> Bool
  {
    // Here we have ! because we know there's a piece there
    let type = pieces[column, row]!.type

    // Here we do ? because there may be no piece there; if there isn't then
    // the loop will terminate because it is != type. (So there is no
    // need to check whether pieces[i, row] != nil.)
    var horzLength = 1
    for var i = column - 1; i >= 0 && pieces[i, row]?.type == type; --i, ++horzLength { }
    for var i = column + 1; i < columns && pieces[i, row]?.type == type; ++i, ++horzLength { }
    if horzLength >= 3 { return true }

    var vertLength = 1
    for var i = row - 1; i >= 0 && pieces[column, i]?.type == type; --i, ++vertLength { }
    for var i = row + 1; i < rows && pieces[column, i]?.type == type; ++i, ++vertLength { }
    return vertLength >= 3
  }

  // MARK: Finding matches

  public func horizontalMatches() -> Set<Chain>
  {
    var set = Set<Chain>()

    for row in 0..<rows {
      // Skip the last two columns
      for var col = 0; col < columns - 2; {
        if let piece = pieces[col, row]? {
          let piece = pieces[col, row]!
          let type = piece.type

          // If the next two are the same type
          if pieces[col + 1, row]?.type == type && pieces[col + 2, row]?.type == type {
            // Add all to a chain
            let chain = Chain(chainType: .Horizontal)
            do {
              chain.addPiece(pieces[col, row]!)
              ++col
            } while col < columns && pieces[col, row]?.type == type

            set.addElement(chain)
            continue
          }
          
          // No match, skip
          ++col
        }
      }
    }
    
    return set
  }

  public func verticalMatches() -> Set<Chain>
  {
    var set = Set<Chain>()

    for col in 0..<columns {
      // Skip the last two columns
      for var row = 0; row < rows - 2; {
        if let piece = pieces[col, row]? {
          let type = piece.type

          // If the next two are the same type
          if pieces[col, row + 1]?.type == type && pieces[col, row + 2]?.type == type {
            // Add all to a chain
            let chain = Chain(chainType: .Horizontal)
            do {
              chain.addPiece(pieces[col, row]!)
              ++row
            } while row < rows && pieces[col, row]?.type == type

            set.addElement(chain)
            continue
          }
          
          // No match, skip
          ++row
        }
      }
    }
    
    return set
  }

}