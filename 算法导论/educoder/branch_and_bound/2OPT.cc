//装载问题 优先队列式分支限界法求解
#include "MaxHeap.h"

int N;

class bbnode;

template <class Type>
class HeapNode {
   public:
    operator Type() const { return uweight; }
    bbnode *ptr;   //指向活节点在子集树中相应节点的指针
    Type uweight;  //活节点优先级(上界)
    int level;     //活节点在子集树中所处的层序号
};

class bbnode {
    template <class Type>
    friend void AddLiveNode(MaxHeap<HeapNode<Type>> &H, bbnode *E, Type wt,
                            bool ch, int lev);
    template <class Type>
    friend Type MaxLoading(Type w[], Type c, int n, int bestx[]);
    friend class AdjacencyGraph;

   private:
    bbnode *parent;  //指向父节点的指针
    bool LChild;     //左儿子节点标识
};

template <class Type>
void AddLiveNode(MaxHeap<HeapNode<Type>> &H, bbnode *E, Type wt, bool ch,
                 int lev);

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

//将活节点加入到表示活节点优先队列的最大堆H中
template <class Type>
void AddLiveNode(MaxHeap<HeapNode<Type>> &H, bbnode *E, Type wt, bool ch,
                 int lev) {
    bbnode *b = new bbnode;
    b->parent = E;
    b->LChild = ch;
    HeapNode<Type> N;

    N.uweight = wt;
    N.level = lev;
    N.ptr = b;
    H.Insert(N);
}

//优先队列式分支限界法，返回最优载重量，bestx返回最优解
template <class Type>
Type MaxLoading(Type w[], Type c, int n, int bestx[]) {
    //定义最大的容量为1000
    MaxHeap<HeapNode<Type>> H(1000);

    //定义剩余容量数组
    Type *r = new Type[n + 1];
    r[n] = 0;

    //**************begin************/
    for (int j = n - 1; j > 0; j--) {
        r[j] = r[j + 1] + w[j + 1];
    }

    //**************end**************/

    //初始化
    int i = 1;      //当前扩展节点所处的层
    bbnode *E = 0;  //当前扩展节点
    Type Ew = 0;    //扩展节点所相应的载重量

    //搜索子集空间树
    //**************begin************/
    while (i != n + 1)  //非叶子节点
    {
        //检查当前扩展节点的儿子节点
        if (Ew + w[i] <= c) {
            AddLiveNode(H, E, Ew + w[i] + r[i], true, i + 1);
        }
        //右儿子节点
        AddLiveNode(H, E, Ew + r[i], false, i + 1);
        //取下一扩展节点
        HeapNode<Type> N;
        H.DeleteMax(N);  //非空
        i = N.level;
        E = N.ptr;
        Ew = N.uweight - r[i - 1];
    }

    //**************end**************/

    //构造当前最优解
    //**************begin************/
    for (int j = n; j > 0; j--) {
        bestx[j] = E->LChild;
        E = E->parent;
    }

    //**************end**************/

    return Ew;
}
