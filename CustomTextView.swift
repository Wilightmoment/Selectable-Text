//
//  CustomTextView.swift
//  react-native-selectable-text
//
//  Created by JoshChen on 2023/7/27.
//

import Foundation

struct Sentence {
    let content: String
    let start_time: Float
    let end_time: Float
    let index: Int
}

class CustomTextView: UITextView, UITextViewDelegate {
    private var sentences: [Sentence] = []
    private var playingIndex = 0
    private let attributedString = NSMutableAttributedString()
    private var attributedStringBGColor = UIColor(ciColor: .green)
    public var sentenceIndexMap = [Int: [Int]] ()
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextView()
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupTextView()
    }
    
    private func setupTextView() {
        self.isEditable = false
        self.isScrollEnabled = false
        self.translatesAutoresizingMaskIntoConstraints = false
//        self.backgroundColor = UIColor(ciColor: .gray)
    }
    
    private func clearBackgroundColor() {
        self.attributedString.removeAttribute(.backgroundColor, range: NSRange(location: 0, length: attributedString.length))
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    public func getSentences(_ position: (start: Int, end: Int)) -> Array<[String: Any]> {
        var selectedSentences: Set<Int> = Set()
        let range = (position.start..<position.end)
        for i in range {
            self.sentenceIndexMap.forEach { item in
                if item.value.contains(i) {
                    selectedSentences.insert(item.key)
                }
            }
        }
        let find = selectedSentences.sorted().map { index in
            let item = self.sentences[index]
            return [
                "content": item.content,
                "index": item.index,
                "start_time": item.start_time,
                "end_time": item.end_time
            ] as [String : Any]
        }
        return find
    }
    
    public func setSentences(_ sentences: [Sentence]) {
        self.sentences = sentences
        var lastCount = 0
        
        for (currentIndex, sentence) in sentences.enumerated() {
            attributedString.append(NSMutableAttributedString(string: sentence.content))
            let charArray = Array(sentence.content)
            let sentenceIndexArray = charArray.enumerated().map { (charIndex, _) in
                charIndex + lastCount
            }
            sentenceIndexMap.updateValue(sentenceIndexArray, forKey: currentIndex)
            lastCount = charArray.count
        }
        self.setPlayingSentence(playingIndex: self.playingIndex)
    }
    
    public func setPlayingBGColor(_ color: UIColor) {
        self.attributedStringBGColor = color
        self.clearBackgroundColor()
        self.setPlayingSentence(playingIndex: self.playingIndex)
    }
    
    public func setTextColor(_ color: UIColor) {
        let range = NSRange(location: 0, length: attributedString.length)
        self.attributedString.removeAttribute(.foregroundColor, range: range)
        self.attributedString.addAttribute(.foregroundColor, value: color, range: range)
        self.setPlayingSentence(playingIndex: self.playingIndex)
    }
    
    public func setPlayingSentence(playingIndex: Int) {
        self.playingIndex = playingIndex
        // clear background color
        self.clearBackgroundColor()
        // find playing sentence of index
        let startIndex = self.sentences.firstIndex { sentence in
            sentence.index == playingIndex
        }
        
        if startIndex == nil {
            self.attributedText = self.attributedString
            return
        }
        let string = attributedString.string
        if let range = string.range(of: self.sentences[startIndex ?? 0].content) {
            let nsRange = NSRange(range, in: string)
            attributedString.addAttribute(.backgroundColor, value: self.attributedStringBGColor, range: nsRange)
        }
        self.attributedText = self.attributedString
//        self.sizeToFit()
    }
}
