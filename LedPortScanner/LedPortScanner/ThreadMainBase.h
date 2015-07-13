//
//  ThreadMainBase.h
//  portscaner
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#ifndef INCLUDED_THREADMAINBASE_HEADER
#define INCLUDED_THREADMAINBASE_HEADER

namespace TONAFMLED {

class ThreadMainBase
{
public:
    virtual ~ThreadMainBase(){}
    virtual void threadMain() = 0;

};


} // end of TONAFMLED namespace

#endif
