//
//  _Buffer.h
//  Buffer
//
//  Created by Dima Bart on 2018-05-02.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

#ifndef _Buffer_h
#define _Buffer_h

#include <stdio.h>

typedef uint8_t * Bytes;

struct _Node {
    size_t length;
    size_t capacity;
    Bytes _Nonnull bytes;
};

typedef struct _Node Node;

Node NodeCreate(size_t size)
__attribute__((swift_name("Node(size:)")));

void NodeWrite(Node node, size_t offset, _Nonnull Bytes bytes, size_t size)
__attribute__((swift_name("Node.write(self:offset:bytes:size:)")));

_Nonnull Bytes NodeRead(Node node, size_t offset, size_t size)
__attribute__((swift_name("Node.read(self:offset:size:)")));

#endif /* _Buffer_h */
