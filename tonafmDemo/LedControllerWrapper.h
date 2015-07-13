//
//  LedControllerWrapper.h
//  tonafmDemo
//
//  Created by Liangchuan Gu on 09/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LedControllerWrapper : NSObject

- (BOOL) controlLedByRgbAndAvgPower : (int8_t) r
                            green: (int8_t) g
                             blue: (int8_t) b
                            avgPower: (float) power;

@end
