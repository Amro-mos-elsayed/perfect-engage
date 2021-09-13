import UIKit

protocol TopViewDelegate: class {

  func flashButtonDidPress(_ title: String)
  func rotateDeviceDidPress()
    func cancelButtonDidPress()
}

open class TopView: UIView {

  struct Dimensions {
    static let leftOffset: CGFloat = 11
    static let rightOffset: CGFloat = -11
    static let height: CGFloat = 34
  }

  var configuration = Configuration()

  var currentFlashIndex = 0
  let flashButtonTitles = ["AUTO", "ON", "OFF"]

  open lazy var flashButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.frame = CGRect(x: self.frame.size.width - 70, y: 0, width: 70, height: 70)
    button.setImage(AssetManager.getImage("AUTO"), for: UIControl.State())
    button.setTitle("AUTO", for: UIControl.State())
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
    button.setTitleColor(UIColor.white, for: UIControl.State())
    button.setTitleColor(UIColor.white, for: .highlighted)
    button.titleLabel?.font = self.configuration.flashButton
    button.tintColor = .white
    button.addTarget(self, action: #selector(flashButtonDidPress(_:)), for: .touchUpInside)
    button.contentHorizontalAlignment = .left

    return button
    }()

//  open lazy var rotateCamera: UIButton = { [unowned self] in
//    let button = UIButton()
//    button.setImage(AssetManager.getImage("cameraIcon"), for: UIControlState())
//    button.addTarget(self, action: #selector(rotateCameraButtonDidPress(_:)), for: .touchUpInside)
//    button.imageView?.contentMode = .center
//
//    return button
//    }()
    
    open lazy var recordingLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "Recording"
        label.textColor = .white
        label.font = self.configuration.flashButton
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
        }()
    
    open lazy var recordingView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = .red
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    open lazy var closeButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        button.setImage(AssetManager.getImage("closeCamera"), for: UIControl.State())
        button.addTarget(self, action: #selector(cancelButtonDidPressed(_:)), for: .touchUpInside)
        button.imageView?.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
        }()
    
  weak var delegate: TopViewDelegate?

  // MARK: - Initializers

  public init(configuration: Configuration? = nil) {
    if let configuration = configuration {
      self.configuration = configuration
    }
    super.init(frame: .zero)
    configure()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure() {
    var buttons: [UIButton] = [flashButton]
    buttons.append(closeButton)

//    if configuration.canRotateCamera {
//      buttons.append(rotateCamera)
//    }

    for button in buttons {
      button.layer.shadowColor = UIColor.black.cgColor
      button.layer.shadowOpacity = 0.5
      button.layer.shadowOffset = CGSize(width: 0, height: 1)
      button.layer.shadowRadius = 1
      button.translatesAutoresizingMaskIntoConstraints = false
      addSubview(button)
    }
    
    addSubview(recordingView)
    addSubview(recordingLabel)
    
    flashButton.isHidden = configuration.flashButtonAlwaysHidden

    setupConstraints()
  }

  // MARK: - Action methods

  @objc func flashButtonDidPress(_ button: UIButton) {
    currentFlashIndex += 1
    currentFlashIndex = currentFlashIndex % flashButtonTitles.count

    switch currentFlashIndex {
    case 1:
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.45, alpha: 1), for: UIControl.State())
      button.setTitleColor(UIColor(red: 0.52, green: 0.52, blue: 0.24, alpha: 1), for: .highlighted)
    default:
        button.setTitleColor(UIColor.white, for: UIControl.State())
      button.setTitleColor(UIColor.white, for: .highlighted)
    }

    let newTitle = flashButtonTitles[currentFlashIndex]

    button.setImage(AssetManager.getImage(newTitle), for: UIControl.State())
    button.setTitle(newTitle, for: UIControl.State())

    delegate?.flashButtonDidPress(newTitle)
  }
    
    @objc func cancelButtonDidPressed(_ button:UIButton){
        delegate?.cancelButtonDidPress()
    }

//  @objc func rotateCameraButtonDidPress(_ button: UIButton) {
//    delegate?.rotateDeviceDidPress()
//  }
}
