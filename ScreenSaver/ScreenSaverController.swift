//
//  ViewController.swift
//  ScreenSaver
//
//  Created by Mikhail Zoline on 7/9/17.
//  Copyright © 2017 MZ. All rights reserved.
//
//  At first it was a screen saver project with 'fake', that is to say a very simplistic
//  behavior of the collisions between particles and bounds. The both particles were spawned
//  with their raduis and the initial movemnt directions directly in code.
//  Subsequently I decided to implement the possibility to initialize the particles with
//  gesture of two fingers in order to vary the size. The switch for initialization is
//  doubletap, then two fingers, then doubletap again. Once the particle is initialized it can
//  be dragged and droped with one finger. It is necessary to do the same for the second
//  particle: doubletap, two fingers for the radius, doubletap,  drag and drop for the position.
//  Finally the direction of movemnt is given with a gesture of launching a particle with one
//  finger.

import UIKit

// Initialisation constants
fileprivate let paRadius : CGFloat = 55.0
fileprivate let pbRadius : CGFloat = 45.0

fileprivate let paInitPosition = CGVector(dx: 25.0, dy: 475.0)
fileprivate let pbInitPosition = CGVector(dx: 300.0, dy: 25.0)

fileprivate let paInitialVelocity = CGVector(dx: 0.050, dy: 0.090)
fileprivate let pbInitialVelocity = CGVector(dx: -0.075, dy: -0.085)

fileprivate let CGVectorZero = CGVector(dx: 0, dy: 0)

fileprivate let PI_180 = Double.pi/180
fileprivate let PI_2 = Double.pi*2.0

fileprivate let pAccelerationThresh: UInt64 = 140000
fileprivate let pVelocityScale: CGFloat = 0.1
fileprivate let pDistanceThresh: CGFloat = 10.0

class ScreenSaverController: UIViewController {
    
    fileprivate var pTimer = Timer()
    
    fileprivate var pA:CollisionParticle? = nil
    fileprivate var pB:CollisionParticle? = nil
    
    fileprivate var pCircleMode:Bool = false

    fileprivate var pPath: UIBezierPath? = nil
    fileprivate var pLayer:CAShapeLayer = CAShapeLayer()
    
    fileprivate var pRadius:Float = 60.0
    
    fileprivate var pOne:CGPoint = CGPoint()
    fileprivate var pTwo:CGPoint = CGPoint()
    
    fileprivate var pStart = DispatchTime.now()
    fileprivate var pStop = DispatchTime.now()
    
    let colorKeyframeAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize your drawing layer for drawing the circle to pick the size of the particle
        pLayer.strokeColor = UIColor .magenta.cgColor
        pLayer.lineWidth = 2.0
        pLayer.lineDashPattern = [2,3]
        pLayer.fillRule = kCAFillRuleEvenOdd
        pLayer.fillColor = UIColor.init(white: 1.0, alpha: 0.0).cgColor
        
        // Add drawing layer to main view
        view.layer.addSublayer(pLayer)
        
