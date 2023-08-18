//
//  Sentence.m
//  react-native-selectable-text
//
//  Created by JoshChen on 2023/8/16.
//
#import "Sentence.h"
#import <Foundation/Foundation.h>

@implementation Sentence

- (instancetype)initWithContent:(NSString *)content index:(NSInteger)index others:(NSDictionary<NSString *, NSString *> *)others {
    self = [super init];
    if (self) {
        _content = [content copy];
        _index = index;
        _others = [others mutableCopy];
    }
    return self;
}

@end
