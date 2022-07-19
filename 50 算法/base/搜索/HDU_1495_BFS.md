
# 题目大意

给定可乐容积 S 和两个容积为 A, B 的容器，且保证 S = A + B，每次可以执行 S、A、B 之间的互倒，如果能平分则输出最少步数，不能平分则输出NO

# 解题思路

- 首先，奇数必定不能平分，偶数进行 BFS
- 此外，s 和 a 确定后，b 就唯一确定了，因此可以只用二维数组表示某个状态是否已经出现
- 首先，初始状态 (S, 0, 0) 及 step = 0，入队
- 取出队首元素，判断是否目标状态，实则结束搜索，否则按六个方向进行搜索，得到新的状态
- 若新的状态未出现过，则入队，并标记已出现
- 若新状态已经出现过，则跳过
- 循环直至队列为空或找到目标状态
- 目标状态为：S 和大的一个杯子的中的内容相等，另一个小杯子为 0 ，即分别占 S / 2
- 特殊处理：保证杯子 A 大于杯子 B，若输入的 A 小于 B，执行互换，这样判定目标状态时直接比较 S A 是否分别为 S/2 即可 

# 题解

```C++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 105;
bool visit[maxn][maxn]; // 二维就能记录三维的状态

struct Node{
    int s, a, b;
    int step;
    Node(int rS, int rA, int rB, int rStep):s(rS),a(rA),b(rB), step(rStep){}
};


/**
 * 把 a 中的可乐倒入 b 中， B 为容量 b 的容量
 * @param a
 * @param b
 * @param B
 */
void pour(int& a, int& b, int B){
    if (a + b <= B){
        // 若 a + b 小于等于 B 的容量，则将 a 全部倒入 b，a中不剩
        b = a + b;
        a = 0;
    } else {
        // 否则，B-b 倒入 b 中且 b 会被倒满，然后a中留下剩余内容
        a = a - (B - b); //
        b = B; // b 被倒满
    }
}

/**
 * HDU 1495 BFS
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    // 状态由 (s, a, b) 组成，节点还包括了步数
    // 初始节点 (S, 0, 0) 入队，step = 0,
    // 取出队首元素，BFS 6 个搜索方向

    int S,A,B;

    while ((scanf("%d%d%d", &S, &A, &B) == 3) && (S+A+B)) {
        if (S % 2){
            // 奇数必定不行
            printf("NO\n");
            continue;
        }
        // 初始化
        memset(visit, 0, sizeof(visit));
        queue<Node> q;
        bool findSolution = 0;
        if (A < B){
            // 保证 A > B
            swap(A, B);
        }
        // 初始节点
        Node startNode(S, 0, 0, 0);
        q.push(startNode);
        visit[S][0] = true;

        while (!q.empty()){
            Node node = q.front();
            q.pop();

            // 若当前节点已经是目标节点
            if ((node.s == node.a) && node.b == 0){
                // 找到目标状态
                findSolution = 1;
                printf("%d\n", node.step);
                break;
            }
            // 6 个方向的 BFS，步数先统一+1
            node.step++;
            // S -> A，
            Node newNode = node;
            pour(newNode.s, newNode.a, A);
            // 若新的状态未出现过，则步数+1(已经统一执行过)，标记出现过，然后入队
            if (!visit[newNode.s][newNode.a]){
                q.push(newNode); // 入队
                visit[newNode.s][newNode.a] = 1; // 标记已访问
            }
            // S -> B
            newNode = node;
            pour(newNode.s, newNode.b, B);
            // 若新的状态未出现过，则步数+1(已经统一执行过)，标记出现过，然后入队
            if (!visit[newNode.s][newNode.a]){
                q.push(newNode); // 入队
                visit[newNode.s][newNode.a] = 1; // 标记已访问
            }
            // A -> S
            newNode = node;
            pour(newNode.a, newNode.s, S);
            // 若新的状态未出现过，则步数+1(已经统一执行过)，标记出现过，然后入队
            if (!visit[newNode.s][newNode.a]){
                q.push(newNode); // 入队
                visit[newNode.s][newNode.a] = 1; // 标记已访问
            }
            // A -> B
            newNode = node;
            pour(newNode.a, newNode.b, B);
            // 若新的状态未出现过，则步数+1(已经统一执行过)，标记出现过，然后入队
            if (!visit[newNode.s][newNode.a]){
                q.push(newNode); // 入队
                visit[newNode.s][newNode.a] = 1; // 标记已访问
            }
            // B -> A
            newNode = node;
            pour(newNode.b, newNode.a, A);
            // 若新的状态未出现过，则步数+1(已经统一执行过)，标记出现过，然后入队
            if (!visit[newNode.s][newNode.a]){
                q.push(newNode); // 入队
                visit[newNode.s][newNode.a] = 1; // 标记已访问
            }
            // B -> S
            newNode = node;
            pour(newNode.b, newNode.s, S);
            // 若新的状态未出现过，则步数+1(已经统一执行过)，标记出现过，然后入队
            if (!visit[newNode.s][newNode.a]){
                q.push(newNode); // 入队
                visit[newNode.s][newNode.a] = 1; // 标记已访问
            }
        }

        if (!findSolution){
            printf("NO\n");
        }
    }
}
```