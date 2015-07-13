//
//  PortScannerSingleton.h
//  tonafmDemo
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <LedPortScanner/Address.h>
#import <vector>

@interface PortScannerSingleton : NSObject

@property (readonly, atomic) BOOL isScanning;

+ (PortScannerSingleton *) sharedInstance;
- (void) startScanning;
- (void) stopScanning;
- (NSArray *) getLedList;

- (void) getLedVector: (std::vector<TONAFMLED::Address>&) vector;

@end
