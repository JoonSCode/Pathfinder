//
//  ResultTableViewModel.swift
//
//
//  Created by 윤준수 on 2021/05/22.
//

import Combine
import CoreLocation
import Foundation

class ResultTableViewModel {
    var locations = CurrentValueSubject<[Poi], Never>([])
    private var repository: Repository
    private var cancelBag = Set<AnyCancellable>()

    init(repository: Repository) {
        self.repository = repository
        repository.placeModel.sink(receiveValue: {
            [unowned self] locationDatas in
            locations.send(locationDatas)
        }).store(in: &cancelBag)
    }
}
