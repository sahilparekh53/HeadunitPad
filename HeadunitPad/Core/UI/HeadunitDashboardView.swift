import UIKit

final class HeadunitDashboardView: UIView {
    private let gradient = CAGradientLayer()
    private let profileLabel = UILabel()
    private let hintLabel = UILabel()

    init(title: UILabel, subtitle: UILabel, status: UILabel, connect: UIButton,
         address: UIButton, stop: UIButton, spinner: UIActivityIndicatorView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        gradient.colors = [UIColor(red: 0.055, green: 0.09, blue: 0.14, alpha: 1).cgColor,
                           UIColor(red: 0.02, green: 0.035, blue: 0.06, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradient, at: 0)

        title.font = .systemFont(ofSize: 34, weight: .bold)
        title.textAlignment = .left
        title.textColor = .white
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.75
        subtitle.font = .systemFont(ofSize: 15, weight: .medium)
        subtitle.textAlignment = .left
        subtitle.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitle.text = "Your Android Auto display"
        let car = UIImageView(image: UIImage(systemName: "car.fill"))
        car.tintColor = .systemTeal
        car.contentMode = .scaleAspectFit
        car.widthAnchor.constraint(equalToConstant: 48).isActive = true
        let titles = UIStackView(arrangedSubviews: [title, subtitle])
        titles.axis = .vertical
        titles.spacing = 5
        let header = UIStackView(arrangedSubviews: [car, titles])
        header.spacing = 18
        header.alignment = .center

        status.font = .systemFont(ofSize: 18, weight: .semibold)
        status.textColor = .white
        status.textAlignment = .center
        status.numberOfLines = 3
        spinner.color = .systemTeal
        let progress = UIStackView(arrangedSubviews: [spinner, status])
        progress.axis = .vertical
        progress.spacing = 14
        progress.alignment = .center

        for button in [connect, address, stop] {
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.75
        }
        connect.configuration?.baseBackgroundColor = .systemTeal
        connect.configuration?.baseForegroundColor = UIColor(red: 0.015, green: 0.08, blue: 0.1, alpha: 1)
        address.configuration?.baseForegroundColor = .white
        address.configuration?.baseBackgroundColor = UIColor.white.withAlphaComponent(0.08)
        address.configuration?.title = "Phone address"
        address.accessibilityLabel = "Enter phone IP address"
        connect.accessibilityLabel = "Connect to Android Auto"
        stop.configuration?.title = "Stop connecting"
        stop.accessibilityLabel = "Stop Android Auto and automatic reconnection"
        let buttons = UIStackView(arrangedSubviews: [connect, address, stop])
        buttons.axis = .vertical
        buttons.spacing = 12
        let content = UIStackView(arrangedSubviews: [progress, buttons])
        content.axis = .vertical
        content.spacing = 26
        content.translatesAutoresizingMaskIntoConstraints = false
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.045)
        card.layer.cornerRadius = 26
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        card.addSubview(content)
        NSLayoutConstraint.activate([
            status.widthAnchor.constraint(lessThanOrEqualTo: content.widthAnchor),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 26),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -26),
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 26),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -26)
        ])
        profileLabel.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        profileLabel.textColor = .systemTeal
        profileLabel.textAlignment = .center
        hintLabel.font = .systemFont(ofSize: 14)
        hintLabel.textColor = UIColor.white.withAlphaComponent(0.55)
        hintLabel.numberOfLines = 3
        hintLabel.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [header, card, profileLabel, hintLabel])
        stack.axis = .vertical
        stack.spacing = 22
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        let preferredWidth = stack.widthAnchor.constraint(equalToConstant: 440)
        preferredWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 50),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -22),
            preferredWidth
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    func updateProfile() {
        let size = ProjectionSettings.effectiveVideoDimensions
        profileLabel.text = "\(size.width) × \(size.height)  ·  \(ProjectionSettings.effectiveFpsLimit.title)"
        let preferences = ProjectionSettings.connectionPreferences
        hintLabel.text = preferences.hasConnectedBefore
            ? (preferences.automaticallyConnectsOnOpen ? "Your phone reconnects when you open HeadunitPad." : "Connect whenever you are ready.")
            : "Start the head unit server on your phone, then connect. Your successful connection will be remembered."
    }
}
