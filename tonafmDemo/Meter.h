//
//  Metoer.h
//  tonafmDemo
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#ifndef tonafmDemo_Metoer_h
#define tonafmDemo_Metoer_h

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

namespace TONAFMLED {

class Meter
{
public:
    // Meter constructor arguments:
    // inNumUISteps - the number of steps in the UI element that will be drawn.
    //					This could be a height in pixels or number of bars in an LED style display.
    // inTableSize - The size of the table. The table needs to be large enough that there are no large gaps in the response.
    // inMinDecibels - the decibel value of the minimum displayed amplitude.
    // inRoot - this controls the curvature of the response. 2.0 is square root, 3.0 is cube root. But inRoot doesn't have to be integer valued, it could be 1.8 or 2.5, etc.
    
    Meter(float inMinDecibels = -80., size_t inTableSize = 800, float inRoot = 1.5);
    ~Meter();
    
    float ValueAt(float inDecibels)
    {
        if (inDecibels < v_MinDecibels) return  0.;
        if (inDecibels >= 0.) return 1.;
        int index = (int)(inDecibels * v_ScaleFactor);
        return v_Table[index];
    }
private:
    float	v_MinDecibels;
    float	v_DecibelResolution;
    float	v_ScaleFactor;
    float	*v_Table;
};

}

#endif
