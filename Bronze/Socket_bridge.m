//
//  Socket_bridge.m
//  Bronze
//
//  Created by Take Vos on 2016-05-21.
//  Copyright © 2016 Take Vos. All rights reserved.
//

#import "Socket_bridge.h"
#include <fcntl.h>

int fcntl_setint(int fildes, int cmd, int value)
{
    return fcntl(fildes, cmd, value);
}

int fcntl_getint(int fildes, int cmd, int *value)
{
    return fcntl(fildes, cmd, value);
}
