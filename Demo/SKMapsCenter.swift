//
//  SKMapsCenter.swift
//  Demo
//
//  Created by Anders Klausen on 17/01/15.
//  Copyright (c) 2014 Anders Klausen. All rights reserved.
//

import Foundation
import MapKit

let outerCircleView_widthAndHeight: CGFloat = 172
let innerCircleView_widthAndHeight: CGFloat = 20
let greenColor: UIColor = UIColor(red: 36.0/255.0, green: 162.0/255.0, blue: 121.0/255.0, alpha: 1.0)

class SKMapsCenter: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    var mapView: MKMapView!
    var layerView: UIView!
    var outerCircleView: UIView!
    var innerCircleView_animate: UIView!
    var innerCircleView_static: UIView!
    
    var lastScale: CGFloat!
    
    var tapOneActivated: Bool = false
    var tapTwoActivated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Properties for mapView
        mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
        mapView.centerCoordinate = CLLocationCoordinate2DMake(37.364612, -122.034747)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, 5000, 5000), animated: true)
        mapView.userInteractionEnabled = false
        mapView.delegate = self
        
        // Properties for layerView
        layerView = UIView(frame: UIScreen.mainScreen().bounds)
        layerView.backgroundColor = greenColor
        layerView.alpha = 0.65
        
        // Properties for outerCircleView
        outerCircleView = UIView(frame: CGRectMake((self.view.frame.size.width/2) - (outerCircleView_widthAndHeight/2), (self.view.frame.size.height/2) - (outerCircleView_widthAndHeight/2), outerCircleView_widthAndHeight, outerCircleView_widthAndHeight))
        outerCircleView.backgroundColor = greenColor
        outerCircleView.userInteractionEnabled = false
        outerCircleView.alpha = 0.25
        
        // Properties for innerCircleView_animate
        innerCircleView_animate = UIView(frame: CGRectMake((self.view.frame.size.width/2) - (innerCircleView_widthAndHeight/2), (self.view.frame.size.height/2) - (innerCircleView_widthAndHeight/2), innerCircleView_widthAndHeight, innerCircleView_widthAndHeight))
        innerCircleView_animate.layer.cornerRadius = 10
        innerCircleView_animate.backgroundColor = UIColor.whiteColor()
        innerCircleView_animate.userInteractionEnabled = false
        innerCircleView_animate.alpha = 0.2
        
        // Properties for innerCircleView_static
        innerCircleView_static = UIView(frame: CGRectMake((self.view.frame.size.width/2) - (innerCircleView_widthAndHeight/2), (self.view.frame.size.height/2) - (innerCircleView_widthAndHeight/2), innerCircleView_widthAndHeight, innerCircleView_widthAndHeight))
        innerCircleView_static.layer.cornerRadius = innerCircleView_animate.layer.cornerRadius
        innerCircleView_static.backgroundColor = innerCircleView_animate.backgroundColor
        innerCircleView_static.userInteractionEnabled = false
        innerCircleView_static.opaque = true
        
        // Pinch gesture: Pinching while maintaining users center position on the mapView
        var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "didReceivePinch:")
        pinchGestureRecognizer.delegate = self
        layerView.addGestureRecognizer(pinchGestureRecognizer)
        
        // One finger tap gesture: Used to zoom in on the mapView
        var tapOneGestureRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveTapOne:")
        tapOneGestureRecognizer.delegate = self
        tapOneGestureRecognizer.numberOfTapsRequired = 2
        layerView.addGestureRecognizer(tapOneGestureRecognizer)
        
        // Two finger tap gesture: Used to zoom out on the mapView
        var tapTwoGestureRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveTapTwo:")
        tapTwoGestureRecognizer.delegate = self
        tapTwoGestureRecognizer.numberOfTouchesRequired = 2
        layerView.addGestureRecognizer(tapTwoGestureRecognizer)
        
        // Add subviews
        self.view.addSubview(mapView)
        self.view.addSubview(layerView)
        self.view.addSubview(outerCircleView)
        self.view.addSubview(innerCircleView_animate)
        self.view.addSubview(innerCircleView_static)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Extra properties for outerCircleView
        outerCircleView.layer.borderWidth = 0.5
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
        innerCircleView_animate.layer.addAnimation(scaleAnimation, forKey: "scaleAnimation")
        innerCircleView_animate.layer.addAnimation(opacityAnimation, forKey: "opacityAnimation")
        
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