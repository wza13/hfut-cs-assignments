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

int partition_array(int *arr ,int l,int r)
// 编程实现arr[l, r]分区：选定一个基准，左边比基准小，右边比基准大
// 返回基准所处位置
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    int pivot = arr[l];
    while (l < r) {
        while (l < r && arr[r] >= pivot)
            --r;
        if (l < r)
            arr[l] = arr[r];
        while (l < r && arr[l] <= pivot)
            ++l;
        if (l < r)
            arr[r] = arr[l];
    }
    arr[r] = pivot;
    return r;
    /********** End **********/
}

int* quick_sort(int *arr, int l, int r)
//  基于partition_array函数编程实现快速排序：自上而下的递归方法
//  函数参数：有序数组arr 初始l=0，r=n-1
//  函数返回值：返回从小到大排序后的数组
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    if (l >= r) return arr;
    int mid = partition_array(arr, l, r);    
    arr = quick_sort(arr, l, mid - 1);
    arr = quick_sort(arr, mid + 1, r);
    return arr;
    /********** End **********/
}

int main() {
    int arr[] = {2, 1, 4, 3, 1, 6};
    int* res = quick_sort(arr, 0, 5);
}
