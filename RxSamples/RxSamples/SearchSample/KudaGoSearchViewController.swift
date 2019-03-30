//
//  GoogleSearchViewController.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 21/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import UIKit
import Utils
import RxSwift
import RxCocoa

typealias KudaGoEventCellConfigurator = CellConfigurator<KudaGoEventCell, KudaGoEvent>

class KudaGoSearchViewController: UIViewController, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = dataSource

        view.addSubview(errorBar)
        errorBar.translatesAutoresizingMaskIntoConstraints = false
        errorBar.textInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)

        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        errorBarTopConstraint = errorBar.topAnchor.constraint(equalTo: searchBar.bottomAnchor)
        updateErrorBarPosition(forIsError: false, animated: false)

        let anotherConstraints = [
            errorBarTopConstraint!,
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            errorBar.heightAnchor.constraint(equalToConstant: L.errorBarHeight)
        ]
        NSLayoutConstraint.activate(
            searchBar.pinToParentSafe(withEdges: [.top, .left, .right])
            + tableView.pinToParentSafe(withEdges: [.bottom, .left, .right])
            + errorBar.pinToParentSafe(withEdges: [.left, .right])
            + anotherConstraints
        )

        searchBar.rx.text.orEmpty
            .do(onNext: { [weak self] _ in
                self?.updateErrorBarPosition(forIsError: false, animated: true)
            })
            .debounce(0.25, scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] searchText -> Observable<Result<[KudaGoEvent], APIError>> in
                guard let slf = self else { return .empty() }
                guard !searchText.isEmpty else { return .just(.success([])) }
                slf.update(withIsLoading: true)
                return slf.searchApi.searchEvents(with: searchText)
            }
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] result in
                guard let slf = self else { return }
                slf.updateErrorBarPosition(forIsError: result.isError, animated: true)
                slf.update(withIsLoading: false)
                switch result {
                case .success(let events):
                    slf.updateTableView(with: events)
                case .error(let error):
                    slf.updateTableView(with: [])
                    slf.errorBar.text = error.description
                }
            })
            .disposed(by: bag)
    }

    private let dataSource = TableViewDataSource()
    private let searchApi = KudaGoSearchAPI(session: URLSession.shared)
    private let tableView: UITableView = UITableView()
    private let searchBar: UISearchBar = UISearchBar()
    private let errorBar: ErrorBar = ErrorBar()
    private var errorBarTopConstraint: NSLayoutConstraint!
    private let bag = DisposeBag()
}

fileprivate extension KudaGoSearchViewController {
    enum L {
        static let errorBarHeight: CGFloat = 28.0 // 20 + 4 + 4
    }

    private func updateTableView(with events: [KudaGoEvent]) {
        dataSource.sectionConfigurations = [
            SectionConfigurator(cellConfigurators: events.map {
                KudaGoEventCellConfigurator(model: $0)
            })
        ]
        tableView.reloadData()
    }

    private func update(withIsLoading isLoading: Bool) {
        searchBar.isLoading = isLoading
        UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
    }

    private func updateErrorBarPosition(forIsError isError: Bool, animated: Bool) {
        let constant = isError ? 0.0 : -L.errorBarHeight
        guard errorBarTopConstraint.constant != constant else { return }
        
        let updates = {
            self.errorBarTopConstraint.constant = constant
        }

        if animated {
            view.layoutIfNeeded()
            UIView.animate(
                withDuration: 0.25,
                delay: 0.0,
                options: UIView.AnimationOptions.beginFromCurrentState,
                animations: {
                    updates()
                    self.view.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            updates()
        }
    }
}

extension KudaGoSearchAPI {
    func searchEvents(with text: String) -> Observable<Result<[KudaGoEvent], APIError>> {
        let asyncRequest = { (_ completion: @escaping (Result<[KudaGoEvent], APIError>) -> Void) -> URLSessionTaskProtocol in
            return self.searchEvents(withText: text, completion: completion)
        }
        return Observable.fromAsync(asyncRequest)
    }
}

extension Observable {
    static func fromAsync(_ asyncRequest: @escaping (@escaping (Element) -> Void) -> URLSessionTaskProtocol) -> Observable<Element> {
        return Observable.create({ (o) -> Disposable in
            let task = asyncRequest({ (result) in
                o.onNext(result)
                o.onCompleted()
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        })
    }
}

class ErrorBar: UIView {
    var text: String = "" {
        didSet {
            label.text = text
        }
    }

    var textInsets: UIEdgeInsets = .zero {
        didSet {
            top.constant = textInsets.top
            left.constant = textInsets.left
            bottom.constant = textInsets.bottom
            right.constant = textInsets.right
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)

        backgroundColor = UIColor.red.withAlphaComponent(0.8)

        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14.0)

        top = label.topAnchor.constraint(equalTo: topAnchor, constant: textInsets.top)
        left = label.leftAnchor.constraint(equalTo: leftAnchor, constant: textInsets.left)
        bottom = bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: textInsets.bottom)
        right = rightAnchor.constraint(equalTo: label.rightAnchor, constant: textInsets.right)
        NSLayoutConstraint.activate([top, left, bottom, right])
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let label: UILabel = UILabel()
    private var top: NSLayoutConstraint!
    private var left: NSLayoutConstraint!
    private var bottom: NSLayoutConstraint!
    private var right: NSLayoutConstraint!
}


extension UISearchBar {

    public var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else {
            return nil
        }
        return textField
    }

    public var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
    }

    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let newActivityIndicator = UIActivityIndicatorView(style: .gray)
                    newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = UIColor.white
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
