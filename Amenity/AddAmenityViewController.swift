//
//  AddAmenityViewController.swift
//  Amenity
//
//  Created by Alan Zhang on 2020-02-27.
//  Copyright © 2020 Alan Zhang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol AddAmenityViewControllerDelegate: class {
    func amenitySelected(amenityType: String, description: String, location: CLLocation, address: String)
}

class AddAmenityViewController: UIViewController {
    
    weak var delegate: AddAmenityViewControllerDelegate?
    
    var mapView = MKMapView()
    
    let locationManager = CLLocationManager()
    let regionMeters: Double = 500
    var previousLocation: CLLocation?
    
    let amenityTypes = ["Toilet", "Fountain", "Microwave", "Other"]
    let amenityTypeSC = UISegmentedControl()
    var amenityTypeTextField = UITextField()
    var descriptionTextField = UITextField()
    let innerStackView = UIStackView()
    
    let addButton = UIButton(type: .system)
    var addressLabel = UILabel()
    
    let mapPinSize = CGFloat(7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userLocation.title = nil
        
        view.backgroundColor = .systemBackground
        
        title = "Add An Amenity"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        let amenityTypeLabel = UILabel()
        amenityTypeLabel.text = "Type of Amenity"
        amenityTypeLabel.textAlignment = .left
        amenityTypeLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        amenityTypeLabel.textColor = .label
        
        amenityTypes.enumerated().forEach { (index, amenityType) in amenityTypeSC.insertSegment(withTitle: amenityType, at: index, animated: false) }
        amenityTypeSC.selectedSegmentIndex = 0
        amenityTypeSC.addTarget(self, action: #selector(amenityTypeTapped), for: .valueChanged)
        
        amenityTypeTextField = UITextField()
        amenityTypeTextField.font = UIFont(name: "HelveticaNeue", size: 18)
        amenityTypeTextField.placeholder = "Enter type of amenity"
        amenityTypeTextField.delegate = self
        amenityTypeTextField.textColor = .label
        amenityTypeTextField.isHidden = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Description"
        descriptionLabel.textAlignment = .left
        descriptionLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        descriptionLabel.textColor = .label
        
        descriptionTextField = UITextField()
        descriptionTextField.font = UIFont(name: "HelveticaNeue", size: 18)
        descriptionTextField.placeholder = "Enter description"
        descriptionTextField.delegate = self
        descriptionTextField.textColor = .label
        
        innerStackView.axis = .vertical
        innerStackView.alignment = .leading
        innerStackView.distribution = .fill
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.spacing = 5
        innerStackView.preservesSuperviewLayoutMargins = true
        innerStackView.isLayoutMarginsRelativeArrangement = true
        [amenityTypeLabel, amenityTypeSC, amenityTypeTextField, descriptionLabel, descriptionTextField].forEach(innerStackView.addArrangedSubview)
        innerStackView.setCustomSpacing(10, after: amenityTypeSC)
        
        addressLabel.textAlignment = .center
        addressLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
        addressLabel.textColor = .label
        
        addButton.backgroundColor = .clear
        addButton.layer.cornerRadius = 20
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), for: .normal)
//        addButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .highlighted)
        addButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 24)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
                
        let outerStackView = UIStackView(arrangedSubviews: [innerStackView, mapView, addressLabel, addButton])
        outerStackView.axis = .vertical
        outerStackView.alignment = .center
        outerStackView.distribution = .equalSpacing
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.preservesSuperviewLayoutMargins = true
        view.addSubview(outerStackView)
        
        let mapPinLabel = UILabel()
        mapPinLabel.layer.masksToBounds = true
        mapPinLabel.layer.cornerRadius = mapPinSize / 2
        mapPinLabel.backgroundColor = .red
        
        view.addSubview(mapPinLabel)
        mapPinLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            outerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            outerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            outerStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            outerStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            outerStackView.leftAnchor.constraint(equalTo: innerStackView.leftAnchor),
            mapView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            addButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            mapPinLabel.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            mapPinLabel.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
            mapPinLabel.widthAnchor.constraint(equalToConstant: mapPinSize),
            mapPinLabel.heightAnchor.constraint(equalToConstant: mapPinSize)
        ])
        
        checkLocationServices()
    }
    
    @objc func amenityTypeTapped() {
        if amenityTypeSC.selectedSegmentIndex == 3 && amenityTypeTextField.isHidden {
            UIView.animate(withDuration: 0.25) {
                self.amenityTypeTextField.isHidden = false
                self.innerStackView.setCustomSpacing(5, after: self.amenityTypeSC)
                self.innerStackView.setCustomSpacing(10, after: self.amenityTypeTextField)
            }
        } else if !amenityTypeTextField.isHidden {
            UIView.animate(withDuration: 0.25) {
                self.amenityTypeTextField.isHidden = true
                self.innerStackView.setCustomSpacing(10, after: self.amenityTypeSC)
                self.innerStackView.setCustomSpacing(0, after: self.amenityTypeTextField)
            }
        }
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addButtonTapped() {
        var amenityType = amenityTypes[amenityTypeSC.selectedSegmentIndex]
        if amenityType == "Other" {
            amenityType = amenityTypeTextField.text ?? ""
        }
        
        if amenityType.isEmpty { return }
        
        delegate?.amenitySelected(amenityType: amenityType, description: descriptionTextField.text ?? "", location: previousLocation!, address: addressLabel.text ?? "")
        // TODO: fix force unwrap CLLocation
        dismiss(animated: true, completion: nil)
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            configureLocationManager()
            checkLocationAuthorization()
        } else {
            //
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            previousLocation = getCenterLocation(for: mapView)
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension AddAmenityViewController: CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
//        mapView?.setRegion(region, animated: true)
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //
    }
}

extension AddAmenityViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let locationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView {
            locationAnnotationView.displayPriority = .required
            locationAnnotationView.animatesWhenAdded = true
            locationAnnotationView.titleVisibility = .adaptive
            
            return locationAnnotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // annotation selected
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                // TODO: show alert to user
                return
            }
            
            guard let placemark = placemarks?.first else {
                // TODO: show alert to user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
            
        }
    }
}

extension AddAmenityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
