/*************************************************************
    图的深度优先遍历  头文件
    更新于2020年6月17日
**************************************************************/
#include "stdio.h"
#include "stdlib.h"
#define MAXVEX 20      /*最大顶点数*/
#define MAXSIZE MAXVEX /*队列最大容量*/

typedef enum { DG, DN, UDG, UDN } GraphKind; /*有向图，有向网，无向图，无向网*/
typedef struct ENode                         /*表结点类型*/
{
    int adjvex;
    struct ENode *nextarc;
    int weight;
} ENode;
typedef int VexType;
typedef struct VNode /*头结点类型*/
{
    VexType vex;
    ENode *firstarc;
} VNode, AdjList[MAXVEX]; /*邻接表类型定义*/
typedef struct {
    AdjList vertices; /*用邻接表存储顶点集合及边集合*/
    int vexnum, edgenum;
    GraphKind kind;
} ALGraph; /*邻接表存储的图的类型定义*/

typedef int datatype;
typedef struct {
    datatype data[MAXSIZE]; /*存放顶点编号*/
    int front;
    int rear;  //队尾指针，指向队尾元素的下一个位置
    int len;
} SeqQueue;  //循环顺序队列的类型定义

/*******函数声明*******/

void CreateUDG_ALG(ALGraph &g); /*构造无向图的邻接表*/
void PrintAdjList(ALGraph g);   /*输出邻接表*/
void DFSTraverse(ALGraph g);    /*深度优先遍历以邻接表存储的图g*/
void DFS(ALGraph g, int i); /*从未被访问的顶点Vi出发深度优先遍历图g*/
void BFSTraverse(ALGraph g); /*广度优先遍历以邻接表存储的图g*/
void InitQueue(SeqQueue &q); /*队列初始化*/
int QueueEmpty(SeqQueue q);  /*判队空*/
void EnQueue(SeqQueue &q, datatype x);  /*入队*/
void DeQueue(SeqQueue &q, datatype &x); /*出队*/
