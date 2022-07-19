
# 题目大意

 给出一三维空间的地牢,要求求出由字符'S'到字符'E'的最短路径，移动方向可以是上，下，左，右，前，后，六个方向，每移动一次就耗费一分钟，要求输出最快的走出时间。不同L层的地图，相同RC坐标处是相连通的。(.可走，#为墙)

# 解决思路

- 从起点开始，分别往6个方向遍历
- 每次步数+1，并入队
- 循环直至队列为空，若还未找到则没有出口
- 若在中间找到终点，则提前结束循环，找到出口

# 题解

```C++
#include <cstdio>
#include <cstring>
#include <queue>
using namespace std;

int c, m, n;
const int maxn = 35;
char mapp[maxn][maxn][maxn];
bool visit[maxn][maxn][maxn];
int start_x, start_y, start_z;

struct node {
    int x, y, z, step;

    node(int rX, int rY, int rZ, int rStep){
        x = rX;
        y = rY;
        z = rZ;
        step = rStep;
    }
};

// 遍历方向
int next_x[] = {1, -1, 0, 0, 0, 0};
int next_y[] = {0, 0, 1, -1, 0, 0};
int next_z[] = {0, 0, 0, 0, 1, -1};

/**
 * 判断某个节点是否可以访问，可以则可以入队
 * @param n
 * @return
 */
bool judge(node pt){
    if (pt.x < 0 || pt.x >= m
        || pt.y < 0 || pt.y >= n
        || pt.z < 0 || pt.z >= c
        || mapp[pt.z][pt.x][pt.y] == '#'
        || visit[pt.z][pt.x][pt.y]){
        return false;
    }
    return true;
}

void bfs(int start_z, int start_x, int start_y){

    // 1. 起点入队
    // 2. 从队列中取出元素，往六个方向遍历，若未走过且可以走，则把对应节点入队列，对应步数+1，并标记已访问
    // 3. 重复上述操作直至队列为空

    // 数据初始化
    queue<node> q;
    node start(start_x, start_y, start_z, 0);
    bool found = false;
    memset(visit, 0, sizeof(visit));

    // 起点入队并标记已经访问
    q.push(start);
    visit[start_z][start_x][start_y] = 1;

    while (!q.empty()){
        node tmp = q.front();  // 取出队列首节点
        q.pop();  // 弹出元素

        // 若是终点，打印步数，跳出循环
        if (mapp[tmp.z][tmp.x][tmp.y] == 'E'){
            printf("Escaped in %d minute(s).\n", tmp.step);
            found = true;
            break;
        }else{
            // 当前位置不是终点，步数+1，继续处理后续元素入队，并标记已访问
            tmp.step++;
            for (int i = 0; i < 6; ++i) {
                // 6个方向的不同节点
                node tmp2 = tmp;
                tmp2.x += next_x[i];
                tmp2.y += next_y[i];
                tmp2.z += next_z[i];
                // 判断新节点是否可访问，可访问则入队
                if (judge(tmp2)) {
                    visit[tmp2.z][tmp2.x][tmp2.y] = 1;
                    q.push(tmp2);

                }
            }
        }
    }
    //若未找到元素，则说明无出口
    if (!found){
        printf("Trapped!\n");
    }
}

/**
 * POJ 2251 三维 BFS
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    while(scanf("%d%d%d", &c, &m, &n)==3 && (m+n+c)){
        for (int i = 0; i < c; ++i) {
            for (int j = 0; j < m; ++j) {
                scanf("%s", mapp[i][j]);
                for (int k = 0; k < n; ++k) {
                    // 查找起始位置
                    if (mapp[i][j][k] == 'S'){
                        start_z = i;
                        start_x = j;
                        start_y = k;
                    }
                }
            }
        }
        bfs(start_z, start_x, start_y);
    }
    return 0;
}
```

