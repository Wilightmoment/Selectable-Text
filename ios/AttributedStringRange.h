//
//  AttributedStringRange.h
//  Pods
//
//  Created by JoshChen on 2023/8/16.
//
#import <Foundation/Foundation.h>
#ifndef AttributedStringRange_h
#define AttributedStringRange_h

@interface AttributedStringRange : NSObject
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) NSInteger endIndex;
@property (nonatomic, assign) NSInteger currentIndex;

@end


#endif /* AttributedStringRange_h */
