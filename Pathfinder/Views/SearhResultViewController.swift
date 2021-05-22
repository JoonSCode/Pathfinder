//
//  SearhResultViewController.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import Combine
import CoreLocation
import UIKit

protocol SearchResultViewDelegate {
    func didCellClicked(indexPath: IndexPath)
}

class SearhResultViewController: UIViewController, UITableViewDataSource {
    @IBOutlet var searchResultTableView: UITableView!
    private var cancelBag = Set<AnyCancellable>()
    var delegate: SearchResultViewDelegate?

    var viewModel: ResultTableViewModel? {
        didSet {
            viewModel!.locations.sink(receiveValue: {
                [unowned self] _ in
                searchResultTableView.reloadData()
            }).store(in: &cancelBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.locations.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ResultTableViewCell, let poi = viewModel?.locations.value[indexPath.row] else {
            return UITableViewCell()
        }

        cell.placeName.text = poi.name
        guard let distance = Double(poi.distance) else { return cell }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        if distance > 1 {
            cell.placeDistance.text = "\(formatter.string(from: NSNumber(value: distance))!)km"
        } else {
            cell.placeDistance.text = "\(formatter.string(from: NSNumber(value: distance * 100))!)m"
        }
        return cell
    }
}

extension SearhResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didCellClicked(indexPath: indexPath)
    }
}
