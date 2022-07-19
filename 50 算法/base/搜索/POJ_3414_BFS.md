
# 题目大意

有水壶 1 和 水壶 2，容量分别为 A、B，每次可以执行下述三种操作：
- FILL(i) ：装满水壶 i，i = 1 或 2
- DROP(i) ：倒掉水壶 i 中的水，另其剩 0
- POUR(i, j) ：把水壶 i 的水倒到水壶 j 中，可能 i 全部倒进 j 中 或 j 装满后 i 中留下一部分

# 解题思路

- 这是一个 6 个方向的 BFS 搜索题，对每个状态，都有后继的 6 种可能操作，以得到 6 种新的操作状态
- 模拟这 6 个操作，得到 6 个新的状态，若这些状态还未出现过，则步数+1，记录操作类型，将节点入队 
- 若是已经出现过，则跳过这个节点
- 循环上述过程直至找到目标状态或者队列为空
- 题目要求打印操作序列，注意操作序列不能使用数组存储，而是利用结构体和自定义状态队列，每个节点要状态维护当前状态的前一个状态在队列中的下标以及由前一个状态到当前状态的操作类型，因此需要先对前面的操作类型编号，按顺序分别编号为 0,1,2,3,4,5 即可

# 题解

```C++
#include <cstdio>
#include <vector>
#include <map>
#include <queue>
using namespace std;

struct Node {
    int a; // 当前状态下壶 a 的水量
    int b; // 当前状态下壶 b 的水量
    int step; // 当前状态下已经执行的操作数量
    int prev; // 当前状态的前一个状态的下标
    int op; // 由前一个状态到当前状态所执行的操作类型，最后可以反序遍历回去，再将序列反过来即可得到操作序列
};

map< pair<int, int>, bool> hasAppear; // 某个状态是否已经出现过
bool findSolution;

/**
 * 归打印出由状态 (0, 0) 即 que[0] 到当前状态的结果
 * @param que 节点队列
 * @param idx 当前要打印的节点在队列中的下标
 */
void printRes(Node* que, int idx){
    // 递归出口，当前节点下标是0，直接返回
    if (idx == 0){
        return;
    }

    // 取出当前节点
    Node node = que[idx];
    // 递归打印前面的节点
    printRes(que, node.prev);

    // 打印当前节点
    if (node.op == 0){
        printf("FILL(1)\n");
    } else if (node.op == 1) {
        printf("FILL(2)\n");
    } else if (node.op == 2) {
        printf("DROP(1)\n");
    } else if (node.op == 3) {
        printf("DROP(2)\n");
    } else if (node.op == 4) {
        printf("POUR(1,2)\n");
    } else if (node.op == 5) {
        printf("POUR(2,1)\n");
    }
}

/**
 * 根据给定的容量 A，B 以及目标状态 C 执行 BFS 搜索
 * @param A 壶A 容量
 * @param B 壶B 容量
 * @param C 目标状态 C：任意一个壶出现 C
 */
void bfs(int A, int B, int C){
    // 定义相关变量
    Node que[10005]; // 搜索队列
    int head = 0, tail = 0; // 队列的首尾下标，初始状态为空
    // 初始化
    hasAppear.clear();
    findSolution = false;
    // 构造初始状态，入队，并标记已经出现过
    Node originNode; // 默认状态就是 (0, 0)， 操作序列为空
    originNode.a = 0;
    originNode.b = 0;
    originNode.step = 0;
    originNode.prev = -1; // (0, 0) 无前一个状态
    originNode.op = -1; // 无前一个状态，自然也无从前一个状态到当前状态的操作类型
    que[tail++] = originNode; // 入队
    hasAppear[make_pair(0, 0)] = true; // 标记(0,0)已经出现

    // 队列不为空，进入循环
    while(head < tail){
        // 记录当前节点的所在的队列下标，后续搜索方向的前一个状态即为当前状态
        int prevState = head;
        // 取出队首元素，并弹出元素
        Node node = que[head++];

        // 查看当前节点是否已经是目标状态，是则根据记录的操作序列打印结果
        if (node.a == C || node.b == C){
            // 直接打印步数
            printf("%d\n", node.step);
            // 递归打印操作序列
            printRes(que, head-1);
            findSolution = true;
            break;
        }

        // 分别搜索 6 个方向，每个方向若可行，步数都要+1
        node.step++;

        // 操作 0 ：FILL(1) - 装满壶 A
        Node newNode = node;
        newNode.a = A;

        // 判断新的状态是否已经出现过，未出现则在节点中记录前一个状态，记录操作，步数+1，并将节点入队
        if (hasAppear.find(make_pair(newNode.a, newNode.b)) == hasAppear.end()){
            newNode.prev = prevState; // 记录前一个状态的下标
            newNode.op = 0; // 记录到信状态的操作类型
            que[tail++] = newNode; // 新节点入队
            hasAppear[make_pair(newNode.a, newNode.b)] = true; // 标记新节点已经出现
        }

        // 操作 1 ：FILL(2) - 装满壶 B
        newNode = node;
        newNode.b = B;

        // 判断新的状态是否已经出现过，未出现则在节点中记录前一个状态，记录操作，步数+1，并将节点入队
        if (hasAppear.find(make_pair(newNode.a, newNode.b)) == hasAppear.end()){
            newNode.prev = prevState; // 记录前一个状态的下标
            newNode.op = 1; // 记录到信状态的操作类型
            que[tail++] = newNode; // 新节点入队
            hasAppear[make_pair(newNode.a, newNode.b)] = true; // 标记新节点已经出现
        }

        // 操作 2 ：DROP(1) - 倒掉壶 A
        newNode = node;
        newNode.a = 0;

        // 判断新的状态是否已经出现过，未出现则在节点中记录前一个状态，记录操作，步数+1，并将节点入队
        if (hasAppear.find(make_pair(newNode.a, newNode.b)) == hasAppear.end()){
            newNode.prev = prevState; // 记录前一个状态的下标
            newNode.op = 2; // 记录到信状态的操作类型
            que[tail++] = newNode; // 新节点入队
            hasAppear[make_pair(newNode.a, newNode.b)] = true; // 标记新节点已经出现
        }

        // 操作 3 ：DROP(2) - 倒掉壶 B
        newNode = node;
        newNode.b = 0;

        // 判断新的状态是否已经出现过，未出现则在节点中记录前一个状态，记录操作，步数+1，并将节点入队
        if (hasAppear.find(make_pair(newNode.a, newNode.b)) == hasAppear.end()){
            newNode.prev = prevState; // 记录前一个状态的下标
            newNode.op = 3; // 记录到信状态的操作类型
            que[tail++] = newNode; // 新节点入队
            hasAppear[make_pair(newNode.a, newNode.b)] = true; // 标记新节点已经出现
        }

        // 操作 4 ：POUR(1, 2) - 从 A 倒去 B，有两种情况
        newNode = node;

        if (newNode.a + newNode.b > B){
            // 若是两者之和大于B的容量，则A中剩下a+b-B，而B全满
            newNode.b = B;
            // 注意这里不能用newNode的，因为newNode的b已经改变，当然也可以不用node，提前计算好原来的a+b即可
            newNode.a = node.a + node.b - B;
        }else{
            // 否则两者之和小于等于B的容量，A中不剩，B=a+b
            newNode.a = 0;
            newNode.b = node.a + node.b;
        }

        // 判断新的状态是否已经出现过，未出现则在节点中记录前一个状态，记录操作，步数+1，并将节点入队
        if (hasAppear.find(make_pair(newNode.a, newNode.b)) == hasAppear.end()){
            newNode.prev = prevState; // 记录前一个状态的下标
            newNode.op = 4; // 记录到信状态的操作类型
            que[tail++] = newNode; // 新节点入队
            hasAppear[make_pair(newNode.a, newNode.b)] = true; // 标记新节点已经出现
        }

        // 操作 5 ：POUR(2, 1) - 从 B 倒去 A，有两种情况
        newNode = node;

        if (newNode.a + newNode.b > A){
            // 若是两者之和大于A的容量，则B中剩下a+b-A，而A全满
            newNode.a = A;
            newNode.b = node.a + node.b - A;
        } else{
            // 否则两者之和小于等于A的容量，B中不剩，A=a+b
            newNode.b = 0;
            newNode.a = node.a + node.b;
        }

        // 判断新的状态是否已经出现过，未出现则在节点中记录前一个状态，记录操作，步数+1，并将节点入队
        if (hasAppear.find(make_pair(newNode.a, newNode.b)) == hasAppear.end()){
            newNode.prev = prevState; // 记录前一个状态的下标
            newNode.op = 5; // 记录到信状态的操作类型
            que[tail++] = newNode; // 新节点入队
            hasAppear[make_pair(newNode.a, newNode.b)] = true; // 标记新节点已经出现
        }
    }

    // 若队列为空还未找到解，则无解
    if (!findSolution){
        printf("impossible\n");
    }
}

/**
 * POJ 3414 BFS
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    // 首先这是一个6个方向的BFS搜索问题，任意一个状态的后续搜索状态分别是：
    // 0. FILL(1), 1. FILL(2)
    // 2. DROP(1), 3. DROP(2)
    // 4. POUR(1, 2), 5. POUR(2, 1)
    // 由于最终输出需要打印操作记录，因此需要为这些操作编号，并将操作记录存储起来
    // 1. 首先，初始状态为 (0, 0)，当前已经执行的操作为空，将节点入队
    // 2. 取出队首元素，分别执行6个方向的搜索，得到6个新的状态
    // 3. 判断这些状态是否已经出现，若还未出现则把这个操作加入序列，然后将该该状态和操作组成的节点入队
    // 4. 若状态已出现过，则忽略该搜索方向
    // 5. 循环上述直至找到目标状态或队列为空

    int A, B, C;

    while(scanf("%d%d%d", &A, &B, &C) == 3){
        bfs(A, B, C);
    }

    return 0;
}
```