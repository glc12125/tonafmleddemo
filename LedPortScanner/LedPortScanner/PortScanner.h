//
//  PortScanner.h
//  portscaner
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#ifndef INCLUDED_PORTSCANNER_HEADER
#define INCLUDED_PORTSCANNER_HEADER

#include "Address.h"
#include "ThreadMainBase.h"

#include <set>
#include <vector>
#include <mutex>
#include <chrono>
#include <thread>
#include <atomic>


namespace TONAFMLED {

struct AddressCompare
{
    bool operator()(const Address l, const Address r) const
    {
        return l.v_host.compare(r.v_host) < 0;
    }
};
    
class PortScanner : ThreadMainBase
{
    
public:
    PortScanner(int scanTimeoutMilliseconds = 300, int milliseconds = 5000, int scanPort = 5577);
    ~PortScanner();
    void getLedAddressList(std::vector<Address>& ledAddressVector);
    void startScanning();
    void stopScannning();
    
private:
    virtual void threadMain();
    
private:
    std::thread v_scanningThread;
    std::atomic_int v_scannerRunning;
    std::chrono::seconds v_scannerInterval;
    std::set<Address, AddressCompare> v_ledVector;
    std::mutex v_ledVectorMutex;
    int v_scanTimeout;
    int v_scanPort;
    
};
    
} // end of TONAFMLED

#endif