
# 题目大意

- 给定一块油田，可以往 8 个方向搜索，得到一块油田，求其连通油田的数目
- 上下左右斜对角相邻的@属于同一个连通块

# 解题思路

- DFS 或 BFS 皆可，题解采用 DFS
- 遍历整个地图，每遇到一个 '@' ，则进行 DFS 或 BFS 搜索周围方向，并将经过的位置改不可访问的 '*'
- 一次 BFS 或 DFS 可以得到一个连通的油田

# 题解

```C++
#include <bits/stdc++.h>
#include <cstring>
using namespace std;

const int maxn = 105;
int m, n;
char mapp[maxn][maxn];
bool visit[maxn][maxn];

/**
 * 从位置 (x, y) 开始往 8 个方向递归遍历，以处理一个 block 油田
 * @param x
 * @param y
 */
void dfs(int x, int y){
    // 当前节点不可访问，递归出口
    if (x < 0 || x >= m || y < 0 || y >= n || visit[x][y] || mapp[x][y] == '*'){
        return ;
    }

    // 否则当前节点是油田，可以访问，替换为 *，并标记为已访问
    mapp[x][y] = '*';
    visit[x][y] = true;
    // 递归处理八个方向
    dfs(x-1, y);
    dfs(x+1, y);
    dfs(x, y-1);
    dfs(x, y+1);
    dfs(x-1, y-1);
    dfs(x-1, y+1);
    dfs(x+1, y-1);
    dfs(x+1, y+1);
}

/**
 * HDU 1241 入门 DFS
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    while (scanf("%d%d", &m, &n) == 2 && m){
        for (int i = 0; i < m; ++i) {
            scanf("%s", mapp[i]);
        }
        int block = 0; // 统计油田块
        memset(visit, 0, sizeof(visit));
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (mapp[i][j] == '@'){
                    ++block;
                    dfs(i, j);
                }
            }
        }
        printf("%d\n", block);
    }
    return 0;
}
```