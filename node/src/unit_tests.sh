#!/bin/bash

check() {
    if [ $? -ne 0 ]; then
        echo "KO :("
    else
        echo "OK :)"
    fi
}

###################################

test_util_get_hash() {
    ( . /kvnode/util_get_hash.sh $1 | ( echo "$2" | ( diff /dev/fd/3 /dev/fd/4 ) 4<&0 ) 3<&0 )
    check
}

test_util_get_hash hashme 4781
test_util_get_hash hashmetoo 51014

###################################

test_util_find_node() {
    ( NUMNODES=$3 . /kvnode/util_find_node.sh $1 | ( echo "$2" | ( diff /dev/fd/3 /dev/fd/4 ) 4<&0 ) 3<&0 )
    check
}

test_util_find_node hashme node1 5
test_util_find_node hashmetoo node4 5
