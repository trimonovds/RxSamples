import UIKit
import pop
import Utils

struct ShapeCellModel {
    let title: String
    let subtitle: String
    let shape: UIBezierPath
}

final class ShapeCell: BindableTableViewCell {

    typealias Model = ShapeCellModel

    struct Layout {
        static let inset: CGFloat = 18
        static let shapeSize: CGFloat = 48
        static let estimatedHeight: CGFloat = 40
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to model: ShapeCell.Model) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        shapeLayer.path = model.shape.cgPath
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = shapeButton.bounds
    }
    
    // MARK: - Private
    
    private let shapeButton = UIButton()
    private let shapeLayer = CAShapeLayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private func setupViews() {
        addSubview(shapeButton)
        shapeButton.addTarget(self, action: #selector(handleShapeButton), for: .touchUpInside)
        
        shapeButton.layer.addSublayer(shapeLayer)
        shapeLayer.lineWidth = 5
        shapeLayer.lineJoin = .round
        updateShapeColors()
        
        addSubview(titleLabel)
        titleLabel.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        titleLabel.numberOfLines = 0
        
        addSubview(subtitleLabel)
        subtitleLabel.font = .systemFont(ofSize: UIFont.systemFontSize)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .darkGray
        
        setupLayout()
    }
    
    private func setupLayout() {
        let inset = Layout.inset
        let shapeSize = Layout.shapeSize
        
        shapeButton.translatesAutoresizingMaskIntoConstraints = false
        shapeButton.widthAnchor.constraint(equalToConstant: shapeSize).isActive = true
        shapeButton.heightAnchor.constraint(equalToConstant: shapeSize).isActive = true
        shapeButton.topAnchor.constraint(equalTo: topAnchor, constant: inset).isActive = true
        shapeButton.leftAnchor.constraint(equalTo: leftAnchor, constant: inset).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: shapeButton.rightAnchor, constant: inset).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: inset).isActive = true
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leftAnchor.constraint(equalTo: shapeButton.rightAnchor, constant: inset).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func updateShapeColors() {
        shapeLayer.fillColor = UIColor.randomLight.cgColor
        shapeLayer.strokeColor = UIColor.randomDark.cgColor
    }
    
    private func bounceShape() {
        let animation: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        animation.velocity = CGPoint(x: 8, y: 8)
        animation.springBounciness = 16
        animation.fromValue = CGPoint(x: 1.1, y: 1.1)
        animation.toValue = CGPoint(x: 1, y: 1)
        shapeLayer.pop_add(animation, forKey: kPOPLayerScaleXY)
    }
    
    @objc private func handleShapeButton() {
        updateShapeColors()
        bounceShape()
    }

}
