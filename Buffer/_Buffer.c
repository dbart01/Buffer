//
//  _Buffer.c
//  Buffer
//
//  Created by Dima Bart on 2018-05-02.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

#include "_Buffer.h"
#include <stdlib.h>
#include <string.h>

Node NodeCreate(size_t size) {
    Node node;
    node.bytes    = malloc(size);;
    node.capacity = size;
    node.length   = size;
    return node;
}

void NodeWrite(Node node, size_t offset, Bytes bytes, size_t size) {
    // TODO: Verify out-of-bounds
    memcpy(node.bytes + offset, bytes, size);
}

Bytes NodeRead(Node node, size_t offset, size_t size) {
    // TODO: Verify out-of-bounds
    return node.bytes + offset;
}
