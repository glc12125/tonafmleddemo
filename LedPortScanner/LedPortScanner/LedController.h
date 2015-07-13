//
//  LedController.h
//  portscaner
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#ifndef INCLUDED_LEDCONTROLLER_HEADER
#define INCLUDED_LEDCONTROLLER_HEADER

#include "Address.h"
#include <vector>

namespace TONAFMLED {

class LedController
{
public:
    bool controllByRGBAndAvgPower(const std::vector<Address>& ledVector,
                                  int8_t red,
                                  int8_t green,
                                  int8_t blue,
                                  float avgPower);
};
    
} // end of TONAFMLED namespace

#endif /* defined(__portscaner__LedController__) */
