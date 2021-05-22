//
//  Repository.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import Foundation
import Combine
import CoreLocation

class Repository {
    var dangerModel = PassthroughSubject<[DangerLocationData], Never>()
    var placeModel = PassthroughSubject<[Poi], Never>()
    var pathModel = PassthroughSubject<[PathPoint], Never>()
    
    private let naverSearchAPI: LocationSearchAPIProtocol
    
    init(locationAPI: LocationSearchAPIProtocol = LocationSearchAPI()) {
        naverSearchAPI = locationAPI
    }
    
    func getPlaceData(place: String, currentLocation: CLLocationCoordinate2D) {
        naverSearchAPI.searchPlace(place: place, currentLocation: currentLocation, completion: {
            locationModel in
            self.placeModel.send(locationModel.searchPoiInfo.pois.poi)
        })
    }
    
    func getDangerData(coordinates: [CLLocationCoordinate2D]) {
        naverSearchAPI.getDangerData(coordinates: coordinates, completion: {
            dangerModelResponse in
            self.dangerModel.send(dangerModelResponse.response.payload)
        })
        
    }
    
    func getPath(startPoi: Poi, destinationPoi: Poi) {
        naverSearchAPI.getPath(startPoi: startPoi, destinationPoi: destinationPoi, completion: {
            [unowned self] pathModelResponse in
            pathModel.send(pathModelResponse.features)
        })
    }
}
