import UIKit

extension UIAlertController {
    
    /// Add two textField
    ///
    /// - Parameters:
    ///   - height: textField height
    ///   - hInset: right and left margins to AlertController border
    ///   - vInset: bottom margin to button
    ///   - textFieldOne: first textField
    ///   - textFieldTwo: second textField
    
    func addThreeTextFields(height: CGFloat = 60, hInset: CGFloat = 0, vInset: CGFloat = 0, textFieldOne: TextField.Config?, textFieldTwo: TextField.Config?, textFieldThree: TextField.Config?) {
        let textField = ThreeTextFieldsViewController(height: height, hInset: hInset, vInset: vInset, textFieldOne: textFieldOne, textFieldTwo: textFieldTwo, textFieldThree: textFieldThree)
        set(vc: textField, height: height * 3 + 3 * vInset)
    }
}

final class ThreeTextFieldsViewController: UIViewController {
    
    fileprivate lazy var textFieldView: UIView = UIView()
    fileprivate lazy var textFieldOne: TextField = TextField()
    fileprivate lazy var textFieldTwo: TextField = TextField()
    fileprivate lazy var textFieldThree: TextField = TextField()

    fileprivate var height: CGFloat
    fileprivate var hInset: CGFloat
    fileprivate var vInset: CGFloat
    
    init(height: CGFloat, hInset: CGFloat, vInset: CGFloat, textFieldOne configurationOneFor: TextField.Config?, textFieldTwo configurationTwoFor: TextField.Config?,textFieldThree configurationThreeFor: TextField.Config?) {
        self.height = height
        self.hInset = hInset
        self.vInset = vInset
        super.init(nibName: nil, bundle: nil)
        view.addSubview(textFieldView)
        
        textFieldView.addSubview(textFieldOne)
        textFieldView.addSubview(textFieldTwo)
        textFieldView.addSubview(textFieldThree)

        textFieldView.width = view.width
        textFieldView.height = height * 3
        textFieldView.maskToBounds = true
        textFieldView.borderWidth = 1
        textFieldView.borderColor = UIColor.lightGray
        textFieldView.cornerRadius = 8
        
        configurationOneFor?(textFieldOne)
        configurationTwoFor?(textFieldTwo)
        configurationTwoFor?(textFieldThree)

        //preferredContentSize.height = height * 2 + vInset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
     textFieldView.width = view.width - hInset * 2
     textFieldView.height = height * 3
     textFieldView.center.x = view.center.x
     textFieldView.center.y = view.center.y
     
     textFieldOne.width = textFieldView.width
     textFieldOne.height = textFieldView.height / 3
     textFieldOne.center.x = textFieldView.width / 2
     textFieldOne.center.y = textFieldView.height / 4
     
     textFieldTwo.width = textFieldView.width
     textFieldTwo.height = textFieldView.height / 3
     textFieldTwo.center.x = textFieldView.width / 2
     textFieldTwo.center.y = textFieldView.height - textFieldView.height / 4
      
      textFieldThree.width = textFieldView.width
      textFieldThree.height = textFieldView.height / 3
      textFieldThree.center.x = textFieldView.width / 2
      textFieldThree.center.y = textFieldView.height - ((textFieldView.height / 4) * 2 )

    }
}

