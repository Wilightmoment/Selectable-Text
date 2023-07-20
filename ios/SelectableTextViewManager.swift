@objc(SelectableTextViewManager)
class SelectableTextViewManager: RCTViewManager {
    
    override func view() -> (SelectableTextView) {
        return SelectableTextView()
    }
    
    @objc override static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
class SelectableTextView : UITextView {
    @objc var menuItems: [String] = [""] {
        didSet {
            let menuItems = menuItems.map({
                UIMenuItem(title: $0, action: #selector(onSelectCallback))
            })
            UIMenuController.shared.menuItems = menuItems
        }
    }
    @objc var onSelection: RCTDirectEventBlock?
    @objc var value: String = "" {
        didSet {
            self.text = value
            self.sizeToFit()
        }
    }
    @objc var fontSize: String? = nil {
        didSet {
            if let fontSizeString = fontSize, let fontSizeValue = Float(fontSizeString) {
                font = UIFont.systemFont(ofSize: CGFloat(fontSizeValue))
                self.sizeToFit()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextView()
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupTextView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.sizeToFit()
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(onSelectCallback) {
            return true
        }
        return false
    }
    
    private func setupTextView() {
        isEditable = false
        isScrollEnabled = false
        translatesAutoresizingMaskIntoConstraints = true
    }
    
    // Action method to handle the tap gesture
    @objc func onSelectCallback(menu: UIMenuItem) {
        if let textRange = self.selectedTextRange {
            let startPosition = textRange.start
            let endPosition = textRange.end
            
            // Convert UITextPosition to an integer offset
            let startIndex = self.offset(from: self.beginningOfDocument, to: startPosition)
            let endIndex = self.offset(from: self.beginningOfDocument, to: endPosition)
            let selection = (
                range: [startIndex, endIndex],
                text: self.text(in: textRange) ?? "",
                key: menu.title
            )
            // Perform actions when the UITextView is tapped
            onSelection!(["range": selection.range, "text": selection.text, "key": selection.key])
            print("onCommentClick: \(menu.title)")
        }
    }
}
