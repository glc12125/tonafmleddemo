//
//  Address.h
//  portscaner
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#ifndef INCLUDED_ADDRESS_HEADER
#define INCLUDED_ADDRESS_HEADER

#include <string>

namespace TONAFMLED {

struct Address
{
    int v_port;
    std::string v_host;
};
    
} // end of TONAFMLED namespace

#endif /* defined(__portscaner__Address__) */
