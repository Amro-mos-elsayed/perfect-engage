import UIKit

protocol ButtonPickerDelegate: class {

  func buttonDidPress()
    
    func buttonStartHolding()
    func buttonEndHolding()
}

class ButtonPicker: UIButton {

  struct Dimensions {
    static let borderWidth: CGFloat = 4
    static let buttonSize: CGFloat = 58
    static let buttonBorderSize: CGFloat = 68
  }

  var configuration = Configuration()

  lazy var numberLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = self.configuration.numberLabelFont
    label.isHidden = true
    return label
    }()

  weak var delegate: ButtonPickerDelegate?

  // MARK: - Initializers

  public init(configuration: Configuration? = nil) {
    if let configuration = configuration {
      self.configuration = configuration
    }
    super.init(frame: .zero)
    configure()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  func configure() {
    addSubview(numberLabel)

    subscribe()
    setupButton()
    setupConstraints()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func subscribe() {
    NotificationCenter.default.addObserver(self,
      selector: #selector(recalculatePhotosCount(_:)),
      name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidPush),
      object: nil)

    NotificationCenter.default.addObserver(self,
      selector: #selector(recalculatePhotosCount(_:)),
      name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidDrop),
      object: nil)

    NotificationCenter.default.addObserver(self,
      selector: #selector(recalculatePhotosCount(_:)),
      name: NSNotification.Name(rawValue: ImageStack.Notifications.stackDidReload),
      object: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func setupButton() {
    backgroundColor = UIColor.clear
    layer.cornerRadius = Dimensions.buttonSize / 2
    accessibilityLabel = "Take photo"
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickerButtonDidPress(_:)))
    tapGesture.numberOfTapsRequired = 1
    addGestureRecognizer(tapGesture)
    
    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(pickerButtonDidHighlight(_:)))
    addGestureRecognizer(longGesture)
    
//    addTarget(self, action: #selector(pickerButtonDidPress(_:)), for: .touchUpOutside)
//    addTarget(self, action: #selector(pickerButtonDidHighlight(_:)), for: .touchDown)
  }

  // MARK: - Actions

  @objc func recalculatePhotosCount(_ notification: Notification) {
    guard let sender = notification.object as? ImageStack else { return }
    numberLabel.text = sender.assets.isEmpty ? "" : String(sender.assets.count)
  }

  @objc func pickerButtonDidPress(_ sender: UIGestureRecognizer) {
    backgroundColor = UIColor.clear
    numberLabel.textColor = UIColor.clear
    numberLabel.sizeToFit()
    delegate?.buttonDidPress()
  }

  @objc func pickerButtonDidHighlight(_ sender: UIGestureRecognizer) {
    numberLabel.textColor = UIColor.clear
    if sender.state == .ended {
        print("UIGestureRecognizerStateEnded")
        //Do Whatever You want on End of Gesture
        delegate?.buttonEndHolding()
    }
    else if sender.state == .began {
        print("UIGestureRecognizerStateBegan.")
        //Do Whatever You want on Began of Gesture
        backgroundColor = UIColor.red
        delegate?.buttonStartHolding()
    }
  }
}
