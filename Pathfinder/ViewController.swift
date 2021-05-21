//
//  ViewController.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import UIKit
import NMapsMap
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    var locationManager: CLLocationManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
//        print(locationManager.location)
        naverMapView.showLocationButton = true
        // Do any additional setup after loading the view.
//        let mapView = NMFMapView(frame: view.frame)
//        view.addSubview(mapView)
    }


}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.count != 0 else { return }
        let location = locations[0]
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude))
        naverMapView.mapView.moveCamera(cameraUpdate)
    }
}

