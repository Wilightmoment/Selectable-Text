//
//  SelectableTextView.m
//  react-native-selectable-text
//
//  Created by JoshChen on 2023/8/16.
//
#import "SelectableTextView.h"

#if __has_include(<RCTText/RCTTextAttributes.h>)
#import <RCTText/RCTTextAttributes.h>
#else
#import "RCTTextAttributes.h"
#endif

#import <React/RCTUtils.h>
#import "Sentence.h"
#import "TextView.h"
#import "AttributedStringRange.h"

@implementation SelectableTextView
{
    RCTUITextView *_backedTextInputView;
}
//NSString *const RNST_CUSTOM_SELECTOR = @"_CUSTOM_SELECTOR_";
//
//UITextPosition *selectionStart;
UITextPosition* beginning;
- (instancetype)initWithBridge:(RCTBridge *)bridge
{
    if (self = [super initWithBridge:bridge]) {
        _backedTextInputView = [[TextView alloc] initWithFrame:self.bounds];
        _backedTextInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backedTextInputView.backgroundColor = [UIColor clearColor];
        _backedTextInputView.textColor = [UIColor blackColor];
        // This line actually removes 5pt (default value) left and right padding in UITextView.
        _backedTextInputView.textContainer.lineFragmentPadding = 0;
#if !TARGET_OS_TV
        _backedTextInputView.scrollsToTop = NO;
#endif
        _backedTextInputView.scrollEnabled = NO;
        _backedTextInputView.textInputDelegate = self;
        _backedTextInputView.editable = NO;
        _backedTextInputView.selectable = YES;
        beginning = _backedTextInputView.beginningOfDocument;
        self.textSize = [UIFont systemFontOfSize: 14];
        self.textColorOfHex = [UIColor blackColor];
        self.playingBgColor = [UIColor clearColor];
        self.highlightBGColor = [UIColor clearColor];
        self.playingSentence = [[NSNumber alloc] initWithInt: -1];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(onTapCallback:)];
        [_backedTextInputView addGestureRecognizer:tapGesture];
        [self addSubview:_backedTextInputView];
        [self setUserInteractionEnabled:YES];
        [self setAutoFocus:false];
    }
    
    return self;
}
- (id<RCTBackedTextInputViewProtocol>)backedTextInputView
{
    return _backedTextInputView;
}
- (void)setSentences:(NSArray<NSDictionary<NSString *,id> *> *)sentences {
    NSMutableArray<Sentence *> *newSentences = [NSMutableArray array];
    NSMutableDictionary<NSNumber *, NSNumber *> *newSentenceIndexMap = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSNumber *, Sentence *> *newSentenceDict = [NSMutableDictionary dictionary];
    NSMutableString *pargraph = [NSMutableString stringWithString:@""];
    NSUInteger lastCount = 0;
    for (NSDictionary<NSString *, id> *item in sentences) {
        Sentence *sentence = [[Sentence alloc] initWithContent:item[@"content"] ?: @"" index:[item[@"index"] integerValue] others:@{}];
        for (NSString *key in item) {
            if ([key isEqualToString:@"content"] || [key isEqualToString:@"index"]) {
                if ([key isEqualToString:@"content"]) [pargraph appendString:item[key]];
                continue;
            }
            sentence.others[key] = [item[key] isKindOfClass:[NSString class]] ? item[key] : @"";
        }
        for (NSUInteger i = 0; i < [sentence.content length]; i++) {
            [newSentenceIndexMap setObject:item[@"index"] forKey:@(i + lastCount)];
        }
        [newSentences addObject:sentence];
        [newSentenceDict setObject:sentence forKey:@(sentence.index)];
        NSLog(@"sentenceDict: %@", newSentenceDict);
        lastCount += sentence.content.length;
    }
    self.sentenceIndexMap = newSentenceIndexMap;
    self.formatedSentences = newSentences;
    self.sentenceDict = newSentenceDict;
    if (pargraph.length > 0) {
        self.text = pargraph;
        [self renderText];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    return;
}
- (void) setPlayingColor:(NSString *)playingColor {
    if (!playingColor) return;
    self.playingBgColor = [self hexStringToUIColor:playingColor];
    [self renderText];
}
- (void) setPlayingIndex:(NSNumber *)playingIndex {
    self.playingSentence = playingIndex;
    [self renderText];
}
- (AttributedStringRange *)getAttributedStringPosition:(NSNumber *) playingSentenceIndex {
    AttributedStringRange *result = [[AttributedStringRange alloc] init];
    result.startIndex = -1;
    result.endIndex = 0;
    result.startIndex = 0;
    if (!self.formatedSentences) return result;
    for (Sentence *sentence in self.formatedSentences) {
        if ([playingSentenceIndex integerValue] == sentence.index) {
            result.endIndex = sentence.content.length;
            break;
        }
        result.startIndex += sentence.content.length;
        result.currentIndex++;
    }
    return result;
}
- (void) setPlayingSentence {
    if (!self.formatedSentences || !self.text) return;
    NSMutableAttributedString *mutableAttributedString = [self getAttributedText];
    [self removeBackgroundColor:mutableAttributedString color:self.playingBgColor];
    AttributedStringRange *result = [self getAttributedStringPosition:self.playingSentence];
    if (result.currentIndex < self.formatedSentences.count && self.playingBgColor) {
        [mutableAttributedString addAttribute:NSBackgroundColorAttributeName value:self.playingBgColor range:NSMakeRange(result.startIndex, result.endIndex)];
    }
    [super setAttributedText:mutableAttributedString];
    [_backedTextInputView setAttributedText:mutableAttributedString];
}
- (void)setFontSize:(NSString *)fontSize {
    if (!fontSize) return;
    NSLog(@"setFontSize %@", fontSize);
    UIFont *newFont = [UIFont systemFontOfSize:[fontSize integerValue]];
    self.textSize = newFont;
    [self renderText];
}
- (void)setHighlightIndexes:(NSArray<NSNumber *> *)highlightIndexes {
    self.highlightSentences = highlightIndexes;
    [self renderText];
}
- (NSMutableAttributedString *) getAttributedText {
    NSAttributedString *originalAttributedString = _backedTextInputView.attributedText;
    bool hasAttributedString = originalAttributedString.length > 0;
    // 初始化一個新的 NSMutableAttributedString，如果 originalAttributedString 為 null
    NSMutableAttributedString *newAttributedString = (hasAttributedString) ? [[NSMutableAttributedString alloc] initWithAttributedString:originalAttributedString] : [[NSMutableAttributedString alloc] initWithString:self.text];
    // 檢查第一個字符的字體大小
    NSRange detectRange = NSMakeRange(0, 1); // 這裡只檢查第一個字符，你可以根據需要調整範圍
    NSRange range = NSMakeRange(0, self.text.length);
    UIFont *currentFont = [newAttributedString attribute:NSFontAttributeName atIndex:detectRange.location effectiveRange:nil];
    UIColor *currentTextColor = [newAttributedString attribute:NSForegroundColorAttributeName atIndex:detectRange.location effectiveRange:nil];

    // 如果字體顏色不等於預期的顏色，則進行更改
    if (![currentTextColor isEqual:self.textColorOfHex]) {
        // 設置新的字體顏色
        [newAttributedString addAttribute:NSForegroundColorAttributeName value:self.textColorOfHex range:range];
    }
    // 如果字體大小不等於預期的大小，則進行更改
    if (currentFont.pointSize != self.textSize.pointSize) {
        // 創建一個新的字體
        UIFont *newFont = [UIFont fontWithName:currentFont.fontName size:self.textSize.pointSize];
        // 設置新的字體
        [newAttributedString addAttribute:NSFontAttributeName value:newFont range:range];
    }
    return newAttributedString;

}
- (void)setHighlightSentence {
    if (!self.formatedSentences || !self.text || !self.highlightSentences) return;
    NSMutableAttributedString *mutableAttributedString = [self getAttributedText];
    [self removeBackgroundColor:mutableAttributedString color:self.highlightBGColor];
    for (NSNumber *key in self.highlightSentences) {
        AttributedStringRange *result = [self getAttributedStringPosition:key];
        if (result.currentIndex < self.formatedSentences.count && self.highlightBGColor) {
            [mutableAttributedString addAttribute:NSBackgroundColorAttributeName value:self.highlightBGColor range:NSMakeRange(result.startIndex, result.endIndex)];
        }
    }
    [super setAttributedText:mutableAttributedString];
    [_backedTextInputView setAttributedText:mutableAttributedString];
}
- (void)removeBackgroundColor:(NSMutableAttributedString *)attributedString color:(UIColor *)color {
    if (attributedString != nil) {
        [attributedString enumerateAttribute:NSBackgroundColorAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if ([value isKindOfClass:[UIColor class]] && [value isEqual:color]) {
                [attributedString removeAttribute:NSBackgroundColorAttributeName range:range];
            }
        }];
    }
}
- (void)renderText {
    [self setHighlightSentence];
    [self setPlayingSentence];
}
- (void)setTextColor:(NSString *)textColor {
    NSLog(@"setTextColor %@", textColor);
    UIColor *newColor = [self hexStringToUIColor:textColor];
    self.textColorOfHex = newColor;
    [self renderText];
}
- (void)setHighlightColor:(NSString *) highlightColor {
    NSLog(@"setHighlightColor %@", highlightColor);
    UIColor *newColor = [self hexStringToUIColor:highlightColor];
    self.highlightBGColor = newColor;
    [self renderText];
}
- (UIColor *)hexStringToUIColor:(NSString *)hexColor {
    NSScanner *stringScanner = [NSScanner scannerWithString:hexColor];
    
    if ([hexColor hasPrefix:@"#"]) {
        [stringScanner setScanLocation:1];
    }
    
    uint32_t color = 0;
    [stringScanner scanHexInt:&color];
    
    CGFloat r = (CGFloat)((color >> 16) & 0x000000FF);
    CGFloat g = (CGFloat)((color >> 8) & 0x000000FF);
    CGFloat b = (CGFloat)(color & 0x000000FF);
    
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
}
- (void)setMenuItems:(NSArray *)menuItems {
    NSMutableArray *NewMenuItems = [NSMutableArray array];
    for (NSString *title in menuItems) {
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:title action:@selector(onSelectCallback:)];
        [NewMenuItems addObject:menuItem];
    }
    UIMenuController.sharedMenuController.menuItems = NewMenuItems;
}
- (void)onSelectCallback:(UIMenuItem *)menuItem {
    if (!self.onSelection) return;
    UITextRange *selectionRange = [_backedTextInputView selectedTextRange];
    NSInteger startIndex = [_backedTextInputView offsetFromPosition:beginning toPosition:selectionRange.start];
    NSInteger endIndex = [_backedTextInputView offsetFromPosition:beginning toPosition:selectionRange.end];
    NSArray<Sentence *> *findSentences = [self getSentences:startIndex end:endIndex];
    NSLog(@"findSentences: %@", findSentences);
    self.onSelection(@{
        @"selectedSentences": [self convertSentencesToArray:findSentences],
        @"selectionStart": @(startIndex),
        @"selectionEnd": @(endIndex),
        @"content": [[self.attributedText string] substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)],
        @"eventType": menuItem.title
    });
    [_backedTextInputView setSelectedRange:NSMakeRange(0, 0)];
}
- (NSArray<Sentence *> *) getSentences:(NSInteger)start end:(NSInteger)end {
    NSMutableSet *set = [NSMutableSet set];
    NSMutableArray<Sentence *> *newSentences = [NSMutableArray array];
    for (NSInteger index = start; index < end; index++) {
        if ([self.sentenceIndexMap.allKeys containsObject:@(index)]) {
            [set addObject:self.sentenceIndexMap[@(index)]];
        }
    }
    NSLog(@"sentenceIndexMap: %@", self.sentenceIndexMap);
    NSLog(@"sentenceDict: %@", self.sentenceDict);
    for (NSString *index in set) {
        NSInteger key = [index integerValue];
        if ([self.sentenceDict.allKeys containsObject:@(key)]) {
            [newSentences addObject: self.sentenceDict[@(key)]];
        }
    }
    return newSentences;
}
- (NSArray *)convertSentencesToArray: (NSArray<Sentence *>*) sentences {
    
    NSMutableArray *formatedArray = [[NSMutableArray alloc] init];
    for (Sentence *sentence in sentences) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSString *key in sentence.others) {
            [dict setValue:sentence.others[key] forKey:key];
        }
        [dict setValue:@(sentence.index) forKey:@"index"];
        [dict setValue:sentence.content forKey:@"content"];
        [formatedArray addObject:dict];
    }
    return formatedArray;
}
- (void)onTapCallback:(UITapGestureRecognizer *)gestureRecognizer {
    if (!self.onClick) return;
    [_backedTextInputView setSelectedRange:NSMakeRange(0, 0)];
    CGPoint location = [gestureRecognizer locationInView:_backedTextInputView];
    UITextPosition *tappedTextPosition = [_backedTextInputView closestPositionToPoint:location];
    UITextRange *textRange = [_backedTextInputView.tokenizer rangeEnclosingPosition:tappedTextPosition withGranularity:UITextGranularityWord inDirection:UITextWritingDirectionLeftToRight];
    
    NSInteger offsetStart = [_backedTextInputView offsetFromPosition:beginning toPosition:textRange.start];
    NSInteger offsetEnd = [_backedTextInputView offsetFromPosition:textRange.start toPosition:textRange.end];
    
    NSString *tappedText = [[self.attributedText string] substringWithRange:NSMakeRange(offsetStart, offsetEnd)];
    NSLog(@"tap-offset: %lu, %lu", offsetStart, offsetEnd);
    NSArray *tappedSentences = [self convertSentencesToArray:[self getSentences:offsetStart end:(offsetStart + offsetEnd)]];
    self.onClick(@{
        @"selectedSentences": tappedSentences,
        @"content": tappedText
    });
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(onSelectCallback:)) {
        return YES;
    }
    return NO;
}
@end
