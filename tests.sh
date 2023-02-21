#!/bin/bash 

echo "Executing unit tests..."
docker-compose run --rm node1 /bin/bash /kvnode/unit_tests.sh

###################################

check() {
    if [ $? -ne 0 ]; then
        echo "KO :("
    else
        echo "OK :)"
    fi
}

test_put_get() {
    ( ( (echo "PUT $1"; cat $2) | nc -N localhost 7776 ) | ( echo "$1" | ( diff /dev/fd/3 /dev/fd/4 ) 4<&0 ) 3<&0 )
    check

    ( echo "GET $1" | nc localhost 7776 ) > /tmp/retrievedfile
    diff $2 /tmp/retrievedfile
    check
}

test_del() {
    echo "DEL $1" | nc localhost 7776
    check

    echo "GET $1" | nc localhost 7776
    check
}

echo "Executing integration tests..."
# Node 1
test_put_get hashme tests.sh
test_put_get hashme docker-compose.yml
test_del hashme
# Node 4
test_put_get hashmetoo tests.sh
test_put_get hashmetoo docker-compose.yml
test_del hashmetoo
