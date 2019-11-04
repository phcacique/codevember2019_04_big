//
//  GameScene.swift
//  Big
//
//  Created by Pedro Cacique on 04/11/19.
//  Copyright © 2019 Pedro Cacique. All rights reserved.
//

import SpriteKit
import GameplayKit
import SwiftGameOfLifeCircular

class GameScene: SKScene {
    var grid = CircularGrid()
    var renderTime: TimeInterval = 0
    let duration: TimeInterval = 0.8
    var nodes:[SKShapeNode] = []
    var centerGOL:CGPoint = CGPoint.zero
    let colors:[UIColor] = [ UIColor(red:247/255, green:215/255, blue:148/255, alpha: 1),
                             UIColor(red:243/255, green:166/255, blue:131/255, alpha: 1),
                             UIColor(red:119/255, green:139/255, blue:235/255, alpha: 1),
                             UIColor(red:231/255, green:127/255, blue:103/255, alpha: 1),
                             UIColor(red:207/255, green:106/255, blue:135/255, alpha: 1)
    ]
    
    func setup(){
        self.backgroundColor = UIColor(red:48/255, green:57/255, blue:82/255, alpha: 1)
        
        grid = CircularGrid(numSectors: 180, numCircles: 20, isRandom: true, proportion: 50)
        grid.addRule(CountRule(name: "Solitude", startState: .alive, endState: .dead, count: 2, type: .lessThan))
        grid.addRule(CountRule(name: "Survive2", startState: .alive, endState: .alive, count: 2, type: .equals))
        grid.addRule(CountRule(name: "Survive3", startState: .alive, endState: .alive, count: 3, type: .equals))
        grid.addRule(CountRule(name: "Overpopulation", startState: .alive, endState: .dead, count: 3, type: .greaterThan))
        grid.addRule(CountRule(name: "Birth", startState: .dead, endState: .alive, count: 3, type: .equals))
    }
    
    override func didMove(to view: SKView) {
        centerGOL = CGPoint(x:self.size.width/2, y:self.size.height/2)
        restart()
    }
    
    func restart(){
        removeAllActions()
        removeAllChildren()
        setup()
        showGen()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setup()
        restart()
    }
    
    func showGen(){
        let h:CGFloat = 20
        var angle:CGFloat = 0
        let step:CGFloat = CGFloat(360/grid.numSectors) * .pi / CGFloat(180)
        let radius:CGFloat = 20
        
        for j in 0..<grid.numCircles{
            for i in 0..<grid.numSectors{
                if grid.cells[i][j].state == .alive {
                    let x = centerGOL.x + (CGFloat(j) * h) * cos(angle)
                    let y = centerGOL.y + (CGFloat(j) * h) * sin(angle)
                    showEntity(pos: CGPoint(x: x, y: y), radius: radius * CGFloat(j)/5, color:colors[Int.random(in: 0..<colors.count)])
                }
                angle += step
            }
        }
    }
    
    func showEntity(pos:CGPoint, radius:CGFloat = 1, color:UIColor = .yellow){
        let node:SKShapeNode = SKShapeNode(circleOfRadius: radius)
        node.fillColor = color
        node.lineWidth = 0
        node.position = pos
        node.alpha = 0
        node.zPosition = CGFloat(0) - CGFloat((grid.numCircles * grid.numSectors))
        addChild(node)
        
        let d = Double.random(in: 2...8)*duration
        node.run(SKAction.sequence([SKAction.wait(forDuration: Double.random(in: 0...0.3)*duration),
                                SKAction.fadeAlpha(to: CGFloat.random(in: 0.1...0.7), duration: d/2),
                                   SKAction.group([SKAction.fadeAlpha(to: 0, duration: d),
                                                   SKAction.scale(by: CGFloat.random(in: 2...4), duration: d)
                                    ]),
                                    SKAction.removeFromParent()]) )
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        if currentTime > renderTime {
            grid.applyRules()
            showGen()
            renderTime = currentTime + duration
        }
    }
}
