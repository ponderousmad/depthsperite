//
//  CaptureViewController.swift
//  PairedCapture
//
//  Created by Adrian Smith on 2016-01-16.
//  Copyright © 2016 Adrian Smith. All rights reserved.
//

import Foundation


extension Double {
    func out() -> String {
        return String(format: "%+.1f", self)
    }
}

class CaptureViewController: UIViewController, SensorObserverDelegate {
    
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var capturedDepth: UIImageView!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var captureCountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusHistory: UILabel!
    var sensor : StructureSensor?
    var captureCount = 0
    var attitudeText = ""
    
    var lastMinPan : Float = 0
    var lastMaxPan : Float = 0
    let velocityScale : Float = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        statusHistory.lineBreakMode = .byWordWrapping
        statusHistory.numberOfLines = 0
        statusHistory.isHidden = true
        
        sensor = StructureSensor(observer: self);
        
        let statusSwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(CaptureViewController.swipeStatus(_:)));
        statusSwipeDown.direction = .down
        statusLabel.addGestureRecognizer(statusSwipeDown)
        let statusSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(CaptureViewController.swipeStatus(_:)));
        statusSwipeUp.direction = .up
        statusLabel.addGestureRecognizer(statusSwipeUp)
    }
    
    func activateSensor() {
        sensor?.tryReconnect()
    }
    
    func swipeStatus(_ sender: UISwipeGestureRecognizer) {
        if (sender.direction == .up) {
            statusHistory.isHidden = true
        } else if(sender.direction == .down) {
            statusHistory.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CaptureViewController.activateSensor), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        activateSensor()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func statusChange(_ status: String) {
        if statusLabel.text != status {
            statusLabel.text = status;
            if let text = statusHistory.text {
                statusHistory.text = text + "\n" + status
            } else {
                statusHistory.text = status;
            }
        }
    }
    
    func captureDepth(_ image: UIImage!) {
        capturedDepth.image = image
    }
    
    func captureImage(_ image: UIImage!) {
        capturedImage.image = image
    }
    
    func captureStats(_ centerDepth: Float) {
        let mm2m : Float = 0.001
        var min : Float = 0
        var max : Float = StructureSensor.maxValidDepth
        if let s = sensor {
            min = round(s.depthMin) * mm2m
            max = round(s.depthMax) * mm2m
        }
        statsLabel.text = "\(round(centerDepth) * mm2m) m [\(min), \(max)]" +
            (attitudeText.isEmpty ? "" : ", " + attitudeText)
    }
    
    func captureAttitude(_ attitude: CMAttitude) {
        let toDegrees = 180.0 / Double.pi
        let roll = attitude.roll * toDegrees
        let pitch = attitude.pitch * toDegrees
        let yaw = attitude.yaw * toDegrees
        attitudeText = "Roll: \(roll.out()), Pitch: \(pitch.out()), Yaw: \(yaw.out())"
    }
    
    func saveComplete() {
        captureCount += 1
        captureCountLabel.text = "Captures: \(captureCount)";
    }
    
    @IBAction func saveCapture(_ sender: AnyObject) {
        sensor?.saveNext()
    }
    
    @IBAction func depthMaxPan(_ sender: UIPanGestureRecognizer) {
        let panLoc = Float(sender.location(in: sender.view).y)
        if sender.state == UIGestureRecognizerState.changed {
            let velocity = Float(abs(sender.velocity(in: sender.view).y))
            sensor?.depthRangeMax += (lastMinPan - panLoc) * velocity * velocityScale
        }
        lastMinPan = panLoc
        
    }
    
    @IBAction func depthMinPan(_ sender: UIPanGestureRecognizer) {
        let panLoc = Float(sender.location(in: sender.view).y)
        if sender.state == UIGestureRecognizerState.changed {
            let velocity = Float(abs(sender.velocity(in: sender.view).y))
            sensor?.depthRangeMin += (lastMaxPan - panLoc) * velocity * velocityScale
        }
        lastMaxPan = panLoc
    }
}
