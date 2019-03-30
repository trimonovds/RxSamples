//: [Previous](@previous)

import UIKit
import Utils
import RxSwift
import RxCocoa
import PlaygroundSupport

public class TimeInfoView: UIView {
    public var date: Date = Date() {
        didSet {
            update(withNew: date)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        // setup UI
        addSubview(container)
        container.addSubview(dateLabel)
        container.addSubview(timeLabel)
        container.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            container.pinToParent(withInsets: UIEdgeInsets.init(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0))
            + dateLabel.pinToParent(withEdges: [.left, .top, .right])
            + timeLabel.pinToParent(withEdges: [.left, .bottom, .right])
            + [timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8.0)]
        )
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        dateLabel.textColor = .black
        timeLabel.textColor = .gray
        self.layer.cornerRadius = 4.0
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.black.cgColor

        date = Date()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update(withNew date: Date) {
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .none)
        let timeString = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
        dateLabel.text = "Date: \(dateString)"
        timeLabel.text = "Time: \(timeString)"
    }

    private let container = UIView()
    private let dateLabel = UILabel()
    private let timeLabel = UILabel()
}

extension Reactive where Base: TimeInfoView {

    /// Bindable sink for `date` property.
    public var date: Binder<Date> {
        return Binder(self.base) { element, value in
            element.date = value
        }
    }
}

class TimeInfoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let timeInfoView = TimeInfoView(frame: .zero)
        timeInfoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeInfoView)

        NSLayoutConstraint.activate(
            timeInfoView.centerInParent(.vertically) +
                timeInfoView.centerInParent(.horizontally)
        )

        Observable<Int>
            .interval(1.0, scheduler: MainScheduler.instance)
            .map { _ in Date() }
            .bind(to: timeInfoView.rx.date)
            .disposed(by: bag)
    }

    private let bag = DisposeBag()
}

PlaygroundPage.current.liveView = TimeInfoViewController()

//: [Next](@next)
