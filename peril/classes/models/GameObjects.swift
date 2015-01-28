//
//  GameObject.swift
//  peril
//
//  Created by Nico Hämäläinen on 17/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Dollar

public typealias EventHandlerClosure = (battle: Battle, params: [String: AnyObject]) -> Void

// EventManager handles the forwarding and binding of events and their
// listener objects
public class GameObject: NSObject {

  // MARK: Attributes

  public var owner: Player?
  public var battle: Battle

  public var triggers: [GameEvent: [EventHandlerClosure]] = [:]

  // MARK: Initializers

  public init(battle: Battle) {
    self.battle = battle

    super.init()
  }

  // MARK: Handling Events

  public func bindEvent(gameEvent: GameEvent, handler: EventHandlerClosure) {
    if var eventTriggers = triggers[gameEvent] {
      eventTriggers.append(handler)
      println("Bound event for \(gameEvent)")
    }
  }

  public func fireEvent(gameEvent: GameEvent, params: [String: AnyObject] = [:]) {
    if let eventTriggers = triggers[gameEvent] {
      for trigger in eventTriggers {
        trigger(battle: battle, params: params)
        println("Fired event for \(gameEvent)")
      }
    }
  }
}