//
//  Metoer.cpp
//  tonafmDemo
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#include "Meter.h"

namespace TONAFMLED {
    

double DbToAmp(double inDb)
{
    return pow(10., 0.05 * inDb);
}

Meter::Meter(float inMinDecibels, size_t inTableSize, float inRoot)
: v_MinDecibels(inMinDecibels),
v_DecibelResolution(v_MinDecibels / (inTableSize - 1)),
v_ScaleFactor(1. / v_DecibelResolution)
{
    if (inMinDecibels >= 0.)
    {
        printf("Meter inMinDecibels must be negative");
        return;
    }
    
    v_Table = (float*)malloc(inTableSize*sizeof(float));
    
    double minAmp = DbToAmp(inMinDecibels);
    double ampRange = 1. - minAmp;
    double invAmpRange = 1. / ampRange;
    
    double rroot = 1. / inRoot;
    for (size_t i = 0; i < inTableSize; ++i) {
        double decibels = i * v_DecibelResolution;
        double amp = DbToAmp(decibels);
        double adjAmp = (amp - minAmp) * invAmpRange;
        v_Table[i] = pow(adjAmp, rroot);
    }
}

Meter::~Meter()
{
    free(v_Table);
}

}