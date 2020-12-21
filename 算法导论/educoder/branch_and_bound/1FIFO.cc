//装载问题 队列式分支限界法求解

#include <iostream>

#include "Queue.h"
using namespace std;

int N = 0;

template <class Type>
class QNode {
   public:
    QNode *parent;  //指向父节点的指针
    bool LChild;    //左儿子标识
    Type weight;    //节点所相应的载重量
};

template <class Type>
void EnQueue(Queue<QNode<Type> *> &Q, Type wt, int i, int n, Type bestw,
             QNode<Type> *E, QNode<Type> *&bestE, int bestx[], bool ch);

template <class Type>
Type MaxLoading(Type w[], Type c, int n, int bestx[]);

int main() {
    float c = 0;
    float w[100] = {0};  //下标从1开始
    int x[100];
    float bestw;

    cin >> N;
    cin >> c;
    for (int i = 1; i <= N; i++) {
        cin >> w[i];
    }
    cout << "Ship load:" << c << endl;
    cout << "The weight of the goods to be loaded is:" << endl;
    for (int i = 1; i <= N; i++) {
        cout << w[i] << " ";
    }
    cout << endl;

    bestw = MaxLoading(w, c, N, x);

    cout << "Result:" << endl;
    for (int i = 1; i <= N; i++) {
        cout << x[i] << " ";
    }
    cout << endl;
    cout << "The optimal loading weight is:" << bestw << endl;

    return 0;
}

//将活节点加入到活节点队列Q中
template <class Type>
void EnQueue(Queue<QNode<Type> *> &Q, Type wt, int i, int n, Type bestw,
             QNode<Type> *E, QNode<Type> *&bestE, int bestx[], bool ch) {
    if (i == n)  //可行叶节点
    {
        if (wt == bestw) {
            //当前最优装载重量
            bestE = E;
            bestx[n] = ch;
        }
        return;
    }
    //非叶节点
    QNode<Type> *b;
    b = new QNode<Type>;
    b->weight = wt;
    b->parent = E;
    b->LChild = ch;
    Q.Add(b);
}

template <class Type>
Type MaxLoading(
    Type w[], Type c, int n,
    int bestx[]) {  //队列式分支限界法，返回最优装载重量，bestx返回最优解
                    //初始化
    Queue<QNode<Type> *> Q;  //活节点队列
    Q.Add(0);                //同层节点尾部标识
    int i = 1;               //当前扩展节点所处的层
    Type Ew = 0,             //扩展节点所相应的载重量
        bestw = 0,           //当前最优装载重量
        r = 0;               //剩余集装箱重量

    for (int j = 2; j <= n; j++) {
        r += w[j];
    }

    QNode<Type> *E = 0,  //当前扩展节点
        *bestE;          //当前最优扩展节点

    //搜索子集空间树
    //**************begin************/
    while (true) {
        //检查左儿子节点
        Type wt = Ew + w[i];
        if (wt <= c)  //可行节点
        {
            if (wt > bestw) {
                bestw = wt;
            }
            EnQueue(Q, wt, i, n, bestw, E, bestE, bestx, true);
        }
        //检查右儿子节点
        if (Ew + r > bestw) {
            EnQueue(Q, Ew, i, n, bestw, E, bestE, bestx, false);
        }
        Q.Delete(E);  //取下一扩展节点
        if (!E)       //同层节点尾部
        {
            if (Q.IsEmpty()) {
                break;
            }
            Q.Add(0);     //同层节点尾部标识
            Q.Delete(E);  //取下一扩展节点
            i++;          //进入下一层
            r -= w[i];    //剩余集装箱重量
        }
        Ew = E->weight;  //新扩展节点所对应的载重量
    }
    //**************end**************/

    //构造当前最优解
    //**************begin************/
    for (int j = n - 1; j > 0; --j) {
        bestx[j] = bestE->LChild;
        bestE = bestE->parent;
    }

    //**************end**************/
    return bestw;
}
