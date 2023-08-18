//
//  SelectableTextView.h
//  Pods
//
//  Created by JoshChen on 2023/8/16.
//
#if __has_include(<RCTText/RCTBaseTextInputView.h>)
#import <RCTText/RCTBaseTextInputView.h>
#else
#import "RCTBaseTextInputView.h"
#endif
#import "Sentence.h"
#ifndef SelectableTextView_h
#define SelectableTextView_h

NS_ASSUME_NONNULL_BEGIN

@interface SelectableTextView : RCTBaseTextInputView

@property (nonnull, nonatomic, copy) NSArray<NSDictionary<NSString *, id> *> *sentences;
@property (nullable, nonatomic, copy) NSArray<NSString *> *menuItems;
@property (nullable, nonatomic, copy) NSString *textColor;
@property (nullable, nonatomic, copy) NSString *fontSize;
@property (nullable, nonatomic, copy) NSString *playingColor;
@property (nullable, nonatomic, copy) NSNumber *playingIndex;
@property (nonatomic, copy) RCTDirectEventBlock onSelection;
@property (nonatomic, copy) RCTDirectEventBlock onClick;
@property (nonatomic, copy) NSMutableArray<Sentence *> *formatedSentences;
@property (nonatomic, copy) NSMutableDictionary<NSNumber *, NSNumber *> *sentenceIndexMap;
@property (nonatomic, copy) NSMutableDictionary<NSNumber *, Sentence *> *sentenceDict;
@property (nonatomic, copy) NSMutableAttributedString *text;
@property (nonatomic, copy) UIColor *playingBgColor;
@property (nonatomic, copy) UIColor *textColorOfHex;
//@property (nonatomic, copy) NSInteger *playingIndex;
@end

NS_ASSUME_NONNULL_END

#endif /* SelectableTextView_h */
