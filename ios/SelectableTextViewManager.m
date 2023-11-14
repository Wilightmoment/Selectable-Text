//#import <React/RCTViewManager.h>
//
//@interface RCT_EXTERN_MODULE(SelectableTextViewManager, RCTViewManager)

//RCT_EXPORT_VIEW_PROPERTY(playingIndex, NSNumber)
//RCT_EXPORT_VIEW_PROPERTY(playingColor, NSString)
//
//@end
#import "SelectableTextView.h"
#import "SelectableTextViewManager.h"

@implementation SelectableTextViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    SelectableTextView *selectable = [[SelectableTextView alloc] initWithBridge:self.bridge];
    return selectable;
}

RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onClick, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(menuItems, NSArray);
RCT_EXPORT_VIEW_PROPERTY(sentences, NSArray);
RCT_EXPORT_VIEW_PROPERTY(textColor, NSString);
RCT_EXPORT_VIEW_PROPERTY(fontSize, NSString);
RCT_EXPORT_VIEW_PROPERTY(playingIndex, NSNumber);
RCT_EXPORT_VIEW_PROPERTY(playingColor, NSString);
RCT_EXPORT_VIEW_PROPERTY(highlightColor, NSString);
RCT_EXPORT_VIEW_PROPERTY(highlightIndexes, NSArray);
#pragma mark - Multiline <TextInput> (aka TextView) specific properties

#if !TARGET_OS_TV
RCT_REMAP_VIEW_PROPERTY(dataDetectorTypes, backedTextInputView.dataDetectorTypes, UIDataDetectorTypes)
#endif

@end
