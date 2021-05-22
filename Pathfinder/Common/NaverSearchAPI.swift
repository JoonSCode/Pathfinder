//
//  NaverSearchAPI.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import Alamofire
import Combine
import CoreLocation
import Foundation

protocol LocationSearchAPIProtocol {
    func searchPlace(place: String, currentLocation: CLLocationCoordinate2D, completion: @escaping (LocationModel) -> Void)
    func getDangerData(coordinates: [CLLocationCoordinate2D], completion: @escaping (DangerLocationModel) -> Void)
    func getPath(startPoi: Poi, destinationPoi: Poi, completion: @escaping (PathModel) -> Void)
    func getNearDangerData(currentCoordinate: CLLocationCoordinate2D, completion: @escaping (DangerLocationModel) -> Void) 
}

final class LocationSearchAPI: LocationSearchAPIProtocol {
    private var cancelBag = Set<AnyCancellable>()
    private let tmapKey = "l7xx2612a5062de74768a58b73f754e1f4e0"
    func searchPlace(place: String, currentLocation: CLLocationCoordinate2D, completion: @escaping (LocationModel) -> Void) {
        let baseURL = "https://apis.openapi.sk.com/tmap/pois"
        let parameters: Parameters = ["version": 1, "appKey": tmapKey, "searchtypCd": "R", "radius": "30", "centerLat": currentLocation.latitude, "centerLon": currentLocation.longitude, "searchKeyword": place, "count": 10]

        let request = AF.request(baseURL, method: .get, parameters: parameters).validate(statusCode: 200 ..< 300)

        request.publishDecodable(type: LocationModel.self).sink(receiveValue: {
            response in
            switch response.result {
            case let .success(locationModel):
                completion(locationModel)
            case let .failure(error):
                print(error)
            }
        }).store(in: &cancelBag)
    }

    func getDangerData(coordinates: [CLLocationCoordinate2D], completion: @escaping (DangerLocationModel) -> Void) {
        let url = "http://15.164.164.165:3000/api/v1/mobilities/obstacles_base_map_guide"
        var pathDatas: [[Double]] = []
        var qs = "["
        coordinates.forEach({
            data in
            qs += "[\(data.latitude),\(data.longitude)],"
//            let array:Array<Double> = [data.latitude, data.longitude]
//            pathDatas.append(array)
        })
        qs.removeLast()
        qs += "]"
        
        let parameters: Parameters = ["lat_and_lng": qs]
        
        print("parametr: \(parameters)")
   
        let request = AF.request(url, method: .get, parameters: parameters).validate(statusCode: 200 ..< 300)
        
        request.publishDecodable(type: DangerLocationModel.self).sink(receiveValue: {
            response in
            switch response.result {
            case let .success(dangerModel):
                completion(dangerModel)
            case let .failure(error):
                print(error)
            }
        }).store(in: &cancelBag)
    }

    func getPath(startPoi: Poi, destinationPoi: Poi, completion: @escaping (PathModel) -> Void) {
        let url = "https://apis.openapi.sk.com/tmap/routes/pedestrian"
        let parameters: Parameters = ["version": "1", "startX": startPoi.longitude, "startY": startPoi.latitude, "endX": destinationPoi.longitude, "endY": destinationPoi.latitude, "searchOption": 30, "startName": startPoi.name, "endName": destinationPoi.name]
        let headers: HTTPHeaders = ["appKey": tmapKey]
        
        let request = AF.request(url, method: .post, parameters: parameters, headers: headers).validate(statusCode: 200 ..< 300)
        
        
        request.publishDecodable(type: PathModel.self).sink(receiveValue: {
            response in
            switch response.result {
            case let .success(pathModel):
                completion(pathModel)
            case let .failure(error):
                print(error)
            }
        }).store(in: &cancelBag)
    }
    
    func getNearDangerData(currentCoordinate: CLLocationCoordinate2D, completion: @escaping (DangerLocationModel) -> Void) {
        let url = "http://15.164.164.165:3000/api/v1/mobilities/from_my_position"
        let parameters = ["lat": "\(currentCoordinate.latitude)", "lng": "\(currentCoordinate.longitude)", "ride_type": "bicycle"]
        
        let request = AF.request(url, method: .get, parameters: parameters).validate(statusCode: 200 ..< 300)
        
        request.publishDecodable(type: DangerLocationModel.self).sink(receiveValue: {
            response in
            switch response.result {
            case let .success(dangerModel):
                completion(dangerModel)
            case let .failure(error):
                print(error)
            }
        }).store(in: &cancelBag)
    }
}
