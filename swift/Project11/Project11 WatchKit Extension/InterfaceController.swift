//
//  InterfaceController.swift
//  Project11 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/31/21.
//

import WatchKit
import Foundation
import SpriteKit

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var gameInterface: WKInterfaceSKScene!
    var gameScene: GameScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        startGame(self)
    }
    
    override func didAppear() {
        super.didAppear()
        crownSequencer.focus()
    }

    @IBAction func startGame(_ sender: Any) {
        if gameScene != nil {
            guard gameScene.isPlayerAlive == false else { return }
        }
        
        gameScene = GameScene(size: CGSize(width: contentFrame.width, height: contentFrame.height))
        gameScene.parentInterfaceController = self
        gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let transition = SKTransition.doorway(withDuration: 1)
        crownSequencer.delegate = gameScene
        gameInterface.presentScene(gameScene, transition: transition)
    }
}
