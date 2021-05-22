//
//  MainViewModel.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import Combine
import CoreLocation
import Foundation

class MainViewModel {
    let repository = Repository()
    private var cancelBag = Set<AnyCancellable>()
    var dangerDatas = CurrentValueSubject<[DangerLocationData], Never>([])
    var placeDatas = CurrentValueSubject<[Poi], Never>([])
    var pathDatas = CurrentValueSubject<[PathDataViewModel], Never>([])
    
    init() {
        initCombine()
    }
    
    private func initCombine() {
        repository.dangerModel.sink(receiveValue: {
            print($0.count)
            self.dangerDatas.send($0)
        }).store(in: &cancelBag)
        
        repository.placeModel.sink(receiveValue: {
            self.placeDatas.send($0)
        }).store(in: &cancelBag)
        
        repository.pathModel.sink(receiveValue: {
            pathPoints in
            self.pathDatas.send(pathPoints.map {
                PathDataViewModel(pathData: $0)
            })
        }).store(in: &cancelBag)
    }
    
    func requestDangerData() {
        var coordinates: [CLLocationCoordinate2D] = []
        pathDatas.value.filter({
            $0.type == .Point
        }).forEach({
            pointData in
            coordinates.append(contentsOf: pointData.coordinates)
        })
        
        if coordinates.count == 0 { return }
        repository.getDangerData(coordinates: coordinates)
    }
    
    func requestNearDangerData(currentCoordinate: CLLocationCoordinate2D) {
        repository.getNearDangerData(currentCoordinate: currentCoordinate)
    }
    
    func searchPlace(place: String, currentLocation: CLLocationCoordinate2D) {
        repository.getPlaceData(place: place, currentLocation: currentLocation)
    }
    
    func searchPath(startPoi: Poi, destinationPoi: Poi) {
        repository.getPath(startPoi: startPoi, destinationPoi: destinationPoi)
    }
}

struct PathDataViewModel {
    var type: GeometryType
    var coordinates: [CLLocationCoordinate2D]
    var description: String
    var turnType: Int?
    var pointType: String?
    
    init(pathData: PathPoint) {
        type = pathData.geometry.type
        let tempCoordinates = pathData.geometry.coordinates
        coordinates = []
        switch type {
        case .LineString:
            for i in tempCoordinates.indices {
                switch tempCoordinates[i] {
                case .double:
                    continue
                case let .doubleArray(doubleArray):
                    coordinates.append(CLLocationCoordinate2D(latitude: doubleArray[1], longitude: doubleArray[0]))
                }
            }
        case .Point:
            var coordinate = CLLocationCoordinate2D()
            for i in tempCoordinates.indices {
                switch tempCoordinates[i] {
                case let .double(double):
                    if i == 0 {
                        coordinate.longitude = double
                    } else {
                        coordinate.latitude = double
                    }
                case .doubleArray:
                    continue
                }
            }
            coordinates = [coordinate]
        }
    
        description = pathData.properties.description
        turnType = pathData.properties.turnType
        pointType = pathData.properties.pointType
    }
}
