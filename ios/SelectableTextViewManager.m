#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(SelectableTextViewManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(menuItems, NSArray)
RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onClick, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMeasure, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(sentences, NSArray)
RCT_EXPORT_VIEW_PROPERTY(fontSize, NSString)
RCT_EXPORT_VIEW_PROPERTY(playingIndex, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(playingColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(textColor, NSString)
@end
