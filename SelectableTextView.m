//
//  SelectableTextView.m
//  react-native-selectable-text
//
//  Created by JoshChen on 2023/8/16.
//

#if __has_include(<RCTText/RCTTextSelection.h>)
#import <RCTText/RCTTextSelection.h>
#else
#import "RCTTextSelection.h"
#endif

#if __has_include(<RCTText/RCTUITextView.h>)
#import <RCTText/RCTUITextView.h>
#else
#import "RCTUITextView.h"
#endif

#import "SelectableTextView.h"

#if __has_include(<RCTText/RCTTextAttributes.h>)
#import <RCTText/RCTTextAttributes.h>
#else
#import "RCTTextAttributes.h"
#endif

#import <React/RCTUtils.h>
#import "Sentence.h"
@implementation SelectableTextView
{
    RCTUITextView *_backedTextInputView;
}
//NSString *const RNST_CUSTOM_SELECTOR = @"_CUSTOM_SELECTOR_";
//
//UITextPosition *selectionStart;
UITextPosition* beginning;
NSMutableArray<Sentence *> *formatedSentences;
NSMutableDictionary<NSNumber *, NSNumber *> *sentenceIndexMap;
UIColor *playingBgColor;
- (instancetype)initWithBridge:(RCTBridge *)bridge
{
    if (self = [super initWithBridge:bridge]) {
        _backedTextInputView = [[RCTUITextView alloc] initWithFrame:self.bounds];
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
        playingBgColor = [UIColor clearColor];
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
//- (void)setSentences:(NSArray<NSDictionary<NSString *,id> *> *)sentences {
//    NSMutableArray<Sentence *> *newSentences = [NSMutableArray array];
//    NSMutableDictionary<NSNumber *, NSNumber *> *newSentenceIndexMap = [NSMutableDictionary dictionary];
//    NSMutableString *pargraph = [NSMutableString stringWithString:@""];
//    NSUInteger currentIndex = 0;
//    NSUInteger lastCount = 0;
//    for (NSDictionary<NSString *, id> *item in sentences) {
//        Sentence *sentence = [[Sentence alloc] initWithContent:item[@"content"] ?: @"" index:[item[@"index"] integerValue] others:@{}];
//        for (NSString *key in item) {
//            if ([key isEqualToString:@"content"] || [key isEqualToString:@"index"]) {
//                if ([key isEqualToString:@"content"]) [pargraph appendString:item[key]];
//                continue;
//            }
//            sentence.others[key] = [item[key] isKindOfClass:[NSString class]] ? item[key] : @"";
//        }
//        for (NSUInteger i = 0; i < [sentence.content length]; i++) {
//            [newSentenceIndexMap setObject:@(currentIndex) forKey:@(i + lastCount)];
//        }
//        [newSentences addObject:sentence];
//        lastCount += sentence.content.length;
//        currentIndex++;
//    }
//    sentenceIndexMap = newSentenceIndexMap;
//    formatedSentences = newSentences;
//    NSLog(@"fontSize: %@", self.fontSize);
//    if (pargraph.length > 0) {
//        NSAttributedString *str = [[NSAttributedString alloc] initWithString:pargraph attributes:self.textAttributes.effectiveTextAttributes];
//        [super setAttributedText:str];
//    }
//}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    NSMutableArray<Sentence *> *newSentences = [NSMutableArray array];
    NSMutableDictionary<NSNumber *, NSNumber *> *newSentenceIndexMap = [NSMutableDictionary dictionary];
    NSMutableString *pargraph = [NSMutableString stringWithString:@""];
    NSUInteger currentIndex = 0;
    NSUInteger lastCount = 0;
    for (NSDictionary<NSString *, id> *item in self.sentences) {
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
        lastCount += sentence.content.length;
        currentIndex++;
    }
    sentenceIndexMap = newSentenceIndexMap;
    formatedSentences = newSentences;
    NSLog(@"playingIndex %@", self.playingIndex);
    NSLog(@"playingBgColor %@", playingBgColor);
    if (pargraph.length > 0) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:pargraph attributes:self.textAttributes.effectiveTextAttributes];

        [super setAttributedText:str];
    } else {
        [super setAttributedText:attributedText];
    }
}
- (void) setPlayingColor:(NSString *)playingColor {
    if (!playingColor) return;
    playingBgColor = [self hexStringToUIColor:playingColor];
}
//- (void) setPlayingIndex:(NSNumber *)playingIndex {
//    if (!self.sentences) return;
//    NSInteger startIndex = -1;
//    NSInteger currentIndex = 0;
//    NSInteger endIndex = 0;
//    for (Sentence *sentence in self.sentences) {
//        endIndex += sentence.content.length;
//        if (startIndex == sentence.index) {
//            startIndex = currentIndex;
//            break;
//        }
//        currentIndex++;
//    }
//    NSLog(@"index: %lu", startIndex);
//    if (startIndex == -1) return;
//    [self clearBackgroundColor];
//
//    NSMutableAttributedString *mutableAttributedText = [self.attributedText mutableCopy];
//    [mutableAttributedText addAttribute:NSBackgroundColorAttributeName value:self.playingColor range:NSMakeRange(startIndex, endIndex)];
//    [super setAttributedText:mutableAttributedText];
//}
- (void)clearBackgroundColor {
    NSMutableAttributedString *mutableAttributedText = [self.attributedText mutableCopy];
    [mutableAttributedText removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, mutableAttributedText.length)];
//    playingBgColor = [UIColor clearColor];
    [super setAttributedText:mutableAttributedText];
}
//- (void)setFontSize:(NSString *)fontSize {
//    NSMutableAttributedString *mutableAttributedText = [self.attributedText mutableCopy];
//    UIFont *newFont = [UIFont systemFontOfSize:[fontSize integerValue]];
//    [mutableAttributedText addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, mutableAttributedText.length)];
//    [super setAttributedText:mutableAttributedText];
//}
//- (void)setTextColor:(NSString *)textColor {
//    NSMutableAttributedString *mutableAttributedText = [self.attributedText mutableCopy];
//    UIColor *newColor = [self hexStringToUIColor:textColor];
//    [mutableAttributedText enumerateAttributesInRange:NSMakeRange(0, mutableAttributedText.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey, id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
//        [mutableAttributedText addAttribute:NSForegroundColorAttributeName value:newColor range:range];
//    }];
//    [super setAttributedText:mutableAttributedText];
//}
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
    
    self.onSelection(@{
        @"selectedSentences": [self convertSentencesToArray:findSentences],
        @"selectionStart": @(startIndex),
        @"selectionEnd": @(endIndex),
        @"content": [[self.attributedText string] substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)],
        @"eventType": menuItem.title
    });
    
}
- (NSArray<Sentence *> *) getSentences:(NSInteger)start end:(NSInteger)end {
    NSLog(@"start: %li, end: %li", start, end);
    NSMutableSet *set = [NSMutableSet set];
    NSMutableArray<Sentence *> *newSentences = [NSMutableArray array];
    for (NSInteger index = start; index < end; index++) {
        if ([sentenceIndexMap.allKeys containsObject:@(index)]) {
            [set addObject:sentenceIndexMap[@(index)]];
        }
    }
    for (NSString *index in set) {
        NSInteger key = [index integerValue];
        [newSentences addObject: formatedSentences[key]];
    }
    return newSentences;
}
- (NSArray *)convertSentencesToArray: (NSArray<Sentence *>*) sentences {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *formatedArray = [[NSMutableArray alloc] init];
    for (Sentence *sentence in sentences) {
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
//    NSArray<Sentence *> *findSentences =[self getSentences:offsetStart end:offsetEnd];
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
