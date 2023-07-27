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
    private let textView = CustomTextView()
    @objc var menuItems: [String] = [""] {
        didSet {
            let menuItems = menuItems.map({
                UIMenuItem(title: $0, action: #selector(onSelectCallback))
            })
            UIMenuController.shared.menuItems = menuItems
        }
    }
    @objc var onSelection: RCTDirectEventBlock?
    @objc var onClick: RCTDirectEventBlock?
    @objc var sentences: NSArray = [] {
        didSet {
            var newSenteces: [Sentence] = []
            for case let item as [String: Any] in sentences {
                let item = Sentence(content: item["content"] as? String ?? "", start_time: item["start_time"] as? Float ?? 0, end_time: item["end_time"] as? Float ?? 0, index: item["index"] as? Int ?? 0)
                newSenteces.append(item)
            }
            print("didSet sentences: ", newSenteces)
            textView.setSentences(newSenteces)
        }
    }
    @objc var fontSize: String? = nil {
        didSet {
            if let fontSizeString = fontSize, let fontSizeValue = Float(fontSizeString) {
                textView.font = UIFont.systemFont(ofSize: CGFloat(fontSizeValue))
            }
        }
    }
    @objc var playingIndex: NSNumber? = 0 {
        didSet {
            if let index = playingIndex {
                textView.setPlayingSentence(playingIndex: index.intValue)
            }
        }
    }
    @objc var playingColor: String? = nil {
        didSet {
            if let hex = playingColor {
                textView.setPlayingBGColor(hexStringToUIColor(hex))
            }
        }
    }
    @objc var textColor: String? = nil {
        didSet {
            if let hex = textColor {
                textView.setTextColor(hexStringToUIColor(hex))
            }
        }
    }
    
    // Action method to handle the tap gesture
    @objc func onSelectCallback(menu: UIMenuItem) {
        if let textRange = textView.selectedTextRange {
            let startPosition = textRange.start
            let endPosition = textRange.end
            
            // Convert UITextPosition to an integer offset
            let startIndex = textView.offset(from: textView.beginningOfDocument, to: startPosition)
            let endIndex = textView.offset(from: textView.beginningOfDocument, to: endPosition)
            let selectedSentences = textView.getSentences((start: startIndex, end: endIndex))
            
            // Perform actions when the UITextView is tapped
            onSelection!([
                "selectionStart": startIndex,
                "selectionEnd": endIndex,
                "content": textView.text(in: textRange) ?? "",
                "eventType": menu.title,
                "selectedSentences": selectedSentences
            ])
            print("onCommentClick: \(menu.title)")
        }
    }
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {        
        let location = gestureRecognizer.location(in: textView)
        let tappedTextPosition = textView.closestPosition(to: location)
        
        if let tappedRange = textView.tokenizer.rangeEnclosingPosition(tappedTextPosition!, with: .word, inDirection: UITextDirection.init(rawValue: 1)) {
            let tappedText = textView.text(in: tappedRange)
            let tappedTextStart = textView.offset(from: textView.beginningOfDocument, to: tappedRange.start)
            let tappedTextEnd = textView.offset(from: textView.beginningOfDocument, to: tappedRange.end)
            let selectedSentences = textView.getSentences((start: tappedTextStart, end: tappedTextEnd))
            onClick!([
                "selectedSentences": selectedSentences,
                "tappedText": tappedText ?? "",
                "tappedTextStart": tappedTextStart,
                "tappedTextEnd": tappedTextEnd
            ])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(textView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        textView.setContentHuggingPriority(.defaultLow, for: .vertical) // Lower priority for hugging
        textView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical) // Higher priority for compression resistance
    }
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //        self.sizeToFit()
    //    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(onSelectCallback) {
            return true
        }
        return false
    }
    
    func hexStringToUIColor(_ hexColor: String) -> UIColor {
        let stringScanner = Scanner(string: hexColor)
        
        if(hexColor.hasPrefix("#")) {
            stringScanner.scanLocation = 1
        }
        var color: UInt32 = 0
        stringScanner.scanHexInt32(&color)
        
        let r = CGFloat(Int(color >> 16) & 0x000000FF)
        let g = CGFloat(Int(color >> 8) & 0x000000FF)
        let b = CGFloat(Int(color) & 0x000000FF)
        
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    }
}
