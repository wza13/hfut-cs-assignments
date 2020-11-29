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

void adjustHeap(int* arr, int start, int end)
// 编程实现堆的调整
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    // When this function is called,
    // the two subtrees should already be heaps.
    for (int parent = start, son = start * 2 + 1;
         son <= end;
         parent = son, son = son * 2 + 1
    ) {
        // The parent should swap with the bigger son (if it's going to swap)
        if (son + 1 <= end && arr[son] < arr[son + 1])
            son = son + 1;
        if (arr[parent] >= arr[son]) return;
        swap(arr[parent], arr[son]);
    }
    /********** End **********/
}

int* heap_sort(int* arr, int n)
//  基于adjustHeap函数编程实现堆排序
//  函数参数：无序数组arr 数组长度n
//  函数返回值：返回从小到大排序后的数组
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    // Build a heap.
    for (int i = (n - 2) / 2; i >= 0; --i)
        adjustHeap(arr, i, n - 1);
    // Remove the max of arr, which is the top of heap.
    for (int i = n - 1; i > 0; --i) {
        swap(arr[0], arr[i]);
        adjustHeap(arr, 0, i - 1);
    }
    return arr;
    /********** End **********/
}
