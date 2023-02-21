#!/bin/bash

split=$((65536/$NUMNODES))  # 65535 = 2 bytes
hash=$(. /kvnode/util_get_hash.sh $1)

node=1
for (( i=1; i<$NUMNODES+1; ++i )) do
    if [ $hash -ge $((($i-1)*$split)) ] && [ $hash -le $(($i*$split)) ]; then
        node=$i; break
    fi
done

echo "node$node"
