#include <iostream>
#include <fstream>
#include <vector>
#include <cinttypes>
#include <string>
#include <cstdint>
#include "getopt.h"

int usage(const char *name) {
    std::fprintf(stderr, "Usage: %s <opts> [path]\nOpts:\n-s\tSet buffer size\n", name);
    return EXIT_FAILURE;
}

int main(int argc, char *argv[]) {
    std::string line;
    unsigned bufsize(1 << 16);
    std::ios_base::sync_with_stdio(false);
    int c;
    while((c = getopt(argc, argv, "-bh")) >= 0) {
    switch(c) {
        case 'h': return usage(*argv);
        case 'b': bufsize = std::atoi(optarg); break;
    }
    }
    std::ifstream stream(argc == optind ? "/dev/stdin": argv[optind]);
    std::vector<char> buffer(bufsize);
    stream.rdbuf()->pubsetbuf(buffer.data(), buffer.size());
    if(!stream.good()) throw 1;
    std::uint64_t hashval(0), nlines(0);
    std::hash<std::string> hasher;
    while(std::getline(stream, line)) {
        hashval ^= hasher(line);
        ++nlines;
    }
    std::fprintf(stderr, "Hash:%" PRIx64"\tLine Count:%" PRIu64 "\n", hashval, nlines);
}
