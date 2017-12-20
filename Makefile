.PHONY=all
ifndef CXX
CXX=g++
endif
ifndef CC
CC=gcc
endif
ifndef STD
STD=c++17
endif
WARNINGS=-Wall -Wextra -Wno-char-subscripts \
		 -Wpointer-arith -Wwrite-strings -Wdisabled-optimization \
		 -Wformat -Wcast-align -Wno-unused-function -Wunused-variable -Wno-ignored-qualifiers
DBG:= # -DNDEBUG
OPT:= -O3 -funroll-loops -pipe -fno-strict-aliasing -mavx2 -march=native
OS:=$(shell uname)

EXTRA=
OPT:=$(OPT) $(FLAGS)
XXFLAGS=-fno-rtti
CXXFLAGS=$(OPT) $(XXFLAGS) -std=$(STD) $(WARNINGS) $(EXTRA)
CCFLAGS=$(OPT) -std=c11 $(WARNINGS)
LIB=
LD=-L.

OBJS=$(patsubst %.cpp,%.o,$(wildcard lib/*.cpp))
TEST_OBJS=$(patsubst %.cpp,%.o,$(wildcard test/*.cpp))
EXEC_OBJS=$(patsubst %.cpp,%.o,$(wildcard src/*.cpp)) $(patsubst %.cpp,%.fo,$(wildcard src/*.cpp))

EX=$(patsubst src/%.fo,%f,$(EXEC_OBJS)) $(patsubst src/%.o,%,$(EXEC_OBJS))

# If compiling with c++ < 17 and your compiler does not provide
# bessel functions with c++14, you must compile against boost.

INCLUDE=-I. -Iclhash

all: $(OBJS) $(EX) python
print-%  : ; @echo $* = $($*)

obj: $(OBJS) $(EXEC_OBJS)

test/%.o: test/%.cpp $(OBJS)
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LD) $(OBJS) -c $< -o $@ $(LIB)

%.fo: %.cpp
	$(CXX) $(CXXFLAGS) -DFLOAT_TYPE=float $(DBG) $(INCLUDE) $(LD) -c $< -o $@ $(LIB)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -DFLOAT_TYPE=double $(DBG) $(INCLUDE) $(LD) -c $< -o $@ $(LIB)

%: src/%.cpp $(OBJS)
	$(CXX) $(CXXFLAGS) -DFLOAT_TYPE=double $(DBG) $(INCLUDE) $(LD) $(OBJS) $< -o $@ $(LIB)

%f: src/%.cpp $(OBJS)
	$(CXX) $(CXXFLAGS) -DFLOAT_TYPE=float $(DBG) $(INCLUDE) $(LD) $(OBJS) $< -o $@ $(LIB)

%.o: %.c
	$(CC) $(CCFLAGS) -Wno-sign-compare $(DBG) $(INCLUDE) $(LD) -c $< -o $@ $(LIB)

#tests: clean unit

#unit: $(OBJS) $(TEST_OBJS)
#	$(CXX) $(CXXFLAGS) $(INCLUDE) $(TEST_OBJS) $(LD) $(OBJS) -o $@ $(LIB)

clean:
	rm -f $(OBJS)

mostlyclean: clean
