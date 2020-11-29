#include <cstdio>
#include <iostream>

using namespace std;

void print_array(int* arr, int n)
// 打印数组
{
    if (n == 0) {
        printf("ERROR: Array length is ZERO\n");
        return;
    }
    printf("%d", arr[0]);
    for (int i = 1; i < n; i++) {
        printf(" %d", arr[i]);
    }
    printf("\n");
}

int* sort_array(int *arr, int n)
//  编程实现《基数排序算法》
//  函数参数：乱序整数数组 数组长度
//  函数返回值：返回从小到大排序后的数组
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    int buckets[10][50];
    int bucketCount[10];

    for (int i = 0; i < 10; ++i)   
        bucketCount[i] = 0;
    for (int i = 0; i < n; ++i) {
        int geWei = arr[i] % 10;
        buckets[geWei][bucketCount[geWei]] = arr[i];
        bucketCount[geWei] += 1;
    }
    int count = 0;
    for (int i = 0; i < 10; ++i) {
        for (int j = bucketCount[i]; j > 0; --j)
            arr[count++] = buckets[i][bucketCount[i] - j];
    }

    for (int i = 0; i < 10; ++i)   
        bucketCount[i] = 0;
    for (int i = 0; i < n; ++i) {
        int shiWei = arr[i] / 10;
        buckets[shiWei][bucketCount[shiWei]] = arr[i];
        bucketCount[shiWei] += 1;
    }
    count = 0;
    for (int i = 0; i < 10; ++i) {
        for (int j = bucketCount[i]; j > 0; --j)
            arr[count++] = buckets[i][bucketCount[i] - j];
    }
    return arr;
    /********** End **********/
}
