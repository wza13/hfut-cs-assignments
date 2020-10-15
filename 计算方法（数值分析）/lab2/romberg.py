import math


def romberg(f, a, b, epsilon):
    def update_k_h_t_s(k, h, t2, s2):
        k += 1
        h /= 2
        t1 = t2[-1]
        s1 = s2[-1]
        return (k, h, t1, s1)

    def update_c(c2):
        c1 = c2[-1]
        return c1

    def update_r(r2):
        r1 = r2[-1]
        return r1

    t2 = []
    s2 = []
    c2 = []
    r2 = []
    h = b - a
    t1 = (f(a) + f(b)) * h / 2
    t2.append(t1)
    s1 = 0
    c1 = 0
    r1 = 0
    k = 1

    while True:
        s = 0
        x = a + h / 2
        while x < b:
            s = s + f(x)
            x = x + h
        t2.append(t1 / 2 + s * h / 2)

        s2.append(t2[-1] + (t2[-1] - t1) / 3)
        if k == 1:
            k, h, t1, s1 = update_k_h_t_s(k, h, t2, s2)
        else:
            c2.append(s2[-1] + (s2[-1] - s1) / 15)
            if k == 2:
                c1 = update_c(c2)
                k, h, t1, s1 = update_k_h_t_s(k, h, t2, s2)
            else:
                r2.append(c2[-1] + (c2[-1] - c1) / 63)
                if k == 3 or math.fabs(r2[-1] - r1) >= epsilon:
                    r1 = update_r(r2)
                    c1 = update_c(c2)
                    k, h, t1, s1 = update_k_h_t_s(k, h, t2, s2)
                else:
                    break

    print("k\t2^k\tS", "T", "C", "R", sep="\t\t")
    len_t = len(t2)
    for k in range(len_t):
        print(str(k) + "\t" + str(2**k), end="\t")
        print(format(t2[k], ".6f"), end="\t")
        if len(s2) >= len_t - k:
            print(format(s2[k - 1], ".6f"), end="\t")
        if len(c2) >= len_t - k:
            print(format(c2[k - 2], ".6f"), end="\t")
        if len(r2) >= len_t - k:
            print(format(r2[k - 3], ".6f"), end="\t")
        print()

    return r2[-1]


# romberg(lambda x: math.sin(x) / x, 1e-7, 1, 1e-6)
