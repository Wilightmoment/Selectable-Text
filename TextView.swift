//
//  TextView.swift
//  react-native-selectable-text
//
//  Created by JoshChen on 2023/7/19.
//

import UIKit

class TextView: UITextView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextView()
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupTextView()
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    func setupTextView() {
        self.isEditable = false
        self.font = UIFont.systemFont(ofSize: 18)
    }
}
