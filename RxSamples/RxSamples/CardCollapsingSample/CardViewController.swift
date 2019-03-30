import UIKit
import UltraDrawerView
import Utils
import MapKit
import RxSwift
import RxCocoa

final class CardViewController: MapDrawerViewController {

    typealias ShapeCellConfigurator = CellConfigurator<ShapeCell, ShapeCellModel>

    enum Kind {
        case simple
        case smart
    }

    init(kind: Kind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.title = Constants.headerTitle
        headerView.onButtonTap = { [weak self] in
            self?.handleResetButton()
        }

        shapesDataSource.sectionConfigurations = [
            SectionConfigurator(cellConfigurators:
                ShapeCellModel.makeDefaults().map { ShapeCellConfigurator(model: $0) }
            )
        ]

        tableView.dataSource = shapesDataSource

        setupSettings()

        let strategy: DrawerHidingStrategy = {
            switch kind {
            case .simple:
                return SimpleDrawerHidingStrategy()
            case .smart:
                let smartStrategy = SmartDrawerHidingStrategy(timerScheduler: MainScheduler.instance,
                                                              timeInSeconds: 5)
                smartStrategy.timerTickHandler = { [weak self] timeRemains -> Void in
                    self?.headerView.title = "Закроется через \(timeRemains) сек"
                }
                smartStrategy.timerResetHandler = { [weak self] in
                    self?.headerView.title = Constants.headerTitle
                }
                return smartStrategy
            }
        }()
        self.drawerHidingBehavior = DrawerHidingBehavior(
            drawerInput: drawerView,
            cameraManagerOutput: fakeCameraManager,
            locationManagerOutput: fakeLocationManager,
            strategy: strategy
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let center = CLLocationCoordinate2D(latitude: 55.69454914, longitude: 37.60688340)
        let camera = MKMapCamera(lookingAtCenter: center, fromDistance: 67523, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)

        drawerHidingBehavior.isOn = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        drawerHidingBehavior.isOn = false
    }
    
    // MARK: - Private


    private let shapesDataSource = TableViewDataSource()

    private let kind: Kind
    private var drawerHidingBehavior: DrawerHidingBehavior!
    private let fakeLocationManager = FakeLocationManagerOutput()
    private let fakeCameraManager = FakeCameraManagerOutput()
}

extension CardViewController {

    enum Constants {
        static let headerTitle: String = "Карточка"
    }

    // MARK: - Buttons
    
    private func setupSettings() {
        let settingsView = makeSpeedView(speed: fakeLocationManager.didUpdateSpeed)
        view.addSubview(settingsView)
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        settingsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0).isActive = true
        settingsView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0).isActive = true
    }

    func makeSpeedView(speed: Observable<Double>) -> UIView {
        let increaseSpeed = makeButton(withTitle: "+", action: #selector(handleSpeedUpButton))
        let decreaseSpeed = makeButton(withTitle: "-", action: #selector(handleSlowDownButton))
        let autoRotationSwitch = UISwitch()
        autoRotationSwitch.translatesAutoresizingMaskIntoConstraints = false
        _ = fakeCameraManager.isOn.bind(to: autoRotationSwitch.rx.isOn)
        autoRotationSwitch.addTarget(self, action: #selector(handleAutorotationSwitch), for: .valueChanged)
        autoRotationSwitch.tintColor = UIColor.darkGray

        let buttonsStackView = UIStackView(arrangedSubviews: [increaseSpeed, decreaseSpeed, autoRotationSwitch])
        buttonsStackView.axis = .vertical
        buttonsStackView.alignment = .fill
        buttonsStackView.spacing = 8.0
        buttonsStackView.distribution = .fillEqually

        let speedLabel = UILabel()
        speedLabel.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        speedLabel.textColor = .black
        speedLabel.textAlignment = .center
        speedLabel.numberOfLines = 1
        _ = speed.map { s -> String? in "\(s) м/с" }.bind(to: speedLabel.rx.text)


        let speedView = UIImageView()
        speedView.image = StyleKit.imageOfIntro_guidance_camera()
        speedView.addSubview(speedLabel)

        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            speedLabel.centerXAnchor.constraint(equalTo: speedView.centerXAnchor),
            speedLabel.centerYAnchor.constraint(equalTo: speedView.centerYAnchor),
        ])

        speedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            speedView.heightAnchor.constraint(equalToConstant: 112),
            speedView.widthAnchor.constraint(equalToConstant: 112)
        ])

        let stackView = UIStackView(arrangedSubviews: [speedView, buttonsStackView])
        stackView.axis = .horizontal

        let backgroundView = UIView()
        backgroundView.addSubview(stackView)
        backgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        backgroundView.layer.cornerRadius = 8.0
        backgroundView.layer.masksToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(stackView.pinToParent(withInsets: .all(8.0)))
        return backgroundView
    }

    func makeButton(withTitle title: String, action: Selector) -> UIView {
        let button = UIButton(type: .system)
        button.backgroundColor = .darkGray
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.buttonFontSize)
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func handleResetButton() {
        drawerView.setState(UIDevice.current.orientation.isLandscape ? .top : .middle, animated: true)
        fakeLocationManager.speed.accept(0.0)
        fakeCameraManager.isOn.accept(false)
    }

    @objc private func handleSpeedUpButton() {
        fakeLocationManager.speed.accept(fakeLocationManager.speed.value + 1)
    }
    
    @objc private func handleSlowDownButton() {
        let newSpeed = fakeLocationManager.speed.value - 1
        fakeLocationManager.speed.accept(newSpeed >= 0 ? newSpeed : 0.0)
    }

    @objc private func handleAutorotationSwitch(_ sender: UISwitch) {
        fakeCameraManager.isOn.accept(sender.isOn)
    }
}
