//
//  BoardNode.swift
//  peril
//
//  Created by Nico Hämäläinen on 17/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import SpriteKit
import Dollar


public class BoardNode: SKNode
{
  // MARK: Default sizes

  public class func defaultColumns() -> Int {
    return 6
  }

  public class func defaultRows() -> Int {
    return 6
  }

  public class func defaultAnimationDuration() -> NSTimeInterval {
    return 0.2
  }

  public class func defaultAnimationTimingMode() -> SKActionTimingMode {
    return SKActionTimingMode.EaseInEaseOut
  }

  // MARK: Attribtues

  // The game board data
  public let board: Board

  // The battle this board is used with
  public let battle: Battle

  // The starting point for a swap-to-be-done
  public var swapFromColumn: Int?
  public var swapFromRow: Int?

  // The sprite which is drawn over pieces when selected
  public var highlightSprite = SKSpriteNode()

  // The layer holding all our pieces
  public let pieceLayer = SKNode()

  // The layer containing the crop area for our whole board
  public let cropLayer = SKCropNode()

  // The size of a single tile
  public let pieceWidth: CGFloat
  public let pieceHeight: CGFloat

  public var pieceSize: CGSize {
    return CGSize(width: pieceWidth, height: pieceHeight)
  }

  // MARK: Initializers

  public init(size: CGSize, battle: Battle)
  {
    // Initialize board
    board = Board()

    // Save battle reference
    self.battle = battle

    // Calculate tile size
    pieceWidth  = size.width / CGFloat(board.columns)
    pieceHeight = size.height / CGFloat(board.rows)

    // Initialize everything else
    super.init()
    postInit()
  }

  required public init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) is not used")
  }

  // Post-init setup stuff
  public func postInit()
  {
    // Calculate layer positions
    let position: CGPoint = CGPoint(
      x: 0,
      y: -self.frame.height
    )

    // Enable user interaction for touch events
    userInteractionEnabled = true

    // Add a crop layer to prevent peice from showing across gaps
    addChild(cropLayer)

    // Piece layer contains the board pieces
    pieceLayer.position = position
    cropLayer.addChild(pieceLayer)

    swapFromColumn = nil
    swapFromRow = nil
  }

  // MARK: Board tile management

  public func addSpritesForPieces(pieces: Set<Piece>)
  {
    for piece in pieces {
      // Create a new piece sprite and add it to the layer
      let sprite = SKSpriteNode(imageNamed: piece.type.name)
      sprite.size = pieceSize
      sprite.position = pointForColumn(piece.column, row: piece.row)
      pieceLayer.addChild(sprite)
      piece.sprite = sprite

      sprite.alpha = 0
      sprite.setScale(0.5)
      sprite.runAction(
        SKAction.sequence([
          SKAction.waitForDuration(0.15, withRange: 0.5),
          SKAction.group([
            SKAction.fadeInWithDuration(0.15),
            SKAction.scaleTo(1.0, duration: 0.15)
            ])
          ])
      )
    }
  }

  // Clear the sprites for all the pieces
  public func removeAllPieceSprites()
  {
    pieceLayer.removeAllChildren()
  }

  // MARK: Utility methods

  // Converts a column, row pair into a CGPoint that is relative to the pieceLayer
  func pointForColumn(column: Int, row: Int) -> CGPoint {
    return CGPoint(
      x: CGFloat(column) * pieceWidth + pieceWidth  / 2,
      y: CGFloat(row)    * pieceHeight + pieceHeight / 2
    )
  }

  // Converts a point relative to the pieceLayer into column and row numbers
  func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
    // Is this a valid location within the pieces layer? If yes, calculate the
    // corresponding row and column numbers.
    if point.x >= 0 && point.x < CGFloat(board.columns) * pieceWidth &&
      point.y >= 0 && point.y < CGFloat(board.rows) * pieceHeight {
        return (true, Int(point.x / pieceWidth), Int(point.y / pieceHeight))
    }
    else {
      return (false, 0, 0) // Invalid location
    }
  }
}

// MARK: Touch Handling

public extension BoardNode
{

