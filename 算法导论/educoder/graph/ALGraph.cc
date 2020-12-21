/*************************************************************
    创建采用邻接表存储的无向图  实现文件
    更新于2020年6月17日
**************************************************************/
#include "ALGraph.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int visited[MAXVEX]; /*设访问标志数组为全局变量*/

void CreateUDG_ALG(ALGraph &g) /*构造无向图的邻接表*/
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    int i, j, k;
    ENode *p;
    // printf("请输入图的类型(0-3表示DG,DN,UDG,UDN)、顶点数、边数：\n");
    scanf("%d%d%d", &g.kind, &g.vexnum, &g.edgenum);
    for (i = 0; i < g.vexnum; i++) /*构造头结点数组*/
    {
        g.vertices[i].vex = i;
        g.vertices[i].firstarc = NULL; /*初始化头结点指针域为空*/
    }
    for (k = 0; k < g.edgenum; k++) /*构造邻接表*/
    {
        scanf("%d%d", &i, &j); /*输入一条边所依附的两个顶点的编号*/
        /*将顶点Vj插入到第i个单链表的表头，也就是用“头插法”建立一个单链表*/
        p = (ENode *)malloc(sizeof(ENode)); /*生成表结点*/
        p->adjvex = j;
        p->weight = 0;
        p->nextarc = g.vertices[i].firstarc; /*插入表结点*/
        g.vertices[i].firstarc = p;
        /*将顶点Vi插入到第j个单链表的表头，也就是用“头插法”建立一个单链表*/
        p = (ENode *)malloc(sizeof(ENode));
        p->adjvex = i;
        p->weight = 0;
        p->nextarc = g.vertices[j].firstarc;
        g.vertices[j].firstarc = p;
    }
    /********** End **********/
}

void DFSTraverse(ALGraph g) /*深度优先遍历以邻接表存储的图g*/
{
    int i;
    for (i = 0; i < g.vexnum; i++) /*访问标志数组初始化*/
        visited[i] = 0;
    for (i = 0; i < g.vexnum; i++)
        if (!visited[i]) DFS(g, i); /*对尚未访问的顶点调用DFS函数*/
}
void DFS(ALGraph g, int i) /*从未被访问的顶点Vi出发深度优先遍历图g*/
{
    // 请在这里补充代码，完成本关任务
    /********** Begin *********/
    VNode head = g.vertices[i];
    printf("%d ", head.vex);
    visited[head.vex] = true;
    for (ENode *next = head.firstarc; next != NULL; next = next->nextarc)
        if (!visited[next->adjvex]) DFS(g, next->adjvex);
    /********** End **********/
}

/*广度优先遍历以邻接表存储的图g，由于BFS要求”先被访问的顶点的邻接点也先被访问”，故需借助队列Q实现*/
// 请在这里补充代码，完成本关任务
/********** Begin *********/
void BFS(ALGraph g, int i);
void BFSTraverse(ALGraph g) {
    int i;
    for (i = 0; i < g.vexnum; i++) visited[i] = 0;
    for (i = 0; i < g.vexnum; i++)
        if (!visited[i]) BFS(g, i);
}
void BFS(ALGraph g, int i) {
    SeqQueue q;
    InitQueue(q);
    EnQueue(q, i);
    visited[i] = true;
    while (!QueueEmpty(q)) {
        int vex;
        DeQueue(q, vex);
        VNode head = g.vertices[vex];
        printf("%d ", vex);
        for (ENode *next = head.firstarc; next != NULL; next = next->nextarc) {
            if (!visited[next->adjvex]) {
                EnQueue(q, next->adjvex);
                visited[next->adjvex] = true;
            }
        }
    }
}
/********** End **********/

void PrintAdjList(ALGraph g) /*输出邻接表*/
{
    int i, w;
    ENode *p;
    for (i = 0; i < g.vexnum; i++) {
        printf("%d", g.vertices[i].vex);
        p = g.vertices[i].firstarc;
        while (p) {
            w = p->adjvex;
            printf("->%d", w);
            p = p->nextarc;
        }
        printf("\n");
    }
}

void InitQueue(SeqQueue &q)  //队列的初始化
{
    q.front = q.rear = 0;
    q.len = 0;
}
int QueueEmpty(SeqQueue q)  //判队空
{
    if (q.len == 0)
        return 1;
    else
        return 0;
}
void EnQueue(SeqQueue &q, datatype x)  //将元素x入队
{
    if (q.len == MAXSIZE)  //判队满
    {
        printf("Queue is full\n");
        return;
    }
    q.data[q.rear] = x;
    q.rear = (q.rear + 1) % MAXSIZE;
    q.len++;
}
void DeQueue(SeqQueue &q, datatype &x)  //将队头元素出队
{
    if (q.len == 0)  //判队空
    {
        printf("Queue is empty\n");
        return;
    }
    x = q.data[q.front];
    q.front = (q.front + 1) % MAXSIZE;
    q.len--;
}
