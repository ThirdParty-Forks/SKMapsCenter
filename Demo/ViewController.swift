//
//  ViewController.swift
//  Demo
//
//  Created by Anders Klausen on 17/01/15.
//  Copyright (c) 2014 Anders Klausen. All rights reserved.
//

import Foundation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var innerCircleView: UIView!
    @IBOutlet weak var outerCircleView: UIView!
    
    var lastScale: CGFloat!
    
    var tapOneActivated: Bool = false
    var tapTwoActivated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial properties for mapView
        mapView.centerCoordinate = CLLocationCoordinate2DMake(37.364612, -122.034747)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, 5000, 5000), animated: true)
        mapView.delegate = self
        
        // Pinch gesture: Pinching while maintaining users center position on the mapView
        var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "didReceivePinch:")
        pinchGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(pinchGestureRecognizer)
        
        // One finger tap gesture: Used to zoom in on the mapView
        var tapOneGestureRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveTapOne:")
        tapOneGestureRecognizer.delegate = self
        tapOneGestureRecognizer.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tapOneGestureRecognizer)
        
        // Two finger tap gesture: Used to zoom out on the mapView
        var tapTwoGestureRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveTapTwo:")
        tapTwoGestureRecognizer.delegate = self
        tapTwoGestureRecognizer.numberOfTouchesRequired = 2
        mapView.addGestureRecognizer(tapTwoGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Properties
        outerCircleView.layer.borderColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6).CGColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Scaling animation
        var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 1.35
        scaleAnimation.repeatCount = 100000
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 3.0
        
        // Opacity animation
        var opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 1.35
        opacityAnimation.repeatCount = 100000
        opacityAnimation.fromValue = 0.2
        opacityAnimation.toValue = 0.0
        
        // Add animations to the innerCircleView
        innerCircleView.layer.addAnimation(scaleAnimation, forKey: "scaleAnimation")
        innerCircleView.layer.addAnimation(opacityAnimation, forKey: "opacityAnimation")
        
        // UI, outerCircleView
        self.outerCircleView.layer.cornerRadius = self.outerCircleView.frame.size.height / 2
    }
    
    // Similar pinching experience to the Maps application
    func didReceivePinch(sender: UIPinchGestureRecognizer) {
        
        // Remember last scale
        if sender.state == UIGestureRecognizerState.Began {
            lastScale = sender.scale
        }
        
        if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
            
            let maxScale: Double = 10
            let minScale: Double = 0.01
            let newScale: Double = Double(1 - (lastScale - sender.scale))
            
            var latitudeDelta: Double = mapView.region.span.latitudeDelta / newScale
            var longitudeDelta: Double = mapView.region.span.longitudeDelta / newScale
            
            latitudeDelta = max(min(latitudeDelta, maxScale), minScale)
            longitudeDelta = max(min(longitudeDelta, maxScale), minScale)
            
            mapView.setRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(latitudeDelta, longitudeDelta)), animated: false)
            lastScale = sender.scale
        }
    }
    
    // Similar one-finger zoom-in experience to the Maps application
    func didReceiveTapOne(sender: UITapGestureRecognizer) {
        
        tapOneActivated = true
        mapView.delegate = self
        
        let maxScale: Double = 10
        let minScale: Double = 0.01
        
        var latitudeDelta: Double = mapView.region.span.latitudeDelta / 2
        var longitudeDelta: Double = mapView.region.span.longitudeDelta / 2
        
        latitudeDelta = max(min(latitudeDelta, maxScale), minScale)
        longitudeDelta = max(min(longitudeDelta, maxScale), minScale)
        
        mapView.setRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(latitudeDelta, longitudeDelta)), animated: true)
    }
    
    // Similar two-finger zoom-out experience to the Maps application
    func didReceiveTapTwo(sender: UITapGestureRecognizer) {
        
        tapTwoActivated = true
        mapView.delegate = self
        
        let maxScale: Double = 10
        let minScale: Double = 0.01
        
        var latitudeDelta: Double = mapView.region.span.latitudeDelta * 2
        var longitudeDelta: Double = mapView.region.span.longitudeDelta * 2
        
        latitudeDelta = max(min(latitudeDelta, maxScale), minScale)
        longitudeDelta = max(min(longitudeDelta, maxScale), minScale)
        
        mapView.setRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(latitudeDelta, longitudeDelta)), animated: true)
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        
        // Activations
        if self.tapOneActivated == true {
            self.tapOneActivated = false
        } else if self.tapTwoActivated == true {
            self.tapTwoActivated = false
        }
        
        // Remove delegate again
        mapView.delegate = nil
    }
}