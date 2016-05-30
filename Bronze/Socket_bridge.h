//
//  Socket_bridge.h
//  Bronze
//
//  Created by Take Vos on 2016-05-21.
//  Copyright © 2016 Take Vos. All rights reserved.
//

#ifndef Socket_bridge_h
#define Socket_bridge_h

int fcntl_setint(int fildes, int cmd, int value);
int fcntl_getint(int fildes, int cmd, int *value);

#endif /* Socket_bridge_h */
