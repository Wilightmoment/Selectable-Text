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
@implementation SelectableTextView
{
    RCTUITextView *_backedTextInputView;
}
//NSString *const RNST_CUSTOM_SELECTOR = @"_CUSTOM_SELECTOR_";
//
//UITextPosition *selectionStart;
UITextPosition* beginning;
NSInteger playingIndex;
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
        self.playingBgColor = [UIColor clearColor];
        playingIndex = -1;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(onTapCallback:)];
        [_backedTextInputView addGestureRecognizer:tapGesture];
        [self addSubview:_backedTextInputView];
        [self setUserInteractionEnabled:YES];
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
    NSUInteger currentIndex = 0;
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
            [newSentenceIndexMap setObject:@(currentIndex) forKey:@(i + lastCount)];
        }
        [newSentences addObject:sentence];
        [newSentenceDict setObject:sentence forKey:@(sentence.index)];
        NSLog(@"sentenceDict: %@", newSentenceDict);
        lastCount += sentence.content.length;
        currentIndex++;
    }
    self.sentenceIndexMap = newSentenceIndexMap;
    self.formatedSentences = newSentences;
    self.sentenceDict = newSentenceDict;
    if (pargraph.length > 0) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:pargraph attributes:self.textAttributes.effectiveTextAttributes];
        if (self.textColorOfHex) {
            [str addAttribute:NSForegroundColorAttributeName value:self.textColorOfHex range:NSMakeRange(0, str.length)];
        }
        self.text = [str mutableCopy];
        [self setPlayingSentence];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    return;
}
- (void) setPlayingColor:(NSString *)playingColor {
    if (!playingColor) return;
    self.playingBgColor = [self hexStringToUIColor:playingColor];
    [self setPlayingSentence];
}
//- (void) setPlayingIndex:(NSNumber *)_playingIndex {
//    playingIndex = [_playingIndex integerValue];
//    [self setPlayingSentence];
//}
- (void) setPlayingSentence {
    if (!self.formatedSentences || !self.text) return;
    NSLog(@"myText: %@", self.text);
    NSInteger startIndex = -1;
    NSInteger currentIndex = 0;
    NSInteger endIndex = 0;
    for (Sentence *sentence in self.formatedSentences) {
        if (playingIndex == sentence.index) {
            endIndex = sentence.content.length;
            break;
        }
        startIndex += sentence.content.length;
        currentIndex++;
    }
    NSLog(@"startIndex: %lu", startIndex);
    NSLog(@"endIndex: %lu", endIndex);
    [self clearBackgroundColor];
    if (currentIndex < self.formatedSentences.count) {
        [self.text addAttribute:NSBackgroundColorAttributeName value:self.playingBgColor range:NSMakeRange(startIndex + 1, endIndex)];
    }
    [super setAttributedText:self.text];
}
- (void)clearBackgroundColor {
    // Assuming self.text is an NSAttributedString or NSMutableAttributedString
    NSMutableAttributedString *mutableAttributedString = [self.text mutableCopy];
    
    // Remove background color attribute
    [mutableAttributedString removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, mutableAttributedString.length)];
    
    // Assign the modified attributed string back to self.text
    self.text = mutableAttributedString;
    [super setAttributedText:self.text];
}
- (void)setFontSize:(NSString *)fontSize {
    UIFont *newFont = [UIFont systemFontOfSize:[fontSize integerValue]];
    [self.text addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, self.text.length)];
    [super setAttributedText:self.text];
}
- (void)setTextColor:(NSString *)textColor {
    //    NSMutableAttributedString *mutableAttributedText = [self.attributedText mutableCopy];
    UIColor *newColor = [self hexStringToUIColor:textColor];
    self.textColorOfHex = newColor;
    [self.text addAttribute:NSForegroundColorAttributeName value:newColor range:NSMakeRange(0, self.text.length)];
    [super setAttributedText:self.text];
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
    
}
- (NSArray<Sentence *> *) getSentences:(NSInteger)start end:(NSInteger)end {

    NSMutableSet *set = [NSMutableSet set];
    NSMutableArray<Sentence *> *newSentences = [NSMutableArray array];
    for (NSInteger index = start; index < end; index++) {
        if ([self.sentenceIndexMap.allKeys containsObject:@(index)]) {
            [set addObject:self.sentenceIndexMap[@(index)]];
        }
    }
    for (NSString *index in set) {
        NSInteger key = [index integerValue];
        if ([self.sentenceDict.allKeys containsObject:@(key)]) {
            Sentence *aa = self.sentenceDict[@(key)];
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
    CGPoint location = [gestureRecognizer locationInView:_backedTextInputView];
    UITextPosition *tappedTextPosition = [_backedTextInputView closestPositionToPoint:location];
    UITextRange *textRange = [_backedTextInputView.tokenizer rangeEnclosingPosition:tappedTextPosition withGranularity:UITextGranularityWord inDirection:UITextWritingDirectionLeftToRight];
    
    NSInteger offsetStart = [_backedTextInputView offsetFromPosition:beginning toPosition:textRange.start];
    NSInteger offsetEnd = [_backedTextInputView offsetFromPosition:textRange.start toPosition:textRange.end];
    
    NSString *tappedText = [[self.attributedText string] substringWithRange:NSMakeRange(offsetStart, offsetEnd)];
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
