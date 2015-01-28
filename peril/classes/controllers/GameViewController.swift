//
//  GameViewController.swift
//  peril
//
//  Created by Nico Hämäläinen on 14/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

  var scene: GameScene!

  // MARK: IBOutlets

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Hide labels initially
    titleLabel.layer.opacity = 0.0
    subtitleLabel.layer.opacity = 0.0

    // No multitouch support (yet)
    let skView = view as SKView
    skView.multipleTouchEnabled = false
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true

    // Create and configure the scene.
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .AspectFill

    // Present the scene.
    skView.presentScene(scene)

    scene.boardNode.animateInitialBoard { () -> () in
    }
    scene.shuffle()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func shouldAutorotate() -> Bool {
    return false
  }

  override func supportedInterfaceOrientations() -> Int {
    return Int(UIInterfaceOrientationMask.Portrait.rawValue)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

  // MARK: Animations

  func animateLabels() {
    UIView.animateWithDuration(0.5, delay: 0.5, options: .CurveEaseOut, animations: {
      self.titleLabel.layer.opacity = 1.0
      }, completion: nil)

    UIView.animateWithDuration(0.5, delay: 0.6, options: .CurveEaseOut, animations: {
      self.subtitleLabel.layer.opacity = 1.0
      }, completion: nil)
  }
}
