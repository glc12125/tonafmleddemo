//
//  PortScanner.cpp
//  portscaner
//
//  Created by Liangchuan Gu on 08/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//


#include "PortScanner.h"
#include "SocketTypes.h"

#include <iostream>
#include <future>         // std::async, std::future
#include <chrono>         // std::chrono::milliseconds

#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <fcntl.h>        // For Socket options
#include <unistd.h>       // For closeing file descriptor

namespace TONAFMLED {
    
    namespace {
        enum ScannerState{ Stopped, Running };
    }
    
    static const std::string getNetworkAdress(){
        std::string address("error");
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = 0;
        
        // retrieve the current interfaces - returns 0 on success
        success = getifaddrs(&interfaces);
        if (success == 0) {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while (temp_addr != NULL) {
                if( temp_addr->ifa_addr->sa_family == AF_INET) {
                    // Check if interface is en0 which is the wifi connection on the iPhone
                    if ( strncmp (temp_addr->ifa_name,"en0", 3) == 0 ) {
                        // Get NSString from C String
                        address = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr);
                    }
                }
                
                temp_addr = temp_addr->ifa_next;
            }
        }
        
        // Free memory
        freeifaddrs(interfaces);
        
        std::cout << "Local IP: " << address << std::endl;
        size_t pos = address.find_last_of(".");
        if (pos == std::string::npos) {
            std::cout << "wrong ip!" << std::endl;
            return "";
        } else {
            return address.substr(0, pos+1);
        }
        
        return address;
    }
    
    static bool port_is_open(const std::string& address, int port, int timeOut)
    {
        struct sockaddr_in	servaddr;
        int errorCode = NOERRROR;
        int sockfd;
        if ( (sockfd = socket(PF_INET, SOCK_STREAM, 0)) < 0){
            errorCode = SOCKETERROR;
            return false;
        } else {
            memset(&servaddr,0, sizeof(servaddr));
            servaddr.sin_family = AF_INET;
            servaddr.sin_port = htons(port);
            inet_pton(AF_INET, address.c_str(), &servaddr.sin_addr);
            
            struct timeval ts;
            ts.tv_sec = 0;
            ts.tv_usec = timeOut*1000;
            
            fd_set set;
            FD_ZERO(&set);
            FD_SET(sockfd, &set);
            
            fcntl(sockfd, F_SETFL, O_NONBLOCK);
            int rc;
            if ( (rc = connect(sockfd, (struct sockaddr*)&servaddr, sizeof(servaddr))) == -1)
            {
                if ( errno != EINPROGRESS )
                    return false;
                
            }
            
            if(rc == 0) {
                close(sockfd);
                return true;
            }
            //we are waiting for connect to complete now
            if( (rc = select(sockfd + 1, NULL, &set, NULL, (timeOut) ? &ts : NULL)) < 0) {
                close(sockfd);
                return false;
            }
            if(rc == 0){   //we had a timeout
                errno = ETIMEDOUT;
                close(sockfd);
                return false;
            } else {
                close(sockfd);
                return true;
            }
        }
    }
    
    void threadMainWrapper(void * scanner)
    {
        ThreadMainBase * base = static_cast<ThreadMainBase*>(scanner);
        
        base->threadMain();
    }
    
    PortScanner::PortScanner(int scanTimeoutMilliseconds, int seconds, int scanPort) :
    v_scannerInterval(seconds),
    v_scanTimeout(scanTimeoutMilliseconds),
    v_scanPort(scanPort)
    {
    }
    
    PortScanner::~PortScanner()
    {
        stopScannning();
    }
    
    void
    PortScanner::startScanning()
    {
        v_scannerRunning.store(Running);
        v_scanningThread = std::thread(threadMainWrapper, this);
    }
    
    void
    PortScanner::stopScannning()
    {
        v_scannerRunning.store(Stopped);
        if (v_scanningThread.joinable()) {
            v_scanningThread.join();
        }
    }
    
    void
    PortScanner::threadMain()
    {
        while (v_scannerRunning.load() == Running) {
            std::string netWorkAddress(getNetworkAdress());
            int currentHost = 1;
            // This anonymous block is for guard to destruct when finishing
            // one round to scan
            {
                std::unique_lock<std::mutex> guard(v_ledVectorMutex);
                
                while (currentHost < 255) {
                    std::string scanAddress = netWorkAddress;
                    std::string host = std::to_string(currentHost);
                    scanAddress.append(host);
                    
                    if (port_is_open(scanAddress, v_scanPort, v_scanTimeout)) {
                        Address address;
                        address.v_host = scanAddress;
                        address.v_port = v_scanPort;
                        v_ledVector.insert(address);
                        std::cout << scanAddress << ":" << v_scanPort << " : OPEN, adding to list\n";
                    }
                    else {
                        //std::cout << scanAddress << ":" << v_scanPort << " : NOT OPEN\n";
                    }
                    
                    ++currentHost;
                    std::cout << std::flush;
                }
            }
            
            std::this_thread::sleep_for(v_scannerInterval);
        }
    }
    
    void
    PortScanner::getLedAddressList(std::vector<Address>& ledAddressVector)
    {
        std::copy(v_ledVector.begin(), v_ledVector.end(), std::back_inserter(ledAddressVector));
    }
    
} // end of TONAFMLED namespace