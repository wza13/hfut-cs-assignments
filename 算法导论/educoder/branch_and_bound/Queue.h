#include <iostream>
using namespace std;

template <class T>
class Queue {
   public:
    Queue(int MaxQueueSize = 500);
    ~Queue() { delete[] queue; }
    bool IsEmpty() const { return front == rear; }
    bool IsFull() { return (((rear + 1) % MaxSize == front) ? 1 : 0); }
    T Top() const;
    T Last() const;
    Queue<T>& Add(const T& x);
    Queue<T>& AddLeft(const T& x);
    Queue<T>& Delete(T& x);
    void Output(ostream& out) const;
    int Length() { return (rear - front); }

   private:
    int front;
    int rear;
    int MaxSize;
    T* queue;
};

template <class T>
Queue<T>::Queue(int MaxQueueSize) {
    MaxSize = MaxQueueSize + 1;
    queue = new T[MaxSize];
    front = rear = 0;
}

template <class T>
T Queue<T>::Top() const {
    if (IsEmpty()) {
        cout << "queue:no element,no!" << endl;
        return 0;
    } else
        return queue[(front + 1) % MaxSize];
}

template <class T>
T Queue<T>::Last() const {
    if (IsEmpty()) {
        cout << "queue:no element" << endl;
        return 0;
    } else
        return queue[rear];
}

template <class T>
Queue<T>& Queue<T>::Add(const T& x) {
    if (IsFull())
        cout << "queue:no memory" << endl;
    else {
        rear = (rear + 1) % MaxSize;
        queue[rear] = x;
    }
    return *this;
}

template <class T>
Queue<T>& Queue<T>::AddLeft(const T& x) {
    if (IsFull())
        cout << "queue:no memory" << endl;
    else {
        front = (front + MaxSize - 1) % MaxSize;
        queue[(front + 1) % MaxSize] = x;
    }
    return *this;
}

template <class T>
Queue<T>& Queue<T>::Delete(T& x) {
    if (IsEmpty())
        cout << "queue:no element(delete)" << endl;
    else {
        front = (front + 1) % MaxSize;
        x = queue[front];
    }
    return *this;
}

template <class T>
void Queue<T>::Output(ostream& out) const {
    for (int i = rear % MaxSize; i >= (front + 1) % MaxSize; i--)
        out << queue[i];
}

template <class T>
ostream& operator<<(ostream& out, const Queue<T>& x) {
    x.Output(out);
    return out;
}