        //  tap to switch back and forth to Particle Initializing Mode
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ScreenSaverController.taptap))
        tapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGesture)
        
        // Init color animation of particles
        colorKeyframeAnimation.values = [UIColor.red.cgColor,
                                         UIColor.green.cgColor,
                                         UIColor.blue.cgColor,
                                         UIColor.orange.cgColor,
                                         UIColor.magenta.cgColor,
                                         UIColor.cyan.cgColor]
        colorKeyframeAnimation.keyTimes = [0, 0.5, 1, 1.5, 2, 2.5]
        colorKeyframeAnimation.duration = 3
        
    }
    
    internal func startTimer(){
        
        // Run Animation Loop
        pTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(ScreenSaverController.animation), userInfo: nil, repeats: true)
    }
    
    internal func stopTimer(){
        pTimer.invalidate()
    }
    
    //
    internal func animation(){
        
        // Move A and B according to their velocities
        pA?.step()
        pB?.step()
        
        // Detect the collision between particle A and B and view frame
        if(pA != nil ){
            _ = intersectWithFrame(view.bounds, pA!)
        }
        if(pB != nil ){
            _ = intersectWithFrame(view.bounds, pB!)
            
        }
        
        // Detect the collision between particles
        if(pB != nil && pA != nil){
            let collision:Bool = intersectWithCircle(pB!,pA!)
            
            if collision {
                // start color animation
                if (pA?.pAnimated)! {
                    pA?.pAnimated = false
                    pB?.pAnimated = true
                    pA?.pImage.layer.removeAllAnimations()
                    pB?.pImage.layer.add(colorKeyframeAnimation, forKey: "colors")
                }
                else{
                    pB?.pAnimated = false
                    pA?.pAnimated = true
                    pB?.pImage.layer.removeAllAnimations()
                    pA?.pImage.layer.add(colorKeyframeAnimation, forKey: "colors")
                }
            }

        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Single touch
        if (touches .count == 1){
            pOne = touches.first!.location(in: view)
            pStart = DispatchTime.now()
        }
        else{//Double touch
            for (index, aTouch) in touches.enumerated(){
                if(index == 0){
                    pOne = aTouch.location(in: view)
                }
                if(index == 1){
                    pTwo = aTouch.location(in: view)
                }
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Single touch
        if (touches .count == 1){
            pTwo = touches.first!.location(in: view)
            
            if(!pCircleMode){
                if((pA) != nil  && (pA?.pImage.frame)!.contains (pTwo)){
                    pA?.move(to: pTwo)
                }
                else if((pB) != nil  && (pB?.pImage.frame)!.contains (pTwo)){
                    pB?.move(to: pTwo)
                }
            }
        }
        else{//Double touch
            for (index, aTouch) in touches.enumerated(){
                if(index == 0){
                    pOne = aTouch.location(in: view)
                }
                if(index == 1){
                    pTwo = aTouch.location(in: view)
                }
                
            }// get the radius of a circle
            pRadius = pow( (pow(Float(pOne.x - pTwo.x),2) + pow(Float(pOne.y - pTwo.y), 2) ),0.5) * 0.5
            if(pCircleMode == true && (pA == nil || pB == nil) ){
                drawCircle()
            }
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Single touch
        if (touches .count == 1){
            pTwo = touches.first!.location(in: view)
        }
        else{//Double touch
            for (index, aTouch) in touches.enumerated(){
                if(index == 0){
                    pOne = aTouch.location(in: view)
                }
                if(index == 1){
                    pTwo = aTouch.location(in: view)
                }
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Single touch
        if (touches .count == 1){
            pTwo = touches.first!.location(in: view)
            
            pStop = DispatchTime.now()
            
            let nanoTime = pStop.uptimeNanoseconds - pStart.uptimeNanoseconds //
            
            let xcomp = pTwo.x - pOne.x ; let ycomp = pTwo.y - pOne.y
            
            let distance = sqrt(sqr(xcomp) + sqr(ycomp))
            
            if(distance > pDistanceThresh){
                
                let acceleration = nanoTime/UInt64(distance)
                
                
                if( acceleration > pAccelerationThresh && !pCircleMode){
                    if((pA) != nil  && (pA?.pImage.frame)!.contains (pTwo)){
                        let velocity = CGVector(dx: ((xcomp/distance) * pVelocityScale), dy: ((ycomp/distance)*pVelocityScale))
                        pA?.set(velocity: velocity)
//                        pA?.pImage.layer.add(colorKeyframeAnimation, forKey: "colors")

                        // Start Animation
                        startTimer()
                    }
                    else if((pB) != nil  && (pB?.pImage.frame)!.contains (pTwo)){
                        let velocity = CGVector(dx: ((xcomp/distance) * pVelocityScale), dy: ((ycomp/distance)*pVelocityScale))
                        pB?.set(velocity: velocity)
                        
                        // Start Animation
                        startTimer()
                    }
                    
                }
            }
        }
        else{
            
            for (index, aTouch) in touches.enumerated(){
                if(index == 0){
                    pOne = aTouch.location(in: view)
                }
                if(index == 1){
                    pTwo = aTouch.location(in: view)
                }
            }
        }
        
    }
    
    private func drawCircle() {
        pPath = UIBezierPath.init(arcCenter: view.center, radius: CGFloat(pRadius), startAngle: 0, endAngle: CGFloat(Float.pi*2), clockwise: true)
        
        // Tell to drawing layer to update the drawing path
        pLayer.path = (pPath?.cgPath)
    }
    
    @objc private func taptap() {
        if ( pCircleMode == false ){
            pCircleMode = true
            stopTimer()
        }
        else{
            pCircleMode = false
            if (pA == nil && pB == nil){
                pA = CollisionParticle (with: CGFloat(pRadius), initialVelocity: CGVectorZero, initialPosition: view.center, color: UIColor.red, view: view)
                pA?.pAnimated = true
                pPath?.removeAllPoints()
                pLayer.path = (pPath?.cgPath)
                return
            }
            if( pA != nil && pB == nil){
                pB = CollisionParticle (with: CGFloat(pRadius), initialVelocity: CGVectorZero, initialPosition: view.center, color: UIColor.blue, view: view)
                pPath?.removeAllPoints()
                pLayer.path = (pPath?.cgPath)
                return
            }
            if( pA != nil && pB != nil){
                // Start Animation
                startTimer()
            }
            
        }
    }
}
