#!/bin/bash

read MSG
key=$(echo "$MSG" | awk '{print $2}')
node=$(. /kvnode/util_find_node.sh $key)

if [ "${MSG:0:3}" = "GET" ]; then
    if test $node = $NODENAME ; then
        cat /database/$key
    else
        echo "GET $key" | nc $node 7776
    fi

elif  [ "${MSG:0:3}" = "PUT" ]; then
    if test $node = $NODENAME ; then
        cat - > /database/$key
        echo $key
    else
        cat <(echo "PUT $key") - | nc -N $node 7776
    fi

elif  [ "${MSG:0:3}" = "DEL" ]; then
    if test $node = $NODENAME ; then
        rm /database/$key
    else
        echo "DEL $key" | nc $node 7776
    fi

else
    echo "ERROR: Unsupported operation (only PUT/GET/DEL supported)"
fi
