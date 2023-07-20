@objc(SelectableTextViewManager)
class SelectableTextViewManager: RCTViewManager {
    
    override func view() -> (SelectableTextView) {
        return SelectableTextView()
    }
    
    @objc override static func requiresMainQueueSetup() -> Bool {
        return false
    }
}

class SelectableTextView : UIView {
    private let textView: TextView = {
        let textView = TextView()
        textView.text = "Tap and hold to show the 'Comment' menu 123 45 "
        return textView
    }()
    @objc var menuItems: [String] = [""] {
        didSet {
            let menuItems = menuItems.map({
                UIMenuItem(title: $0, action: #selector(onSelectCallback))
            })
            UIMenuController.shared.menuItems = menuItems
        }
    }
    @objc var onSelection: RCTDirectEventBlock?
    
    //    @objc var color: String = "" {
    //        didSet {
    //            self.backgroundColor = hexStringToUIColor(hexColor: color)
    //        }
    //    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextView()
    }
    
    private func setupTextView() {
        // Add the UITextView to the custom view
        addSubview(textView)
        
        // Set the constraints for the UITextView (you can adjust this as needed)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    // Action method to handle the tap gesture
    @objc func onSelectCallback(menu: UIMenuItem) {
        if let textRange = textView.selectedTextRange {
            let startPosition = textRange.start
            let endPosition = textRange.end
            
            // Convert UITextPosition to an integer offset
            let startIndex = textView.offset(from: textView.beginningOfDocument, to: startPosition)
            let endIndex = textView.offset(from: textView.beginningOfDocument, to: endPosition)
            let selection = (
                range: [startIndex, endIndex],
                text: textView.text(in: textRange) ?? "",
                key: menu.title
            )
            // Perform actions when the UITextView is tapped
            onSelection!(["range": selection.range, "text": selection.text, "key": selection.key])
            print("onCommentClick: \(menu.title)")
        }
    }
    
    //    func hexStringToUIColor(hexColor: String) -> UIColor {
    //        let stringScanner = Scanner(string: hexColor)
    //
    //        if(hexColor.hasPrefix("#")) {
    //            stringScanner.scanLocation = 1
    //        }
    //        var color: UInt32 = 0
    //        stringScanner.scanHexInt32(&color)
    //
    //        let r = CGFloat(Int(color >> 16) & 0x000000FF)
    //        let g = CGFloat(Int(color >> 8) & 0x000000FF)
    //        let b = CGFloat(Int(color) & 0x000000FF)
    //
    //        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    //    }
}

//class TextViewDelegate: NSObject, UITextViewDelegate {
////    func
//}
