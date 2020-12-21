//
//  main.cpp
//  step1
//
//  Created by ljpc on 2018/12/8.
//  Copyright © 2018年 ljpc. All rights reserved.
//

#include <iostream>
#include <algorithm>
#include <cstdio>

using namespace std;

int divide(int *a, int t, int i) {
    if (t == 1) {
        if (i == 0) return 0;
        return 1;
    }
    long sum = 0;
    for (int k = 1; k < t; ++k)
        sum = (sum + a[k]) * 10;
    sum += i;
    if (sum % t == 0) return 1;
    return 0;
}

void backtrack(int *a, int t, int n, int &sum)
{
    // 请在这里补充代码，完成本关任务
    /********* Begin *********/

    // 如果 t>n, ++sum, return
    // 遍历0-9，
    // 如果 当前遍历值i与a的前t-1位组合在一起能被t整除
    //      a[t] = i; tbacktrack(a, t+1, n, sum)

    if (t > n) {
        ++sum;
        return;
    }
    for (int i = 0; i <= 9; ++i) {
        if (divide(a, t, i)) {
            a[t] = i;
            backtrack(a, t + 1, n, sum);
        }
    }

    /********* End *********/
}


int main(int argc, const char * argv[]) {
    
    int a[101];
    int n;
    scanf("%d", &n);
    
    int sum = 0;
    backtrack(a, 1, n, sum);

    printf("%d\n", sum);
    
    return 0;
}
