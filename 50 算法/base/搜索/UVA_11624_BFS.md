
# 题目大意

给定 m 行 n 列的地图，地图包括：一个人的起点位置 J，多个着火点起始位置 F，人和火都可以走的位置 \.，人和火都不能走的墙 \#，火每次往上下左右 4 个方向扩展，人每次课选择上下左右 4 个方向的一个，若能不遇到火走到地图的边界，则表示可以走出迷宫，求最少走出迷宫的步数

# 解题思路

- 显然是一个 BFS，但每次在 BFS 时，地图的状态是会改变的（体现在火的扩散），因此这是一个带条件的 BFS 问题
- 涉及队列：
    - 主队列 mainQue 维护人的位置
    - preAddBurn 队列维护前个时间新增加的着火点，用于当前时间的着火点扩散
    - prePos 队列维护当前时间状态下取出的人的可能位置，用于搜索所有下个时间的位置
- 首先，地图为初始状态time=0，人的初始位置入队列，初始着火点添加到 preAddBurn（相当于 time=-1 时添加的着火点）
- 从 mainQue 取出当前 time 下的所有可能的人的位置节点，判断是否到达边界，是则找到结果，结束搜索
- 否则，把当前 time 下的这些位置全都入 prePos 队列，用于下一个 time 的人的搜索
- 搜索之前，着火点先执行扩散，这时取出上个 time 新增的着火点，执行扩散，清除原有着火点，并将当前新的着火点入 preAddBurn 让下个 time 使用
- 在着火点扩散之后，模拟当前 time 下的人的 BFS，并将 BFS 入主队列
- 迭代上述操作直至主队列为空或者找到解，注意每次迭代 time 要增加 1

# 题解

```C++
#include <stdio.h>
#include <map>
#include <queue>
using namespace std;

struct Node{
    int x, y; // 人的位置
    int step; // 当前步数

    Node(int rX, int rY, int rStep){
        x = rX;
        y = rY;
        step = rStep;
    }

};

// 全局变量
const int maxn = 1005;
char mapp[maxn][maxn]; // 存放地图
map< pair<int, int>, bool > visit; // 标记人是否走过
int m, n;


/**
* 判断某个位置是否能成为新的着火点
* 若没有越界，且原来不是着火点，且不是墙，则可以是新的着火点
* @param x
* @param y
* @return
*/
bool canBurn(int x, int y){
    if (x >= 0 && x < m && y >= 0 && y < n && mapp[x][y] != '#' && mapp[x][y] != 'F'){
        return true;
    }
    return false;
}

/**
* 人能访问这个节点
* 没有越界 && 是 . && 没访问过
* @param x
* @param y
* @return
*/
bool canVisit(int x, int y){
    if (x >= 0 && x < m && y >= 0 && y < n && mapp[x][y] == '.' && (visit.find(make_pair(x, y)) == visit.end())){
        return true;
    }
    return false;
}

int dx[] = { -1, 1, 0, 0 };
int dy[] = { 0, 0, -1, 1 };

/**
 * UVA 11624 条件 BFS ： 迷宫状态一直在变
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:\\in.txt", "r", stdin);
#endif // _LOCAL

    // 0. 数据、变量相关：preBurn 队列维护上个 time 新增的着火点
    // 1. 人的 (初始位置, step=0) 入主队列，标记访问，时间 time=0，初始迷宫
    // 2. 取出所有主队列中节点步数与当前时间相等的节点，判断这些节点是否在边缘，是则找到结果，结束
    // 3. 否则，记录下这些节点，这些切点将用于BFS（还是用一个队列，将其称为 prevPos 队列吧，这些节点是下面的新状态的前置节点）
    // 4. 使用上个time新增的着火点执行火的扩散，得到新的着火点和迷宫状态，存储新的着火点用于下个time
    // 5. 在当前迷宫状态下，用前面记录的prevPos中的节点执行BFS，得到新的节点，
    //    若这些新位置人未走过，则步数+1，标记已访问，然后入主队列
    // 6. 迭代上述步骤，每次迭代 time+1，直至主列队为空
    int t;
    int startX, startY;

    scanf("%d", &t);
    while (t--){
        // 变量和初始化
        queue<Node> prevAddBurn; // 维护前一个时间step新增的着火点，此时step相当于时间
        queue<Node> mainQue; // 主队列
        visit.clear();
        int time = 0;
        bool findSolution = 0;
        // 输入数据
        scanf("%d%d", &m, &n);
        for (int i = 0; i < m; ++i) {
            scanf("%s", mapp[i]);
            for (int j = 0; j < n; ++j) {
                if (mapp[i][j] == 'F'){
                    // time=0时增加的着火点
                    prevAddBurn.push(Node(i, j, 0));
                }
                else if (mapp[i][j] == 'J'){
                    startX = i;
                    startY = j;
                }
            }
        }
        // 初始节点入主队列，step=0，标记已访问
        mainQue.push(Node(startX, startY, 0));
        visit[make_pair(startX, startY)] = true;

        while (!mainQue.empty()){
            // 每次进来都是一个时间状态，可能同时pop出多个该时间对应的节点，时间和迷宫状态是一一对应的
            queue<Node> prevPos;

            // 取出所有与当前时间相等的节点，这些节点都和当前的迷宫状态相对应
            while (!mainQue.empty() && mainQue.front().step == time){
                Node node = mainQue.front();
                mainQue.pop();

                // 判断节点是否已在边缘，已在的话结束搜索
                if (node.x == 0 || node.x == m-1 || node.y == 0 || node.y == n-1){
                    // 已在边缘，结束搜索，打上标记
                    findSolution = 1;
                    printf("%d\n", node.step+1);
                    break;
                }
                else{
                    // 否则把这些点保存到 prevPos 队列中，用于下面的 BFS
                    prevPos.push(node);
                }
            }

            if (findSolution == 1){
                break;
            }

            // 在当前time下，根据维护的新着火点执行扩散，得到新的迷宫状态（相当于到了新的time），以下相当于time+1的状态了
            while (!prevAddBurn.empty() && prevAddBurn.front().step <= time){
                // 取出节点
                Node node = prevAddBurn.front();
                prevAddBurn.pop();
                // 4个方向执行扩散
                for (int i = 0; i < 4; ++i) {
                    if (canBurn(node.x + dx[i], node.y + dy[i])){
                        mapp[node.x + dx[i]][node.y + dy[i]] = 'F'; // 扩散为着火点
                        // 着火点加入到 prevAddBurn队列，注意时间为 time + 1，下次迭代使用
                        prevAddBurn.push(Node(node.x + dx[i], node.y + dy[i], time + 1));
                    }
                }
            }
            ++time; // 时间+1

            // 取出前面保存的time-1时间下的位置，BFS到新的time的位置，并判断是否可访问，可则加入主队列
            while (!prevPos.empty()){
                // 取出元素
                Node node = prevPos.front();
                prevPos.pop();
                // 四个方向 BFS
                for (int i = 0; i < 4; ++i) {
                    // 若可访问且未访问过，则入主队列，然后标记已访问
                    if (canVisit(node.x + dx[i], node.y + dy[i])){
                        mainQue.push(Node(node.x + dx[i], node.y + dy[i], node.step + 1));
                        visit[make_pair(node.x + dx[i], node.y + dy[i])] = true;
                    }
                }
            }
            // 继续主队列迭代
        }
        if (!findSolution){
            printf("IMPOSSIBLE\n");
        }
    }
    return 0;
}
```