  override public func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    let touch    = touches.anyObject() as UITouch
    let location = touch.locationInNode(pieceLayer)

    let (success, col, row) = convertPoint(location)
    if success {
      if let piece = board.pieceAtColumn(col, row: row) {
        swapFromColumn = col
        swapFromRow = row
      }
    }
  }

  override public func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    // If swapFromColumn is nil, bail out
    if swapFromColumn == nil { return }

    let touch    = touches.anyObject() as UITouch
    let location = touch.locationInNode(pieceLayer)

    let (success, col, row) = convertPoint(location)
    if success {
      // Figure out in which direction the player swiped. Diagonal not allowed
      var horizontalDelta = 0, verticalDelta = 0

      if col < swapFromColumn! {
        horizontalDelta = -1
      } else if col > swapFromColumn! {
        horizontalDelta = 1
      } else if row < swapFromRow! {
        verticalDelta = -1
      } else if row > swapFromRow! {
        verticalDelta = 1
      }

      // Only try swapping when the user swiped into a new square
      if horizontalDelta != 0 || verticalDelta != 0 {
        // Attempt swap
        attemptMoveHorizontal(horizontalDelta, vertical: verticalDelta)

        // TODO: Hide selection indicator

        // Ignore the rest of this swipe motion from now on
        swapFromColumn = nil
      }
    }
  }

  override public func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    // Remove the selection indicator with a fade-out. We only do it when the
    // user only tapped on a tile without swiping.
    if highlightSprite.parent != nil && swapFromColumn != nil {
      // TODO: Hide selection indicator
    }

    // If the gesture ended, reset starting col and row
    swapFromColumn = nil
    swapFromRow = nil
  }

  override public func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    touchesEnded(touches, withEvent: event)
  }

  // 1) swap the pieces, 2) remove the matching chains, 3) drop new pieces into
  // the screen, 4) check if they create new matches, and so on.
  func attemptMoveHorizontal(horizontalDelta: Int, vertical verticalDelta: Int)
  {
    let toColumn = swapFromColumn! + horizontalDelta
    let toRow    = swapFromRow! + verticalDelta

    // Going outside the bounds? Ignore the swipe.
    if toColumn < 0 || toColumn >= board.columns { return }
    if toRow < 0    || toRow >= board.rows { return }

    println("Attempting move from \(swapFromColumn!),\(swapFromRow!) to \(toColumn),\(toRow)")

    // Can't swap if there's no piece to swap with. Only happens with tile gaps
    // that are not yet implemented.
    if let toPiece = board.pieceAtColumn(toColumn, row: toRow) {
      if let fromPiece = board.pieceAtColumn(swapFromColumn!, row: swapFromRow!) {
        var swap = BoardMove(pieceA: fromPiece, pieceB: toPiece)
        if let scene = self.scene as? GameScene {
          scene.handleBoardMove(swap)
        }
      }
    }
  }
}

// MARK: Animations

public extension BoardNode
{

  // MARK: Animations

  func animateMove(move: BoardMove, isInvalid: Bool = false, completion: () -> ())
  {
    let spriteA = move.pieceA.sprite!
    let spriteB = move.pieceB.sprite!

    // Put the piece you started with on top
    spriteA.zPosition = 100
    spriteB.zPosition = 90

    let moveA = SKAction.moveTo(spriteB.position, duration: BoardNode.defaultAnimationDuration())
    let moveB = SKAction.moveTo(spriteA.position, duration: BoardNode.defaultAnimationDuration())
    moveA.timingMode = BoardNode.defaultAnimationTimingMode()
    moveB.timingMode = BoardNode.defaultAnimationTimingMode()

    // Depending on the move type we have different actions

    var moveActionA: SKAction {
      if isInvalid == true { return SKAction.sequence([moveA, moveB]) }
      else { return moveA }
    }

    var moveActionB: SKAction {
      if isInvalid == true { return SKAction.sequence([moveB, moveA]) }
      else { return moveB }
    }

    // Run the actions

    spriteA.runAction(moveActionA, completion: completion)
    spriteB.runAction(moveActionB)
  }

