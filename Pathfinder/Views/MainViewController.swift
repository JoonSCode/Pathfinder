//
//  MainViewController.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import AudioToolbox
import AVFoundation
import Combine
import CoreLocation
import NMapsMap
import UIKit

class MainViewController: UIViewController {
    @IBOutlet var naverMapView: NMFNaverMapView!
    @IBOutlet var locationButton: NMFLocationButton!
    @IBOutlet var resultContainerView: UIView!
    @IBOutlet var startName: UILabel!
    @IBOutlet var destinationName: UILabel!
    @IBOutlet var searchPathConfirmView: UIView!

    var locationManager: CLLocationManager!
    private var cancelBag = Set<AnyCancellable>()
    let viewModel = MainViewModel()
    var searchBar: UISearchBar!
    var destinationPoi: Poi?
    var startPoi: Poi?
    var isInDanger = false
    private var pathOverlay: NMFPath?
    var dangerMarkers: [NMFMarker] = []
    var obstacleMarkers: [NMFMarker] = []

    @IBOutlet var startNavigatingButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initCombine()
    }

    private func initView() {
        initLocationManager()
        initMapView()
        initSearchBar()

        resultContainerView.isHidden = true
        guard let containerViewController = children[0] as? SearhResultViewController else { return }
        containerViewController.viewModel = ResultTableViewModel(repository: viewModel.repository)
        containerViewController.delegate = self
        resultContainerView.clipsToBounds = true
        resultContainerView.layer.cornerRadius = 15
    }

    private func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }

    private func initMapView() {
        naverMapView.showZoomControls = false
        naverMapView.showLocationButton = false
        locationButton.mapView = naverMapView.mapView
        naverMapView.mapView.zoomLevel = 15
        naverMapView.mapView.positionMode = .direction
    }

    private func initSearchBar() {
        searchBar = UISearchBar()
        view.addSubview(searchBar)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true

        searchBar.backgroundColor = .white
        searchBar.searchTextField.backgroundColor = .white
        searchBar.backgroundImage = UIImage()
        searchBar.clipsToBounds = true
        searchBar.layer.cornerRadius = 15

        let glassIconView = searchBar.searchTextField.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UIColor.purple
        searchBar.delegate = self
        searchBar.showsCancelButton = true
    }

    private func initCombine() {
        viewModel.dangerDatas.sink(receiveValue: {
            [unowned self] dangerDatas in
            clearOverlay(overlays: dangerMarkers)

            dangerDatas.forEach {
                dangerData in
                let marker = getMarker(dangerData: dangerData)
                marker.mapView = naverMapView.mapView
                dangerMarkers.append(marker)
            }
        }).store(in: &cancelBag)

        viewModel.placeDatas.sink(receiveValue: {
            [unowned self] placeDatas in
            if placeDatas.count != 0 {
                resultContainerView.isHidden = false
            }
        }).store(in: &cancelBag)

        viewModel.pathDatas.sink(receiveValue: {
            [unowned self] pathDataViewModels in
            clearOverlay(overlays: obstacleMarkers)
            pathDataViewModels.filter {
                pathDataViewModel in
                pathDataViewModel.type == .Point && Range(125 ... 218).contains(pathDataViewModel.turnType!)
            }.forEach {
                drawObstacleMarker(pathDataViewModel: $0)
            }

            drawPath(coordinates: pathDataViewModels.filter {
                $0.type == .LineString
            }.compactMap {
                pathDataViewModel in
                pathDataViewModel.coordinates
            })

            viewModel.requestDangerData()

        }).store(in: &cancelBag)
    }

    private func getMarker(dangerData: DangerLocationData) -> NMFMarker {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: Double(dangerData.latitude)!, lng: Double(dangerData.longitude)!)
        marker.width = 25
        marker.height = 25
        switch dangerData.impulse.level {
        case 1:
            marker.iconImage = NMFOverlayImage(name: "level1")
        case 2:
            marker.iconImage = NMFOverlayImage(name: "level2")
        case 3:
            marker.iconImage = NMFOverlayImage(name: "level3")
        default:
            print("")
        }
        return marker
    }

    private func drawPath(coordinates: [[CLLocationCoordinate2D]]) {
        pathOverlay?.mapView = nil
        let overlay = NMFPath()
        var points: [NMGLatLng] = []
        coordinates.forEach {
            coordinates in
            coordinates.forEach {
                points.append(NMGLatLng(lat: $0.latitude, lng: $0.longitude))
            }
        }
        overlay.path = NMGLineString(points: points)
        overlay.patternInterval = 5
        overlay.color = .systemPurple
        overlay.mapView = naverMapView.mapView
        pathOverlay = overlay
    }

    private func drawObstacleMarker(pathDataViewModel: PathDataViewModel) {
        let marker = NMFMarker()
        let coordinate = pathDataViewModel.coordinates[0]
        marker.position = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)

        if pathDataViewModel.pointType == "SP" || pathDataViewModel.pointType == "EP" {
            marker.width = 25
            marker.height = 25
            obstacleMarkers.append(marker)
            marker.mapView = naverMapView.mapView
            return
        }

        guard let turnType = pathDataViewModel.turnType else { return }
        switch turnType {
        case 125:
            marker.iconImage = NMFOverlayImage(name: "육교")
        case 126:
            marker.iconImage = NMFOverlayImage(name: "지하보도")
        case 128:
            marker.iconImage = NMFOverlayImage(name: "경사로")
        case Range(211 ... 217):
            marker.iconImage = NMFOverlayImage(name: "횡단보도")
        case 218:
            marker.iconImage = NMFOverlayImage(name: "엘레베이터")
        default:
            return
        }
        marker.iconTintColor = .red
        marker.width = 25
        marker.height = 25
        obstacleMarkers.append(marker)
        marker.mapView = naverMapView.mapView
    }

    func clearOverlay(overlays: [NMFOverlay]) {
        overlays.forEach { $0.mapView = nil }
    }

    @IBAction func closeConfirmView(_ sender: Any) {
        searchPathConfirmView.isHidden = true
        searchBar.isHidden = false
    }

    @IBAction func endNavigating(_ sender: Any) {
        clearOverlay(overlays: obstacleMarkers)
        clearOverlay(overlays: dangerMarkers)
        viewModel.dangerDatas.value = []
        viewModel.pathDatas.value = []
        destinationPoi = nil
    }

    @IBAction func startNavigating(_ sender: Any) {
        guard let start = startPoi, let destination = destinationPoi else { return }
        viewModel.searchPath(startPoi: start, destinationPoi: destination)
        startNavigatingButton.isHidden = true
        searchPathConfirmView.isHidden = true
        searchBar.isHidden = false
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("11")
        guard let destination = destinationPoi else {
            if dangerMarkers.count != 0 {
                return
            }
            clearOverlay(overlays: obstacleMarkers)
            clearOverlay(overlays: dangerMarkers)
            viewModel.requestNearDangerData(currentCoordinate: locations[0].coordinate)
            return
        }
        let currentLocation = locations[0]

        guard !isNavigatingEnd(currentLocation: currentLocation, destination: destination) else {
            clearOverlay(overlays: obstacleMarkers)
            clearOverlay(overlays: dangerMarkers)

            let alert = UIAlertController(title: "도착", message: "목적지에 도착했습니다", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
            alert.addAction(okAction)
            present(alert, animated: false, completion: nil)
            viewModel.dangerDatas.value = []
            viewModel.pathDatas.value = []
            destinationPoi = nil
            return
        }
        var tmpDanger = false

        for dangerData in viewModel.dangerDatas.value {
            let target = CLLocation(latitude: Double(dangerData.latitude)!, longitude: Double(dangerData.longitude)!)
            let distance = getDistance(first: currentLocation, second: target)
            if distance < 15 {
                tmpDanger = true
                break
            }
        }

        isInDanger = tmpDanger

        if isInDanger {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound(1015)
            print("근처 위험")
            let alert = getAlert()
            if alert.isBeingPresented { return }
            present(getAlert(), animated: false, completion: nil)
        }
    }

    private func isNavigatingEnd(currentLocation: CLLocation, destination: Poi) -> Bool {
        let destinationLocation = CLLocation(latitude: Double(destination.latitude)!, longitude: Double(destination.longitude)!)

        let distanceInMeters = getDistance(first: currentLocation, second: destinationLocation)

        return distanceInMeters < 5
    }

    private func getDistance(first: CLLocation, second: CLLocation) -> CLLocationDistance {
        return first.distance(from: second)
    }

    private func getAlert() -> UIAlertController {
        let alert = UIAlertController(title: "경고", message: "주변에 위험 지역이 있습니다!", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
        alert.addAction(okAction)
        return alert
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultContainerView.isHidden = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, let currentLocation = locationManager.location?.coordinate else { return }
        searchBar.resignFirstResponder()
        viewModel.searchPlace(place: searchText, currentLocation: currentLocation)
    }
}
