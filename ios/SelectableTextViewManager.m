#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(SelectableTextViewManager, RCTViewManager)
//RCT_EXPORT_VIEW_PROPERTY(color, NSString)
RCT_EXPORT_VIEW_PROPERTY(menuItems, NSArray)
RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTDirectEventBlock)
@end
