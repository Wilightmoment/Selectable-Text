//
//  SelectableTextViewManager.h
//  Pods
//
//  Created by JoshChen on 2023/8/16.
//
#if __has_include(<RCTText/RCTBaseTextInputViewManager.h>)
#import <RCTText/RCTBaseTextInputViewManager.h>
#else
#import "RCTBaseTextInputViewManager.h"
#endif

#ifndef SelectableTextViewManager_h
#define SelectableTextViewManager_h

NS_ASSUME_NONNULL_BEGIN

@interface SelectableTextViewManager : RCTBaseTextInputViewManager

@property (nonnull, nonatomic, copy) NSArray *sentences;
@property (nullable, nonatomic, copy) NSArray<NSString *> *menuItems;
@property (nullable, nonatomic, copy) NSString *textColor;
@property (nullable, nonatomic, copy) NSString *fontSize;
@property (nullable, nonatomic, copy) NSString *playingColor;
@property (nullable, nonatomic, copy) NSNumber *playingIndex;
@property (nonatomic, copy) RCTDirectEventBlock onSelection;
@property (nonatomic, copy) RCTDirectEventBlock onClick;
@end

NS_ASSUME_NONNULL_END

#endif /* SelectableTextViewManager_h */
