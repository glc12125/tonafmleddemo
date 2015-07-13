//
//  LedController.h
//  tonafmDemo
//
//  Created by Liangchuan Gu on 11/07/2015.
//  Copyright (c) 2015 Lee Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BSDClientErrorCode) {
    NOERRROR,
    SOCKETERROR,
    CONNECTERROR,
    READERROR,
    WRITEERROR
};

#define MAXLINE 4096

@interface LedController : NSObject

@property (nonatomic) int errorCode, sockfd;

-(instancetype)initWithAddress:(NSString *)addr andPort:(int)port;
-(ssize_t) writtenToSocket:(int)sockfdNum withChar:(NSString *)vptr;
-(NSString *) recvFromSocket:(int)lsockfd withMaxChar:(int)max;

@end
