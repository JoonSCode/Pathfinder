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

        startNavigatingButton.isHidden = false
    }
}
