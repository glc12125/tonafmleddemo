//
//  LedControllerWrapper.m
//  tonafmDemo
//
//  Created by Liangchuan Gu on 09/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#import "LedControllerWrapper.h"
#import "PortScannerSingleton.h"
#import <LedPortScanner/LedController.h>
#import <LedPortScanner/Address.h>

@interface LedControllerWrapper() {
    TONAFMLED::LedController* ledController;
}
@end

@implementation LedControllerWrapper

-(id)init
{
    self = [super init];
    
    if(self != nil)
    {
        ledController = new TONAFMLED::LedController();
        if(!ledController)
        {
            self = nil;
        }
    }
    
    return self;
}


- (BOOL) controlLedByRgbAndAvgPower : (int8_t) r
                               green: (int8_t) g
                                blue: (int8_t) b
                            avgPower: (float) power
{
    std::vector<TONAFMLED::Address> ledAddresses;
    [[PortScannerSingleton sharedInstance] getLedVector:ledAddresses];
    if (ledAddresses.size() == 0) {
        return false;
    }
    return ledController->controllByRGBAndAvgPower(ledAddresses,
                                                   r,
                                                   g,
                                                   b,
                                                   power);
}

@end
