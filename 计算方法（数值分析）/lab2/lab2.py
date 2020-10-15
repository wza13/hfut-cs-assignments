import os
import math
# from lab2.romberg import romberg
from romberg import romberg
# from lab2.area import area
from area import area


def main():
    problem1()
    print()
    problem2()


def problem1():
    romberg(lambda x: math.sin(x) / x, 1e-7, 1, 1e-6)


def problem2():
    x = []
    y1 = []
    y2 = []
    scale = 40 / 18 * 1e3
    for line in open(os.getcwd() + "/lab2/map.txt").read().splitlines():
        line = line.split(sep=" ")
        if line[0] == "x":
            x += map(float, line[1:])
        elif line[0] == "y1":
            y1 += map(float, line[1:])
        else:
            y2 += map(float, line[1:])
    x = list(map(lambda x: x * scale, x))
    y1 = list(map(lambda x: x * scale, y1))
    y2 = list(map(lambda x: x * scale, y2))
    print("面积为：", int(area(x, y1, y2) / 1e6), " 平方公里", sep="")
    print("精确值为：41288 平方公里", sep="")


main()
