
# 题目大意

给定 m, n 以及 m 行 n 列的地图，地图包含 Y、M 两个人起始位置，多个肯德基 @，不可通过的点 \#，可通过的点 \.，人可走的方向为上下左右，两个人想在一个肯德基进行见面，使得到这个肯德基之和距离最少，求这个最少距离（保证有解）

# 解题思路

- 对 Y 进行 BFS，求得 Y 到各个可访问的点的距离
- 对 M 进行 BFS，求得 M 到各个可访问的点的距离
- 遍历地图，对所有肯德基，计算 Y、M 两个人到当前肯德基的距离值和，并维护一个最小距离即得到最优解

# 题解

```C++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 205;
int m, n; // m 行 n 列
char mapp[maxn][maxn]; // 输入地图
bool visit[maxn][maxn]; // BFS 时的访问状态
int Y_dist[maxn][maxn]; // Y到各个可访问点的距离，全部memset为1，会是一个很大的数
int M_dist[maxn][maxn]; // M到各个可访问点的距离，全部memset为1，会是一个很大的数
int Y_startX, Y_startY, M_startX, M_startY; // 两个人的起始位置
int dx[] = {-1, 1, 0, 0};
int dy[] = {0, 0, -1, 1};

struct Node{
    int x, y;
    int step;
    Node(int rX, int rY, int rStep):x(rX), y(rY), step(rStep){}

};

/**
 * 判断某个节点能不能访问
 * @param x
 * @param y
 * @return
 */
bool canVisit(int x, int y){
    // 没有越界且没访问过，且不是 #
    if (x >= 0 && x < m && y >= 0 && y < n && !visit[x][y] && mapp[x][y] != '#') {
        return true;
    }
    return false;
}


/**
 * 从位置 (x, y) 开始执行 BFS
 * @param x
 * @param y
 */
void BFS(int x, int y, int dist[][maxn]){

    // 公共初始化
    queue<Node> q;
    memset(visit, 0, sizeof(visit));
    int newStep;
    // 初始节点
    Node originNode(x, y, 0);
    q.push(originNode); // 入队
    visit[x][y] = true; // 标记访问
    dist[x][y] = 0; // 记录距离


    while (!q.empty()){
        Node node = q.front();
        q.pop();
        newStep = node.step + 1; // 新的

        // 执行 4 个方向的 BFS，先步数+1，可用于赋值
        for (int i = 0; i < 4; ++i) {
            if (canVisit(node.x+dx[i], node.y+dy[i])){
                q.push(Node(node.x+dx[i], node.y+dy[i], newStep)); // 入队
                visit[node.x+dx[i]][node.y+dy[i]] = true; // 标记
                dist[node.x+dx[i]][node.y+dy[i]] = newStep; // 记录距离
            }
        }
    }
}

/**
 * HDU 2612 BFS
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    // 首先，分别对 Y,B 进行 BFS，记录下 Y 到其他可走位置的距离，不可达点默认为 -1
    // 然后，遍历地图，对每个肯德基，统计 Y、M 到该肯德基的距离之和，找出最小的即为最优解

    while (scanf("%d%d", &m, &n) == 2){
        for (int i = 0; i < m; ++i) {
            scanf("%s", mapp[i]);
            // 记录 Y 和 M 两个人的起始位置
            for (int j = 0; j < n; ++j) {
                if (mapp[i][j] == 'Y'){
                    Y_startX = i;
                    Y_startY = j;
                } else if (mapp[i][j] == 'M'){
                    M_startX = i;
                    M_startY = j;
                }
            }
        }
        // Y 的初始化
        memset(Y_dist, 1, sizeof(Y_dist));
        BFS(Y_startX, Y_startY, Y_dist);
        // M 的初始化
        memset(M_dist, 1, sizeof(M_dist));
        BFS(M_startX, M_startY, M_dist);

        // 遍历地图，统计到各个最小肯德基的距离
        int min_dist = INT_MAX;

        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (mapp[i][j] == '@'){
                    if (Y_dist[i][j] + M_dist[i][j] < min_dist){
                        min_dist = Y_dist[i][j] + M_dist[i][j];
                    }
                }
            }
        }
        printf("%d\n", min_dist*11);
    }
    return 0;
}
```