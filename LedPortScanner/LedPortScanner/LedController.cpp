//
//  LedController.cpp
//  portscaner
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#include "LedController.h"
#include "SocketTypes.h"

#include <iostream>
#include <arpa/inet.h>
#include <unistd.h>

namespace TONAFMLED {
    
    static size_t writtenToSocket(int sockfdNum, const uint8_t * vptr, size_t size)
    {
        
        ssize_t  nwritten;
        const uint8_t  *ptr = vptr;
        
        size_t n=size;
        int errorCode = NOERRROR;
        while (size > 0) {
            if ( (nwritten = write(sockfdNum, ptr, size)) <= 0) {
                if (nwritten < 0 && errno == EINTR)
                    nwritten = 0;
                else {
                    errorCode = WRITEERROR;
                    return(-1);
                }
            }
            
            size -= nwritten;
            ptr   += nwritten;
        }
        return(n);
    }
    
    bool
    LedController::controllByRGBAndAvgPower(
                                            const std::vector<Address>& ledVector,
                                            int8_t red,
                                            int8_t green,
                                            int8_t blue,
                                            float avgPower)
    {
        std::vector<Address>::const_iterator itr;
        for (itr = ledVector.begin(); itr !=ledVector.end(); ++itr) {
            std::cout << "Start controlling host: "
                      << itr->v_host << ":"
                      << itr->v_port << std::endl;
            // open the socket to write
            struct sockaddr_in	servaddr;
            
            int errorCode = NOERRROR;
            int sockfd;
            // Initializing socket every time, needs to be improved later
            if ( (sockfd = socket(PF_INET, SOCK_STREAM, 0)) < 0)
                errorCode = SOCKETERROR;
            else {
                memset(&servaddr,0, sizeof(servaddr));
                servaddr.sin_family = AF_INET;
                servaddr.sin_port = htons(itr->v_port);
                inet_pton(AF_INET, itr->v_host.c_str(), &servaddr.sin_addr);
                
                if (connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) {
                    errorCode = CONNECTERROR;
                    std::cout << "Cannot connect to Led server: "
                              << itr->v_host << ":"
                              << itr->v_port << std::endl;
                    continue;
                }
            }
            uint8_t initData[6] = { 0, 1, 1, 3, 3, 7 };
            size_t size = sizeof(initData)/sizeof(*initData)+ sizeof(*initData);
            if (writtenToSocket(sockfd, initData, size) == size) {
                std::cout << "Initialized the LED light!" << std::endl;
                uint8_t testData[5] = {86, 120, 120, 120, 170};
                testData[1] = red;
                testData[2] = green;
                testData[3] = (uint8_t)(blue * avgPower) % 255;
                size_t dataSize = sizeof(testData)/sizeof(*testData) + sizeof(*testData);
                if (writtenToSocket(sockfd, testData, dataSize) == dataSize) {
                    std::cout << "Sent test data, orange color!" << std::endl;
                    close(sockfd);
                }
            } else {
                std::cout << "Cannot write to Led server!" << std::endl;
                close(sockfd);
            }
            
        }
        
        return true;
    }
    
}