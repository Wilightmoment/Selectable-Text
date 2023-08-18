//
//  Sentence.h
//  Pods
//
//  Created by JoshChen on 2023/8/16.
//
#import <Foundation/Foundation.h>
#ifndef Sentence_h
#define Sentence_h

@interface Sentence : NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *others;

- (instancetype)initWithContent:(NSString *)content index:(NSInteger)index others:(NSDictionary<NSString *, NSString *> *)others;

@end


#endif /* Sentence_h */
