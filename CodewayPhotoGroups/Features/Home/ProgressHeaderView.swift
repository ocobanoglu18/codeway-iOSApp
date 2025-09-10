import UIKit

final class ProgressHeaderView: UICollectionReusableView {
    static let kind = "progress-header-kind"
    static let reuseID = "ProgressHeaderView"

    private let container = UIView()
    private let titleLabel = UILabel()
    private let percentLabel = UILabel()
    private let progress = UIProgressView(progressViewStyle: .bar)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        container.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        progress.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(percentLabel)
        container.addSubview(progress)

        container.backgroundColor = UIColor.secondarySystemBackground
        container.layer.cornerRadius = 14
        container.layer.masksToBounds = false
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowOffset = CGSize(width: 0, height: 8)
        container.layer.shadowRadius = 16

        titleLabel.text = "Scanning Photos"
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .secondaryLabel

        percentLabel.font = .monospacedDigitSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .semibold)
        percentLabel.textColor = .label

        progress.trackTintColor = UIColor.tertiarySystemFill
        progress.progressTintColor = UIColor.systemIndigo

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: percentLabel.leadingAnchor, constant: -8),

            percentLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            progress.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            progress.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            progress.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            progress.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            progress.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    func render(percent: Float, processed: Int, total: Int) {
        let pct = max(0, min(1, percent))
        progress.setProgress(pct, animated: true)
        percentLabel.text = "\(Int(pct * 100))%  (\(processed)/\(total))"
        isHidden = total == 0
    }
}

