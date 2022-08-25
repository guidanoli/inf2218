#!/usr/bin/env python3

N = 2**4

def to_bin(n):
    return bin(n)[2:]

with open("addbin.txt", "w") as fp:
    for a in range(N):
        a = to_bin(a)
        for b in range(N):
            b = to_bin(b)
            fp.write(f"={a}+{b}\n")
