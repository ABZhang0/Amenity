//
//  MainTabBarController.swift
//  Amenity
//
//  Created by Alan Zhang on 2020-02-27.
//  Copyright © 2020 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var amenities: [(MKAnnotation, String)] = []
    
    let mapViewController = MapViewController()
    let amenityTableViewController = AmenityTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        mapViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        
        let amenityTableNavigationController = UINavigationController(rootViewController: amenityTableViewController)
        amenityTableNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
        
        let dummyViewController = UIViewController()
        dummyViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        viewControllers = [ amenityTableNavigationController, mapViewController, dummyViewController ]
        
        selectedIndex = 1
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = tabBarController.viewControllers?.lastIndex(of: viewController)
        if (index == 2) {
            let addAmenityViewController = AddAmenityViewController()
            addAmenityViewController.delegate = self
            let addAmenityNavigationController = UINavigationController(rootViewController: addAmenityViewController)
            addAmenityViewController.mapView.addAnnotations(amenities.map { (annotation, address) in annotation })
            
            addAmenityNavigationController.modalPresentationStyle = .fullScreen
            tabBarController.present(addAmenityNavigationController, animated: true, completion: nil)

            return false
        }
        
        return true
    }
}

extension MainTabBarController: AddAmenityViewControllerDelegate {
    func amenitySelected(amenityType: String, description: String, location: CLLocation, address: String) {
        let locationAnnotation = LocationAnnotation(coordinate: location.coordinate, title: amenityType, subtitle: description)
        
        amenities.append((annotation: locationAnnotation, address: address))
        
        mapViewController.mapView.addAnnotation(locationAnnotation)
        
        amenityTableViewController.appendAmenity(annotation: locationAnnotation, address: address)
    }
}
