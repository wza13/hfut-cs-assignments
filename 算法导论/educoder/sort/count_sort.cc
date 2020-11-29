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

void sort_array(int *arr, int n)
//  编程实现《计数排序算法》
//  函数参数：乱序整数数组 数组长度
//  要求输出：调用print_array(int *arr, int n)输出：
//  每一行一个元素及其个数（升序），如 1 1
//  以及最终的升序序列
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    int min = arr[0];
    int max = arr[0];
    for (int i = 1; i < n; ++i) {
        if (arr[i] > max) max = arr[i];
        if (arr[i] < min) min = arr[i];
    }

    int tempArr[max - min + 1];
    for (int i = 0; i < max - min + 1; ++i)
        tempArr[i] = 0;
    for (int i = 0; i < n; ++i)
        tempArr[arr[i] - min] += 1;

    int count = 0;
    for (int i = 0; i < max - min + 1; ++i) {
        int j = tempArr[i];
        if (j > 0) {
            cout << i + min << " " << j << endl;
            for (; j > 0; --j)
                arr[count++] = i + min;
        }
    }
    print_array(arr, n);
    /********** End **********/
}
