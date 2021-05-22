//
//  MainViewController+SearchPathProtocol.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import Foundation
import NMapsMap

extension MainViewController: SearchResultViewDelegate {
    func didCellClicked(indexPath: IndexPath) {
        if indexPath.row < 0 || indexPath.row > viewModel.placeDatas.value.count { return }
        let destinationPoi = viewModel.placeDatas.value[indexPath.row]
        guard let currentLocation = locationManager.location else { return }
        let startPoi = Poi(name: "현재위치", latitude: "\(currentLocation.coordinate.latitude)", longitude: "\(currentLocation.coordinate.longitude)", distance: "")

        self.startPoi = startPoi
        self.destinationPoi = destinationPoi

        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(from: currentLocation.coordinate), zoom: 15)))

        resultContainerView.isHidden = true
        searchBar.isHidden = true
        searchPathConfirmView.isHidden = false
        startName.text = "현재위치"
        destinationName.text = destinationPoi.name
        
        clearOverlay(overlays: obstacleMarkers)
        clearOverlay(overlays: dangerMarkers)
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: Double(destinationPoi.latitude)!, lng: Double(destinationPoi.longitude)!), zoom: 17)))
        
        let destinationMarker = NMFMarker(position: NMGLatLng(lat: Double(destinationPoi.latitude)!, lng: Double(destinationPoi.longitude)!))
        destinationMarker.width = 25
        destinationMarker.height = 25
        destinationMarker.mapView = naverMapView.mapView
        obstacleMarkers.append(destinationMarker)
        let startMarker = NMFMarker(position: NMGLatLng(lat: currentLocation.coordinate.latitude, lng: currentLocation.coordinate.longitude))
        startMarker.width = 25
        startMarker.height = 25
        startMarker.mapView = naverMapView.mapView
        obstacleMarkers.append(startMarker)
        
        startNavigatingButton.isHidden = false
    }
}