  // Animate out matched gems (scale down and disappear)
  func animateMatchedPieces(chains: Set<Chain>, completion: () -> ())
  {
    for chain in chains {
      for piece in chain.pieces {
        // Make sure we only animate out the pieces once. They can be animated
        // out twice in-case they belong to a mixed shape.
        if let sprite = piece.sprite {
          if sprite.actionForKey("removingFromBoard") == nil {
            let scaleAction = SKAction.scaleTo(0.1, duration: 0.25)
            scaleAction.timingMode = BoardNode.defaultAnimationTimingMode()

            sprite.runAction(SKAction.sequence([
              scaleAction,
              SKAction.removeFromParent()
            ]), withKey: "removingFromBoard")

          }
        }
      }

      // Send events to battle
      self.battle.handleMatchedChain(chain)
    }

    // Continue with the game after animations have completed
    runAction(SKAction.waitForDuration(0.2), completion: completion)
  }

  // Animate falling down pieces

  func animateFallingPieces(columns: [[Piece]], completion: () -> ())
  {
    var longestDuration: NSTimeInterval = 0
    for array in columns {
      for (idx, piece) in enumerate(array) {
        let newPosition = pointForColumn(piece.column, row: piece.row)

        // The further away from the hole you are, the bigger the delay on
        // the animation.
        let delay = 0.1 * NSTimeInterval(idx)
        let sprite = piece.sprite!

        // Calculate duration based on far piece has to fall (0.1 seconds
        // per tile).
        let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / pieceHeight) * 0.05)
        longestDuration = max(longestDuration, duration + delay)

        let moveAction = SKAction.moveTo(newPosition, duration: duration)
        moveAction.timingMode = .EaseOut

        sprite.runAction(SKAction.sequence([
          SKAction.group([
            moveAction
          ])
        ]))
      }
    }

    completion()
  }

  // Animate new pieces from the top
  func animateNewPieces(columns: [[Piece]], completion: () -> ())
  {
    // We don't want to continue with the game until all the animations are
    // complete, so we calculate how long the longest animation lasts, and
    // wait that amount before we trigger the completion block.
    // TODO: Or do we?
    var longestDuration: NSTimeInterval = 0

    for array in columns {
      // The new sprite should start out just above the first tile in this column.
      // An easy way to find this tile is to look at the row of the first piece
      // in the array, which is always the top-most one for this column.
      let startRow = array[0].row + 1

      for (idx, piece) in enumerate(array) {

        // Create a new sprite for the piece.
        let sprite = SKSpriteNode(imageNamed: piece.type.name)
        sprite.size = pieceSize
        sprite.position = pointForColumn(piece.column, row: startRow)

        pieceLayer.addChild(sprite)
        piece.sprite = sprite

        // Give each piece that's higher up a longer delay, so they appear to
        // fall after one another.
        let delay = 0.1 + 0.15 * NSTimeInterval(array.count - idx - 1)

        // Calculate duration based on far the piece has to fall.
        let duration = NSTimeInterval(startRow - piece.row) * 0.08
        longestDuration = max(longestDuration, duration + delay)

        // Animate the sprite falling down. Also fade it in to make the sprite
        // appear less abruptly.
        let newPosition = pointForColumn(piece.column, row: piece.row)
        let moveAction = SKAction.moveTo(newPosition, duration: duration)
        moveAction.timingMode = .EaseOut

        sprite.alpha = 0
        sprite.runAction(SKAction.sequence([
          SKAction.waitForDuration(delay),
          SKAction.group([
            SKAction.fadeInWithDuration(0.05),
            moveAction
          ])
        ]))
      }
    }

    // Wait until the animations are done before we continue.
    runAction(SKAction.waitForDuration(longestDuration), completion: completion)
  }

  func animateInitialBoard(completion: () -> ()) {
    self.hidden = false
    self.position = CGPoint(x: 0, y: self.frame.size.height)

    let action = SKAction.moveBy(CGVector(dx: 0, dy: -self.frame.size.height), duration: 0.3)
    action.timingMode = .EaseInEaseOut
    runAction(action, completion: completion)
  }
}

