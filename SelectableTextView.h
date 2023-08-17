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

@end

NS_ASSUME_NONNULL_END

#endif /* SelectableTextView_h */
