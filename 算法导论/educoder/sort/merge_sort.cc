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

int* merge_array(int* arr1, int n1, int* arr2, int n2)
//  编程实现两个有序数组arr1和arr2合并
//  函数参数：有序数组arr1 数组arr1长度 有序数组arr2 数组arr2长度
//  函数返回值：返回从小到大排序后的合并数组
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    int INT_MAX = 2147483647;
    int* newArr1 = new int[n1 + 1];
    for (int i = 0; i < n1; ++i) {
        newArr1[i] = arr1[i];
    }
    newArr1[n1] = INT_MAX;
    int* newArr2 = new int[n2 + 1];
    for (int i = 0; i < n2; ++i) {
        newArr2[i] = arr2[i];
    }
    newArr2[n2] = INT_MAX;

    // !This new is not paired with a delete. Cause memory leak?
    int* merged = new int[n1 + n2];
    for (int i = 0, j = 0; i + j < n1 + n2;) {
        if (newArr1[i] < newArr2[j]) {
            merged[i + j] = newArr1[i];
            ++i;
        } else {
            merged[i + j] = newArr2[j];
            ++j;
        }
    }
    delete[] newArr1;
    delete[] newArr2;
    return merged;
    /********** End **********/
}

int* merge_sort(int* arr, int n)
//  基于merge_array函数编程实现归并排序：自上而下的递归方法
//  函数参数：有序数组arr 数组arr长度
//  函数返回值：返回从小到大排序后的数组
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    if (n == 1) {
        int* res = new int[1];
        res[0] = arr[0];
        return res;
    };
    if (n == 0) {
        int* res = new int[0];
        return res;
    }

    int mid = n / 2;
    int* arr1 = new int[mid];
    int* arr2 = new int[n - mid];
    for (int i = 0; i < mid; ++i) {
        arr1[i] = arr[i];
    }
    for (int i = 0; i < n - mid; ++i) {
        arr2[i] = arr[i + mid];
    }

    int* sortedArr1 = merge_sort(arr1, mid);
    int* sortedArr2 = merge_sort(arr2, n - mid);
    delete[] arr1;
    delete[] arr2;
    return merge_array(sortedArr1, mid, sortedArr2, n - mid);
    /********** End **********/
}

int main() {
    int arr[] = {2, 1, 4, 3};
    int* res = merge_sort(arr, 4);
    for (int i = 0; i < 4; ++i) {
        cout << res[i] << " ";
    }
    cout << endl;
    for (int i = 0; i < 4; ++i) {
        cout << arr[i] << " ";
    }
    cout << endl;
}