//
//  main.cpp
//  step1
//
//  Created by ljpc on 2018/12/8.
//  Copyright © 2018年 ljpc. All rights reserved.
//

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <iostream>

using namespace std;

const int maxn = 101;

int main(int argc, const char* argv[]) {
    int num, i;
    scanf("%d", &num);
    int a[num];
    for (i = 0; i < num; i++) scanf("%d", &a[i]);
    // int num = 10;
    // int i;
    // int a[10] = { 100,11,45,16,17,19,88,22,23,99};

    int dp[num], id[num];
    for (i = 0; i < num; ++i) {
        dp[i] = 1;
        id[i] = i;
    }

    for (i = num - 1; i >=0; --i) {
        int max = dp[i];
        for (int j = i + 1; j < num; ++j) {
            if (a[i] <= a[j] && dp[j] + 1 >= max) {
                max = dp[j] + 1;
                id[i] = j;
            }
        }
        dp[i] = max;
    }

    int max_dp_index = 0;
    for (i = 0; i < num; ++i)
        max_dp_index = dp[i] >= dp[max_dp_index] ? i : max_dp_index;
    int max_dp = dp[max_dp_index];
    int index = max_dp_index;
    while (max_dp--) {
        if (max_dp == 0)
            printf("%i", a[index]);
        else
            printf("%i ", a[index]);
        index = id[index];
    }
    printf("\n");

    return 0;
}
