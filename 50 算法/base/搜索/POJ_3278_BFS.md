
# 题目大意

给定两个数 n、k，农夫在 n，牛在 k，农夫每次可以执行下述两种操作：

- 移动： n+1 或 n-1
- 瞬移： n*2

牛不动，问农夫至少多少步才能抓到牛


# 解题思路

- BFS
- 跟经典的BFS问题，从起点开始，分别进行两个操作，并步数+1，分别入队
- 循环直至队列为空

# 题解

```C++
#include <cstdio>
#include <queue>
#include <cstring>
using namespace std;

const int maxn = 100005;
bool visit[maxn];


/**
 * 单维三方向 bfs 给定位置 n k，求解最少步数
 * @param n
 * @param k
 */
void bfs(int n, int k){

    // 1. 起点入队
    // 2. 取出队首元素，判定是否到达k，未到达则变量两种操作，步数+1，依次入队，注意要标记已访问避免死循环

    // 0. 数据初始化
    queue< pair<int, int> > q;
    memset(visit, 0, sizeof(visit));

    // 1. 起点入队并标记已经访问
    pair<int, int> start = make_pair(n, 0);
    q.push(start);
    visit[n] = 1;

    while (!q.empty()){
        // 取出队首元素并将元素弹出
        pair<int, int> p = q.front();
        q.pop();

        // 若已搜索到 k ，打印结果，跳出循环
        if (p.first == k){
            printf("%d\n", p.second);
            break;
        } else{
            // 否则，针对改点做 bfs 进行三个方向搜索，注意步数要+1

            if (p.first-1 >= 0 && !visit[p.first-1]){
                // 前移方向，注意进行越界判断
                q.push(make_pair(p.first-1, p.second+1));
                visit[p.first-1] = 1;
            }

            if(p.first+1 < maxn && !visit[p.first+1]){
                // 后移方向
                q.push(make_pair(p.first+1, p.second+1));
                visit[p.first+1] = 1;
            }

            if (p.first * 2 < maxn && !visit[p.first * 2]){
                // 瞬移方向
                q.push(make_pair(p.first*2, p.second+1));
                visit[p.first*2] = 1;
            }
        }
    }
}

/**
 * POJ 3278 三个方向的BFS搜索
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    int n, k;
    while (scanf("%d%d", &n, &k) == 2){
        bfs(n, k);
    }

    return 0;
}
```