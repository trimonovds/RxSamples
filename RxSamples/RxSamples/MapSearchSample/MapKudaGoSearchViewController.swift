//
//  MapViewController.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 25/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import Utils
import UltraDrawerView

enum MapKudaGoSearchStrings {
    static let events: String = "Спектакли"
}

enum MapAnimationState {
    case finished
    case started
}

struct MapCameraEventArgs {
    let mapCamera: MKMapCamera
    let state: MapAnimationState
    let radius: Double
}

enum ScreenState {
    case initial
    case loading
    case found([KudaGoEvent])
    case error
    case searchCanceled
}

protocol Map: AnyObject {
    var mapCameraEvents: Observable<MapCameraEventArgs> { get }
}

protocol MapKudaGoSearchAPI {
    func searchEvents(with text: String, locationArgs: LocationArgs) -> Observable<Result<[KudaGoEvent], APIError>>
}

class MapKudaGoSearchViewModel {

    var didChangeScreenState: Observable<ScreenState> {
        return screenState.asObservable()
    }

    init(map: Map, searchApi: MapKudaGoSearchAPI, schedulerProvider: SchedulerProvider) {
        self.map = map
        self.searchApi = searchApi
        self.schedulerProvider = schedulerProvider

        let finishedCameraMoves = map.mapCameraEvents.filter { $0.state == .finished }
        let searchRequests = finishedCameraMoves
            .debounce(0.5, scheduler: schedulerProvider.mainScheduler)
            .withLatestFrom(map.mapCameraEvents)
            .filter { $0.state != .started }

        searchRequests
            .flatMapLatest { [weak self] request -> Observable<Result<[KudaGoEvent], APIError>> in
                guard let slf = self else { return .empty() }
                slf.screenState.accept(.loading)
                let interruptions = slf.map.mapCameraEvents
                    .filter { $0.state == .started }
                    .do(onNext: { [weak slf] _ in
                        slf?.screenState.accept(.searchCanceled)
                    })
                let locationArgs = LocationArgs(coordinate: request.mapCamera.centerCoordinate, radius: request.radius)
                return slf.searchApi
                    .searchEvents(with: MapKudaGoSearchStrings.events, locationArgs: locationArgs)
                    .takeUntil(interruptions)
            }
            .map { result -> ScreenState in
                switch result {
                case .success(let events):
                    return .found(events)
                case .error(_):
                    return .error
                }
            }
            .bind(to: screenState)
            .disposed(by: bag)
    }

    private let map: Map
    private let searchApi: MapKudaGoSearchAPI
    private let schedulerProvider: SchedulerProvider
    private let screenState = PublishRelay<ScreenState>()
    private let bag = DisposeBag()
}

class MapKudaGoSearchViewController: MapDrawerViewController {

    var state: ScreenState = .initial {
        didSet {
            updateNetworkActivityIndicator(withIsLoading: state.isLoading)
            headerView.title = state.cardHeaderTitle
            if let events = state.events {
                updateTableView(with: events)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .white
        tableView.dataSource = dataSource

        let map = RxMapDelegate(mapView: mapView)
        viewModel = MapKudaGoSearchViewModel(
            map: map,
            searchApi: KudaGoSearchAPI(session: URLSession.shared),
            schedulerProvider: DefaultSchedulerProvider.shared
        )
        viewModel.didChangeScreenState
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] state in
                guard let slf = self else { return }
                slf.state = state
            })
            .disposed(by: bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let center = CLLocationCoordinate2D(latitude: 55.69454914, longitude: 37.60688340)
        let camera = MKMapCamera(lookingAtCenter: center, fromDistance: 67523, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
    }

    private var viewModel: MapKudaGoSearchViewModel!

    private let dataSource = TableViewDataSource()
    private let bag = DisposeBag()
}

class RxMapDelegate: NSObject, Map, MKMapViewDelegate {

    var mapCameraEvents: Observable<MapCameraEventArgs> {
        return mapCamera.asObservable()
    }

    init(mapView: MKMapView) {
        self.mapView = mapView
        super.init()
        mapView.delegate = self
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.mapCamera.accept(.init(mapCamera: mapView.camera, state: .started, radius: mapView.currentRadius()))
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.mapCamera.accept(.init(mapCamera: mapView.camera, state: .finished, radius: mapView.currentRadius()))
    }

    private let mapView: MKMapView
    private let mapCamera = PublishRelay<MapCameraEventArgs>()
}

fileprivate extension MapKudaGoSearchViewController {

    private func updateTableView(with events: [KudaGoEvent]) {
        dataSource.sectionConfigurations = [
            SectionConfigurator(cellConfigurators: events.map {
                KudaGoEventCellConfigurator(model: $0)
            })
        ]
        tableView.reloadData()
    }

    private func updateNetworkActivityIndicator(withIsLoading isLoading: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
    }
}

extension KudaGoSearchAPI: MapKudaGoSearchAPI {
    func searchEvents(with text: String, locationArgs: LocationArgs) -> Observable<Result<[KudaGoEvent], APIError>> {
        let asyncRequest = { (_ completion: @escaping (Result<[KudaGoEvent], APIError>) -> Void) -> URLSessionTaskProtocol in
            return self.searchEvents(withText: text, locationArgs: locationArgs, completion: completion)
        }
        return Observable.fromAsync(asyncRequest)
    }
}

extension MKMapView {

    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }

    func currentRadius() -> Double {
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude, longitude: self.centerCoordinate.longitude)
        let topCenterCoordinate = self.topCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        return centerLocation.distance(from: topCenterLocation)
    }

}

extension ScreenState {
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }

    var events: [KudaGoEvent]? {
        switch self {
        case .found(let events):
            return events
        case .error:
            return []
        default:
            return nil
        }
    }

    var cardHeaderTitle: String {
        switch self {
        case .initial:
            return MapKudaGoSearchStrings.events
        case .error:
            return "Произошла ошибка"
        case .loading:
            return "Ищем \(MapKudaGoSearchStrings.events)..."
        case .found(let events):
            let count = events.count
            return count == 0 ? "Ничего не найдено" : "Найдено \(count) результатов"
        case .searchCanceled:
            return "Поиск отменен"
        }
    }
}
