import UIKit

final class GroupCell: UICollectionViewCell {
    static let reuseID = "GroupCell"

    private let card = UIView()
    private let gradient = CAGradientLayer()
    private let circle = UIView()
    private let icon = UIImageView()
    private let titleLabel = UILabel()
    private let countBadge = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override var isHighlighted: Bool {
        didSet { animate(isHighlighted ? 0.98 : 1.0) }
    }
    override var isSelected: Bool {
        didSet { animate(isSelected ? 0.98 : 1.0) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countBadge.translatesAutoresizingMaskIntoConstraints = false
        chevron.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(card)
        card.addSubview(circle)
        card.addSubview(icon)
        card.addSubview(titleLabel)
        card.addSubview(countBadge)
        card.addSubview(chevron)

        card.layer.cornerRadius = 18
        card.layer.masksToBounds = false
        card.backgroundColor = .secondarySystemBackground
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.10
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.layer.shadowRadius = 18

        gradient.colors = [
            UIColor.systemIndigo.withAlphaComponent(0.18).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 18
        card.layer.insertSublayer(gradient, at: 0)

        circle.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.18)
        circle.layer.cornerRadius = 16

        icon.contentMode = .scaleAspectFit
        icon.tintColor = .systemIndigo

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        countBadge.font = .preferredFont(forTextStyle: .subheadline)
        countBadge.textColor = .systemIndigo
        countBadge.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
        countBadge.layer.cornerRadius = 10
        countBadge.clipsToBounds = true
        countBadge.textAlignment = .center

        chevron.tintColor = .tertiaryLabel
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            circle.widthAnchor.constraint(equalToConstant: 32),
            circle.heightAnchor.constraint(equalToConstant: 32),
            circle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            circle.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            chevron.widthAnchor.constraint(equalToConstant: 12),

            titleLabel.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),

            countBadge.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            countBadge.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            countBadge.heightAnchor.constraint(equalToConstant: 22),
            countBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            countBadge.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = card.bounds
    }

    private func animate(_ scale: CGFloat) {
        UIView.animate(withDuration: 0.15) {
            self.card.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.card.layer.shadowRadius = scale < 1 ? 10 : 18
            self.card.layer.shadowOpacity = scale < 1 ? 0.06 : 0.10
        }
    }

    func configure(title: String, count: Int) {
        titleLabel.text = title
        countBadge.text = "  \(count) items  "
        icon.image = UIImage(systemName: symbol(for: title))
    }

    private func symbol(for title: String) -> String {
        let t = title.lowercased()
        if t.contains("selfie") { return "person.crop.square" }
        if t.contains("food")   { return "fork.knife" }
        if t.contains("travel") { return "airplane" }
        if t.contains("video")  { return "film" }
        if t.contains("live")   { return "dot.radiowaves.left.and.right" }
        return "photo.on.rectangle.angled"
    }
}

