def area(x, y1, y2):
    res = 0
    for i in range(len(x) - 1):
        res += ((y2[i + 1] - y1[i + 1]) + (y2[i] - y1[i])) \
                * (x[i + 1] - x[i]) / 2
    # return res * (scale if scale > 1 else 1 / scale)
    return res
