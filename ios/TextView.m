//
//  TextView.m
//  react-native-selectable-text
//
//  Created by JoshChen on 2023/8/18.
//

#import <Foundation/Foundation.h>
#import "TextView.h"
@implementation TextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) return YES;
    return NO;
}
@end
