A persistent key value store that is based on B-epsilon trees. I saw leveldb but it was written in C++ and i am not a much fan of C++. Hence i thought let me write this in Rust as i haven't written much Rust in a while. Also i am kinda done with Go at this point due to its syntax, error handling, Gc overhead. 

I started by learning what a LSM trees. Here are some links. ScyllaDB has a good basic article on it.
1. https://www.scylladb.com/glossary/log-structured-merge-tree/
2. https://en.wikipedia.org/wiki/Log-structured_merge-tree

Hence going through it and reading it, i purposely felt it was a nice solution, but i wanted something interesting to do. Hence i shifted to search a good data structure or any paper that may indicate if there are any good solution to this problem. 

Thats why i found out B-epsilon trees. Sounds interesting, i went and found some articles:
1. https://blocksandfiles.com/2022/06/29/bε-tree-b-epsilon-tree-beta-epsilon-tree/
2. https://www3.cs.stonybrook.edu/~bender/newpub/2015-BenderFaJa-login-wods.pdf
It kinda combines the power of write in LSM trees and read power of B-Trees. Looks pretty good. Then lets start reading B-epsilon trees implementation and try to write it in Rust.

## B-epsilon implementation in Rust

For this i went back to my competitive programming days. Although i was never a good competitive programmer (i was really bad at remembering tricks), i loved implementing data structures from the site cpalgorithms. Hence i started searching up articles and implementing it.

But midway i learn't about betrfs which uses b epsilon trees where e is a tunnab;le parameter with supposedly ranged between 0.3 to 0.5. Sounds nice to me. So i looked up more and ended up at tokudb which got accquired by percona and good thing about it is it uses fractal trees which is btw whatever i have been reading similar to b epsilon trees but the buffer is not similar to b epsilon trees which btw if i am not wrong is B - B^e which seems fair in manupilating. Maybe i'll know in future even if this was a good decision going down. 

So here is the fractal tree source code [Code](git@github.com:percona/PerconaFT.git) Its basically in ft/ dir and looks mostly unchanged and as old tokudb implementation. But yea its holy big and quite random. Reading c++ so deep and big will be a pain in the ass but yea i'll try to read every operation one by one. 

So for now i have read, watched a bunch of 
