//
//  main.cpp
//  step1
//
//  Created by ljpc on 2018/12/8.
//  Copyright © 2018年 ljpc. All rights reserved.
//

#include <iostream>
#include <cstdio>
#include <cstring>
#include <algorithm>

using namespace std;

int main(int argc, const char * argv[]) {
    
    char s[1001];
    int a[1001];
    int k;
    int n;
    
    // 请在这里补充代码，完成本关任务
    /********* Begin *********/

    scanf("%s", s);
    scanf("%d", &k);
    int i;
    for (i = 0; s[i] != '\0'; ++i)
        a[i] = s[i] - '0';
    n = i;

    while (k--) {
        int j;
        for (i = 0; a[i] == -1 && i < n - 1; ++i) ;
        for (j = i + 1; a[j] == -1 && j < n; ++j) ;
        while (i < n - 1 && j < n) {
            if (a[i] < a[j]) {
                a[i] = -1;
                break;
            }
            for (++i; a[i] == -1 && i < n - 1; ++i) ;
            for (++j; a[j] == -1 && j < n; ++j) ;
        }
        if (j == n) a[i] = -1;
    }

    for (i = 0; i < n; ++i) {
        if (a[i] != -1) printf("%d", a[i]);
    }
    printf("\n");

    /********* End *********/
    
    return 0;
}
