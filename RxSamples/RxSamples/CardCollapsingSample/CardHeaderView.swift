import UIKit
import Utils

final class CardHeaderView: UIView {

    var title: String = "" {
        didSet {
            UIView.performWithoutAnimation {
                button.setTitle(title, for: .normal)
            }
        }
    }

    var onButtonTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    
        addSubview(button)
        button.tintColor = .black
        button.backgroundColor = UIColor.randomLight
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets.left = 16
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(button.pinToParent()) 
        
        addSubview(separator)
        separator.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let button = UIButton(type: .system)
    private let separator = UIView()
    
    @objc private func handleButton() {
        onButtonTap?()
    }

}
