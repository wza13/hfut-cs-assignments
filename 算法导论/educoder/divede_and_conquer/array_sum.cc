#include <stdio.h>
#include <iostream>
using namespace std;

int sum(int arr[], int l, int r);
int another_num(int arr[], int l, int r);

int main()
{   
    /**********  Begin  **********/
    // int num,i;
    // scanf("%d",&num);
    // int a[num];
    // for(i=0;i<num;i++)
    //     scanf("%d",&a[i]);
    
    int num = 10;
    // int a[] = {1 ,3 ,5 ,7 ,9 ,10 ,8 ,6 ,4 ,2};
    // int a[] = {10 ,9 ,8 ,7 ,6 ,5 ,4 ,3 ,2 ,1};
    int a[] = {4, 2, 10, 1, 5, 3, 9, 8, 7, 6};
    printf("分治法求出数组元素的和为:%d\n", sum(a, 0, num - 1));
    /**********  End  **********/
}

int sum(int arr[], int l, int r) {
    if (l > r) return 0;
    if (l == r) return arr[l];
    int mid = (l + r) / 2;
    return sum(arr, l, mid) + sum(arr, mid + 1, r);
}

int another_num(int arr[], int l, int r) {
    if (l == r) return arr[l];
    return arr[l] + another_num(arr, l + 1, r);
}
