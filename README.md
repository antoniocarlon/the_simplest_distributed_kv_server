# The Simplest Distributed KV Server for "large" values

This is an example of a very simple (less than 50 lines of code) distributed KV server capable of storing large values (~128Mb).

## Quickstart

### Requirements
 - Docker
 - Docker compose

### Setup
```
docker-compose up
```

### Configuration
Set up the number of nodes and their names in the `docker-compose.yml` file (the file is configured to use 4 nodes by default and forwards the 7776 port of `node1` to `localhost` for convenience).

Nodes must be named `nodeN` (with consecutive `N`s). For example `node1, node2, ... nodeXX`.

**Note:** The project is set up using Docker Compose for convenience but could be installed on any server with some minor changes (setting up the addresses for the servers and tweaking the file `util_find_node.sh` a bit).

### Usage
Upsert a value to the distributed server (the fist line must be `PUT <key>`):
```
(echo "PUT mykey"; cat myfile) | nc -N localhost 7776
```

Retrieve a value from the distributed server sending `GET <key>`
```
echo "GET mykey" | nc localhost 7776
```

Delete a value from the distributed server sending `DEL <key>`
```
echo "DEL mykey" | nc localhost 7776
```

### Testing
To execute the tests just run `tests.sh`

### About the author
Want to know more about me? Check out my LinkedIn profile! 
https://www.linkedin.com/in/antoniocarlon/

---
The quickstart section ends here :)

---

## Goals and motivation
 - Solve this challenge: https://twitter.com/javisantana/status/1430823534541082631
 - Have fun
 - Refresh my bash and shell script knowledge
 - Learn something new

## Key aspects of the solution
 - Any node can act as the master and send the data to the correct node to be processed (or process it by itself if that's the case).
 - If the data needs to be sent to another node to be processed, it won't be stored locally but sent to the correct node on the fly.
 - The balancing has been implemented by hashing the key (computing the md5 of the key and getting the two first bytes). This allows for a good balancing but the main drawback is that we miss the order, so adjacent keys won't be stored in the same node. In this case I assumed that as we need to store "large" files, the order of the keys won't be important, but in the future it could be interesting to investigate other hashing algorithms.
 - As 128Mb is a large size for the values, instead of just using a simple log file, the storage solution consists of a directory where we store the values as files with the key as the filename.
 - The solution allows to upsert, retrieve and delete values.
 - The solution works with both text and binary values.

## Limitations and possible improvements (in no particular order)
 - Consider splitting the files in equally sized chunks if we plan to receive values of very different sizes (or very large values).
 - Implement some kind of caching mechanism for retrieving objects faster.
 - Use a better hashing algorithm for the partitioning (the current implementation is expected to balance the load uniformly between nodes but won't keep the order so adjacent keys will -can- be stored in different nodes).
 - Implement some mechanism to rebalance the load when adding or removing nodes.
 - Implement a replication mechanism to improve availability and reduce failures.
 - Implement a better server as `socat` doesn't manage connection pooling or prefork the connections (it just performs a fork).
 - Improve the security of the solution.
 - Currently we are storing all the files in the same directory. If the number of files stored increases we will need to split them into separate directories.
 - Compress/uncompress the values (gzip for example) when storing/retrieving them to reduce storage requirements.
 - To prevent strange behavior when two users upsert the same key at the same time, it would be a good idea to implement some kind of blocking mechanism.
 - As the key is used as the filename for the value, the current solution won't allow strange characters (like `/`) in the key.
 - Improve the testing using something like BATS (https://github.com/bats-core/bats-core).
 - Better error handling (checking for null keys/values, missing files, ...).

## Some numbers
Upserting a large (~24MB) file to `node1` (stored in `node1`):
```
time (echo "PUT hashme"; cat myfile.csv) | nc -N localhost 7776
real    0m0,144s
```

Upserting a large (~24MB) file to `node1` (stored in `node4`):
```
time (echo "PUT hashmetoo"; cat myfile.csv) | nc -N localhost 7776
real    0m0,180s
```

Retrieving a large (~24MB) file from `node1` (stored in `node1`):
```
time echo "GET hashme" | nc localhost 7776 > /dev/null
real    0m0,148s
```

Retrieving a large (~24MB) file from `node1` (stored in `node4`):
```
time echo "GET hashmetoo" | nc localhost 7776 > /dev/null
real    0m0,204s
```

Deleting a large (~24MB) file from `node1` (stored in `node1`):
```
time echo "DEL hashme" | nc localhost 7776
real    0m0,066s
```

Deleting a large (~24MB) file from `node1` (stored in `node4`):
```
time echo "DEL hashmetoo" | nc localhost 7776
real    0m0,107s
```

## Steps taken towards the solution
 - Think about the implementation of the solution and the meaning of "simplest". I realized that my interpretation of "simplest" is avoiding overengineering and implementing a good enough solution based on plain old shell scripts only, even if I have to make some trade-offs.
 - Write the first version of the quickstart to gain knowledge on how the solution is going to look from the user point of view.
 - Write the first version of this README file (it has grown and changed a lot because I've used it as a notebook to write about trade-offs, improvements, ...).
 - Make sure that I have gathered all the pieces (this includes struggling with hashes and hexadecimal/binary/decimal numbers and figuring out how I wanted to communicate with and between the servers).
 - Implement the actual solution for short text values (not large values yet) to see if all the pieces fit together and fine tune the communication between servers. This implementation used a log file to store the key and the value.
 - Move from storing a simple key/value (with short text values) to storing files to allow large values. Based on the solution for short text values, my first implementation used a log file to store the key and a hash of the value. The hash of the value was used as a pointer to the actual data which is stored as a file. I realized that the implementation was too complex when I thought about the delete operation and the need for a compacting solution for the log file.
 - Wrapping up (cleaning the code a bit and finishing this README file).
