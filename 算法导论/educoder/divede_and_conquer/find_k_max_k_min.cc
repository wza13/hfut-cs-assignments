#include <stdio.h>
#include <iostream>
using namespace std;

int partition_array(int arr[] ,int l,int r);
int findKMin(int arr[], int l, int r, int k);
int findKMax(int arr[], int l, int r, int k);

int main()
{
	// int num,i;
    // scanf("%d",&num);
    // int a[num];
    // for(i=0;i<num;i++)
    //     scanf("%d",&a[i]);
    
    /**********  Begin  **********/
    int k = 3;
    int num = 10;
    // int a[] = {1 ,3 ,5 ,7 ,9 ,10 ,8 ,6 ,4 ,2};
    // int a[] = {10 ,9 ,8 ,7 ,6 ,5 ,4 ,3 ,2 ,1};
    int a[] = {4, 2, 10, 1, 5, 3, 9, 8, 7, 6};
    int temp[num];

    for (int i = 0; i < num; ++i)
        temp[i] = a[i];
    findKMin(temp, 0, num - 1, k);
    for (int i = 0; i < num; ++i)
        cout << temp[i] << " ";
    cout << endl;

    for (int i = 0; i < num; ++i)
        temp[i] = a[i];
    findKMax(temp, 0, num - 1, num - 1 - k);
    for (int i = 0; i < num; ++i)
        cout << temp[i] << " ";
    cout << endl;

    // printf("max1=%d max2=%d\n", max1, max2);
    // printf("min1=%d min2=%d\n", min1, min2);
    /**********  End  **********/
}

int findKMin(int arr[], int l, int r, int k) {
    if (l > r) return -1;
    int partitionResult = partition_array(arr, l, r);
    if (partitionResult > k) return findKMin(arr, l, partitionResult - 1, k);
    if (partitionResult < k) return findKMin(arr, partitionResult + 1, r, k);
    return partitionResult;
} 

int findKMax(int arr[], int l, int r, int k) {
    // pass k to the value of (len - 1 - k) when initially called.
    if (l > r) return -1;
    int partitionResult = partition_array(arr, l, r);
    if (partitionResult > k) return findKMax(arr, l, partitionResult - 1, k);
    if (partitionResult < k) return findKMax(arr, partitionResult + 1, r, k);
    return partitionResult;
} 

int partition_array(int arr[] ,int l,int r)
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
