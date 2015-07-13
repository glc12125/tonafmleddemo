//
//  PortScannerSingleton.m
//  tonafmDemo
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#import "PortScannerSingleton.h"
#import "Address.h"

#import <LedPortScanner/PortScanner.h>

@interface PortScannerSingleton() {
    TONAFMLED::PortScanner *portScanner;
}

@end

@implementation PortScannerSingleton

static PortScannerSingleton* sharedSingleton;

+ (PortScannerSingleton *) sharedInstance
{
    return sharedSingleton;
}

#pragma mark -
#pragma mark initialization methods

//Is called by the runtime in a thread-safe manner exactly once, before the first use of the class.
//This makes it the ideal place to set up the singleton.
+ (void)initialize
{
    //is necessary, because +initialize may be called directly
    static BOOL initialized = NO;
    
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[PortScannerSingleton alloc] init];
    }
}

-(id)init
{
    self = [super init];
    
    if(self != nil)
    {
        // scanTimeoutMilliseconds, seconds, scanPort
        portScanner = new TONAFMLED::PortScanner(100, 60, 5577);
        if(!portScanner)
        {
            self = nil;
        }
    }
    
    return self;
}

- (void) startScanning
{
    if (!_isScanning) {
        portScanner->startScanning();
        _isScanning = YES;
    }
}

- (void) stopScanning
{
    if (_isScanning) {
        portScanner->stopScannning();
        _isScanning = NO;
    }
}

- (NSArray *) getLedList {
    
    NSMutableArray* ledArray = [[NSMutableArray alloc] init];
    
    std::vector<TONAFMLED::Address> ledAddressVector;
    portScanner->getLedAddressList(ledAddressVector);
    std::vector<TONAFMLED::Address>::const_iterator itr;
    for (itr = ledAddressVector.begin(); itr != ledAddressVector.end(); ++itr) {
        Address * address = [[Address alloc] init];
        address.host = [NSString stringWithCString:itr->v_host.c_str()
                                          encoding:[NSString defaultCStringEncoding]];
        address.port = itr->v_port;
        [ledArray addObject:address];
    }
    
    return [NSArray arrayWithArray:ledArray];
}

- (void) getLedVector:(std::vector<TONAFMLED::Address>&) vector
{
    portScanner->getLedAddressList(vector);
}

@end
