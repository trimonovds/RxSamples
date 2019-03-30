//
//  DrawerViewController.swift
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

class MapDrawerViewController: UIViewController, UIScrollViewDelegate {

    var mapView: MKMapView!
    var tableView: UITableView!
    var headerView: CardHeaderView!
    var drawerView: DrawerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView()
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(mapView.pinToParent())

        headerView = CardHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: Constants.Header.headerHeight).isActive = true

        tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never

        drawerView = DrawerView(scrollView: tableView, delegate: self, headerView: headerView)
        drawerView.middlePosition = .fromBottom(Constants.Drawer.middleInsetFromBottom)
        drawerView.cornerRadius = Constants.Drawer.cornerRadius
        drawerView.containerView.backgroundColor = .white
        drawerView.layer.shadowRadius = Constants.Drawer.shadowRadius
        drawerView.layer.shadowOpacity = Constants.Drawer.shadowOpacity
        drawerView.layer.shadowOffset = Constants.Drawer.shadowOffset

        view.addSubview(drawerView)
        setupDrawerLayout()

        drawerView.setState(.middle, animated: false)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let prevState = drawerView.state

        updateDrawerLayout(for: UIDevice.current.orientation)

        coordinator.animate(alongsideTransition: { [weak self] context in
            let newState: DrawerView.State = (prevState == .bottom) ? .bottom : .top
            self?.drawerView.setState(newState, animated: context.isAnimated)
        })
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
        tableView.scrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let orientation = UIDevice.current.orientation
        updateDrawerLayout(for: orientation)
        drawerView.setState(orientation.isLandscape ? .top : .middle, animated: false)
    }


    // MARK: - Private

    private var isFirstLayout = true
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

}

fileprivate extension MapDrawerViewController {
    private enum Constants {
        typealias Drawer = DrawerConstants
        typealias Header = HeaderConstants
    }

    private func setupDrawerLayout() {
        drawerView.translatesAutoresizingMaskIntoConstraints = false

        portraitConstraints = [
            drawerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            drawerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            drawerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            drawerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ]

        landscapeConstraints = [
            drawerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            drawerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            drawerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            drawerView.widthAnchor.constraint(equalToConstant: 320)
        ]
    }

    private func updateDrawerLayout(for orientation: UIDeviceOrientation) {
        if orientation.isLandscape {
            portraitConstraints.forEach { $0.isActive = false }
            landscapeConstraints.forEach { $0.isActive = true }
            drawerView.topPosition = .fromTop(Constants.Drawer.topInsetLandscape)
            drawerView.availableStates = [.top, .bottom]
        } else {
            landscapeConstraints.forEach { $0.isActive = false }
            portraitConstraints.forEach { $0.isActive = true }
            drawerView.topPosition = .fromTop(Constants.Drawer.topInsetPortrait)
            drawerView.availableStates = [.top, .middle, .bottom]
        }
    }
}
