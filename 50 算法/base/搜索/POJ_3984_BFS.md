
# 题目大意

给定一个 5×5 迷宫，含有 0 和 1，1 表示墙不可走，0 表示可以走的路，求左上角节点 (0, 0) 到右下角节点 (4, 4) 的最短路线

# 解题思路

- 由于需要打印序列，那么在状态元素弹出队列后不能删除元素，因此需要使用一个数组模拟状态队列
- 且为了记忆序列，每个节点存储其前导节点在队列中的下标
- 首先，用初始位置 (0, 0) 和其下标 -1 构造节点，然后初始节点入队
- 取出队首节点，判断当前节点是否已经为目标解，是则结束搜索
- 否则对当前节点执行 4 个方向的 BFS，得到 4 个新的位置，判断这些位置是否可访问且未访问
- 是则直接入队，否则跳过该元素
- 循环上述步骤直至找到解，题目已经保证必定有解，故一定能找到解

# 题解

```C++
#include <cstdio>
#include <map>
using namespace std;

const int maxn = 8; // 地图规模
int mapp[maxn][maxn];

struct Node{
    int x, y;
    int prev;

    Node(){};

    Node(int rX, int rY, int rPrev): x(rX), y(rY), prev(rPrev){}

};

map< pair<int, int>, bool > visit; // 标记某个位置是否访问过
Node que[105]; // 状态队列

int dx[] = {-1, 1, 0, 0};
int dy[] = {0, 0, 1, -1};


/**
 * 判断某个点是否可以访问
 * @param x
 * @param y
 * @return
 */
bool canVisit(int x, int y){

    // 没有越界 & 没有访问过 & 是可以走的路 0
    if (x >= 0 && x < 5 && y >= 0 && y < 5 && (visit.find(make_pair(x, y)) == visit.end()) && mapp[x][y] == 0){
        return true;
    }
    return false;
}

/**
 * 递归打印序列结果
 * @param idx
 */
void prinRes(int idx){
    if (idx == -1){
        return;
    }
    Node node = que[idx];
    // 递归打印之前的节点
    prinRes(node.prev);
    // 打印当前节点
    printf("(%d, %d)\n", node.x, node.y);
}

/**
 * POJ 3984 BFS
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    // 由于要打印序列，因此出队后不能删除节点，可以使用一个数组模拟状态队列
    // 使用一个状态队列，每个节点要维护前导节点在队列中的下标，以用于序列输出
    // 左上角初始化： (0, 0, -1) (0, 0)是坐标，-1 是前导节点
    // 初始化节点入状态队列，并标记位置 (0, 0) 已访问
    // 取出队首元素，四个方向 BFS，注意判定越界问题和是否已访问过
    // 若新的位置未越界且未访问且不是墙，记录新的节点的前导节点下标，以及标记新节点已访问，然后入队
    // 否则，直接跳过该位置
    // 循环上述直至找到结果（因为题目保证一定有解）

    for (int i = 0; i < 5; ++i) {
        for (int j = 0; j < 5; ++j) {
            scanf("%d", mapp[i]+j);
        }
    }

    // 数据初始化
    int head = 0, tail = 0; //队列为空
    bool findSolution = 0;
    visit.clear();

    // 左上角
    Node startNode(0, 0, -1);
    que[tail++] = startNode;

    while (head < tail){
        // 记录取出的节点的下标，后面要用到
        int prevIdx = head;
        // 队列不为空，取出队首节点
        Node node = que[head++];

        // 注意按题意，一定能找到一条路径
        if (node.x == 4 && node.y == 4){
            // 递归打印结果
            prinRes(head-1); // -1 是因为执行了 head++ 操作
            break;
        }

        // 4 个方向进行 BFS
        for (int i = 0; i < 4; ++i) {
            if (canVisit(node.x + dx[i], node.y + dy[i])){
                Node newNode(node.x + dx[i], node.y + dy[i], prevIdx); // BFS 的新节点
                que[tail++] = newNode; // 入队
                visit[make_pair(node.x + dx[i], node.y + dy[i])] = true;
            }
        }
    }

    return 0;
}
```