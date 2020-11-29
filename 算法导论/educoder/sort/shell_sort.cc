#include <cstdio>

using namespace std;

void print_array(int *arr, int n)
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
//  编程实现《希尔排序算法》：将乱序序列arr转化为升序序列
//  函数参数：乱序整数数组（无重复元素） 数组长度
//  要求输出：调用print_array(int *arr, int
//  n)输出前三次选择操作后的序列，以及最终的升序序列
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    int shell[] = {5, 2, 1};
    for (int k = 0; k < 3; ++k) {
        int step = shell[k];
        for (int sorted = 0; sorted + step < n; ++sorted) {
            int i = sorted;
            int temp = arr[sorted + step];
            for (; i >= 0 && temp < arr[i]; i = i - step)
                arr[i + step] = arr[i];
            arr[i + step] = temp;
        }
        print_array(arr, n);
    }
    print_array(arr, n);
    /********** End **********/
}
