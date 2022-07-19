
# 题目大意

- 给一 n*n 棋盘，在其棋盘上放置 k 个棋子，需保证每行每列最多只有一颗棋子，也可不放置。
- \# 表示棋盘区域，可以放置，. 表示空白区域，不可放置

# 解决思路

- 入门搜索
- 利用 DFS，从第 0 开始往下遍历，放置棋子，之后往下递归处理

# 题解

```C++
#include <cstdio>
#include <cstring>

const int maxn = 10; // 棋盘最大大小
int cnt; // 统计搜索成功的次数
char mapp[maxn][maxn];
bool col_visit[maxn]; // 标记某一列是否放置了棋子
int n, k; // 棋盘大小，放置棋子数


/**
 * 从第 row 行开始往下放置剩余的 leftChess 个棋子
 * @param row
 * @param leftChess
 */
void dfs(int row, int leftChess){
    if (leftChess <= 0){
        // 搜索成功的递归边界，所有棋子已经放置
        ++cnt;
        return;
    }

    if (row >= n || (n-row < leftChess) ){
        // 搜索边界及剪纸
        return;
    }

    // 1. 首先是该行要放置棋子的情况
    // 1.1 遍历列放置记录，遇到未放置过的列，则表示本行可以在这一列放置，此时，本行这一列放置棋子，然后递归处理下一行
    // 1.2 注意本行有多列可以访问，由于要搜索所有情况，可以某一列可以放置但不放置，因此递归搜索完需要回溯，处理另一种情况
    // 2. 最后，由于棋子数小于棋盘大小，因此可以本行不放置棋子，直接递归处理下一行


    for (int i = 0; i < n; ++i) {
        if (!col_visit[i] && mapp[row][i] == '#'){
            // 该列目前没有放置棋子且是棋盘区域
            col_visit[i] = 1;  // 在这一列放置棋子
            dfs(row+1, leftChess-1);  // 递归在下一行处理剩余棋子
            col_visit[i] = 0; // 回溯，这一列不放置棋子，继续遍历后续的列
        }
    }

    // 跳过当前行的放置，直接递归处理下一行
    dfs(row+1, leftChess);
}

/**
 * POJ 1321 入门 DFS
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    while((scanf("%d%d", &n, &k) != EOF) && !(n == -1 && k == -1)){
        // 输入数据
        for (int i = 0; i < n; ++i) {
            scanf("%s", mapp[i]);
        }
        // 初始化
        memset(col_visit, 0, sizeof(col_visit));
        cnt = 0;
        // 算法
        dfs(0, k);
        // 打印结果
        printf("%d\n", cnt);
    }
    return 0;
}
```