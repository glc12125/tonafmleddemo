//
//  SocketTypes.h
//  portscaner
//
//  Created by Liangchuan Gu on 12/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#ifndef INCLUDED_SOCKETTYPES_HEADER
#define INCLUDED_SOCKETTYPES_HEADER

namespace TONAFMLED {
    
    enum SOCKET_ERROR {
        NOERRROR,
        SOCKETERROR,
        CONNECTERROR,
        READERROR,
        WRITEERROR
    };
    
}// End of TONAFMLED

#endif // INCLUDED_SOCKETTYPES_HEADER
