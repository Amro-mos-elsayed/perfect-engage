import UIKit

protocol BottomContainerViewDelegate: class {

  func pickerButtonDidPress()
  func doneButtonDidPress()
  func cancelButtonDidPress()
  func imageStackViewDidPress()
    func rotateDeviceDidPress()
    func galleryButtonPressed()
    func pickerButtonDidHolded()
    func pickerButtonDidReleased()
}

open class BottomContainerView: UIView {

  struct Dimensions {
    static let height: CGFloat = 101
  }
    
    struct RotateCameraDimensions {
        static let leftOffset: CGFloat = 11
        static let rightOffset: CGFloat = -11
        static let height: CGFloat = 34
    }

  var configuration = Configuration()

  lazy var pickerButton: ButtonPicker = { [unowned self] in
    let pickerButton = ButtonPicker(configuration: self.configuration)
    pickerButton.setTitleColor(UIColor.clear, for: UIControl.State())
    pickerButton.delegate = self
    pickerButton.numberLabel.isHidden = !self.configuration.showsImageCountLabel
    pickerButton.numberLabel.isHidden = true
    return pickerButton
    }()

  lazy var borderPickerButton: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth
    view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize / 2

    return view
    }()
    
    open lazy var rotateCamera: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(AssetManager.getImage("rotatecameraIcon"), for: UIControl.State())
        button.addTarget(self, action: #selector(rotateCameraButtonDidPress(_:)), for: .touchUpInside)
        //        button.imageView?.contentMode = .center
        
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        return button
        }()
    
    lazy var UserDescriptionLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = self.configuration.userDescriptionLabelFont
        label.textColor = self.configuration.userDisplayLabelColor
        label.text = self.configuration.userDescriptionLabelText
        label.sizeToFit()
        
        return label
        }()
    
    open lazy var galleryButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(AssetManager.getImage("galleryIcon"), for: UIControl.State())
        button.addTarget(self, action: #selector(galleryButtonPressed(_:)), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        return button
        }()

  open lazy var doneButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitle(self.configuration.cancelButtonTitle, for: UIControl.State())
    button.titleLabel?.font = self.configuration.doneButton
    button.addTarget(self, action: #selector(doneButtonDidPress(_:)), for: .touchUpInside)
    button.tintColor = .white
    button.isHidden = true
    return button
    }()

  lazy var stackView = ImageStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = self.configuration.backgroundColor

    return view
    }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleTapGestureRecognizer(_:)))

    return gesture
    }()

  weak var delegate: BottomContainerViewDelegate?
  var pastCount = 0

  // MARK: Initializers

  public init(configuration: Configuration? = nil) {
    if let configuration = configuration {
      self.configuration = configuration
    }
    super.init(frame: .zero)
    configure()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure() {
    //MARK:- changed by ragu
    //added
//    if configuration.canRotateCamera {
//        rotateCamera.layer.shadowColor = UIColor.black.cgColor
//        rotateCamera.layer.shadowOpacity = 0.5
//        rotateCamera.layer.shadowOffset = CGSize(width: 0, height: 1)
//        rotateCamera.layer.shadowRadius = 1
//        rotateCamera.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(rotateCamera)
//    }
    
    [borderPickerButton, pickerButton, doneButton, stackView, topSeparator, UserDescriptionLabel, galleryButton, rotateCamera].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    backgroundColor = configuration.backgroundColor
    stackView.accessibilityLabel = "Image stack"
    stackView.addGestureRecognizer(tapGestureRecognizer)
    stackView.isHidden = true
    stackView.clipsToBounds = true

    setupConstraints()
  }

  // MARK: - Action methods

  @objc func doneButtonDidPress(_ button: UIButton) {
    if button.currentTitle == configuration.cancelButtonTitle {
      delegate?.cancelButtonDidPress()
    } else {
      delegate?.doneButtonDidPress()
    }
  }

  @objc func handleTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
    delegate?.imageStackViewDidPress()
  }
    
    @objc func rotateCameraButtonDidPress(_ button: UIButton) {
        delegate?.rotateDeviceDidPress()
    }
    
    @objc func galleryButtonPressed(_ button: UIButton) {
        delegate?.galleryButtonPressed()
    }

  fileprivate func animateImageView(_ imageView: UIImageView) {
    imageView.transform = CGAffineTransform(scaleX: 0, y: 0)

    UIView.animate(withDuration: 0.3, animations: {
      imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
      }, completion: { _ in
        UIView.animate(withDuration: 0.2, animations: {
          imageView.transform = CGAffineTransform.identity
        })
    })
  }
}

// MARK: - ButtonPickerDelegate methods

extension BottomContainerView: ButtonPickerDelegate {
    func buttonStartHolding() {
        delegate?.pickerButtonDidHolded()
    }
    
    func buttonEndHolding() {
        delegate?.pickerButtonDidReleased()
    }
    

  func buttonDidPress() {
    delegate?.pickerButtonDidPress()
  }
}
