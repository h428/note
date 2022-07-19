
# 题目大意

给定两个素数 m,n，二者都是 4 位数，每次只能变化一个位置上的数，要找到一条从 m 到 n 的最短素数路径（中间值必须也是素数），求最短操作步数。

# 解题思路

- 很明显的 bfs 搜索
- 首先构造素数表 1000-9999 ，标记素数情况（使用素数线性筛）
- 对每个数，除了第一个位置，每个位置有9个搜索方向，故共有35个搜索方向，但要是素数才可入队
- 若是素数，入队，并标记该数已经访问，并记录步数
- 循环上述条件直至队列为空或找到目标数

# 题解

```C++
#include <cstdio>
#include <cstring>
#include <queue>
using namespace std;

const int maxn = 10005;

bool isPrime_all[maxn];
int primeArr_all[maxn];
bool visit[maxn];

/**
 * 素数线性筛
 * @param isPrime 素数标记数组
 * @param primeArr 素数序列，2,3,5,7,11,13,...
 * @param maxn 素数范围
 * @return 返回最终求得的素数个数
 */
int getPrime(bool* isPrime, int* primeArr, const int maxn){

    // 全部标记为素数
    memset(isPrime, 1, maxn);
    // 记录素数个数
    int primeNum = 0;

    for (int m = 2; m < maxn; ++m) {
        // 当前数是否素数已经在之前使用更小的数筛得，由于需要求最小素因子，故还需单独将素数记录下来
        if (isPrime[m]){
            // m 是素数，将 m 记录到素数序列中
            primeArr[primeNum++] = m;
        }
        // 利用当前数 m 筛去所有的满足条件的合数 km
        for (int i = 0; (i < primeNum) && (primeArr[i] * m < maxn); ++i) {
            // k 从第一个素数 2 开始按序列遍历素数序列，筛去所有的满足条件的 km
            int k = primeArr[i];
            isPrime[k * m] = 0;
            if (m % k == 0){
                // m 能整除该素数，说明找到最小素因子，跳出循环
                break;
            }
        }
    }
    return primeNum;
}


/**
 * bfs 搜索，从 m 开始，每次变换一个位置的数，广搜直至搜索到 n
 * @param m
 * @param n
 * @return 步数，若是 -1 表示 Impossible
 */
int bfs(int m, int n){

    // 变量定义
    queue< pair<int, int> > q;
    int tmpNum;

    // 数据初始化
    memset(visit, 0, sizeof visit);

    // 首节点入队，并标记已访问
    q.push(make_pair(m, 0));
    visit[m] = 1;

    while (!q.empty()){

        pair<int, int> node = q.front();
        q.pop();

        // 若已经找到目标数 n，直接返回步数结果
        if (node.first == n){
            return node.second;
        }

        // 取出各个位置上的数，然后分别搜索 35 个方向
        // 第一个位置除了 0 和 f1 的 8 个方向，其他位置除了 fi 的 9 个方向
        int f4 = node.first % 10;
        int f3 = node.first / 10 % 10;
        int f2 = node.first / 100 % 10;
        int f1 = node.first / 1000 % 10;

        // 变换第一位，第一位数从1开始，否则只剩三位数
        for (int i = 1; i < 10; ++i) {
            if (i == f1){
                continue; // 要变化的数和当前数一直，不变
            }
            tmpNum = i*1000+f2*100+f3*10+f4;

            if (!visit[tmpNum] && isPrime_all[tmpNum]){
                // 若该数还没访问过，且是素数则入队，步数+1
                q.push(make_pair(tmpNum, node.second+1));
            }
            visit[tmpNum] = 1; // 标记已访问过

        }

        // 变换第二位，从0开始
        for (int i = 0; i < 10; ++i) {
            if (i == f2){
                continue; // 要变化的数和当前数一直，不变
            }
            tmpNum = f1*1000+i*100+f3*10+f4;

            if (!visit[tmpNum] && isPrime_all[tmpNum]){
                // 是素数则入队，步数+1
                q.push(make_pair(tmpNum, node.second+1));
            }
            visit[tmpNum] = 1; // 标记已访问过
        }

        // 变换第三位，从0开始
        for (int i = 0; i < 10; ++i) {
            if (i == f3){
                continue; // 要变化的数和当前数一直，不变
            }
            tmpNum = f1*1000+f2*100+i*10+f4;

            if (!visit[tmpNum] && isPrime_all[tmpNum]){
                // 是素数则入队，步数+1
                q.push(make_pair(tmpNum, node.second+1));
            }
            visit[tmpNum] = 1; // 标记已访问过
        }

        // 变换第四位，从0开始
        for (int i = 0; i < 10; ++i) {
            if (i == f4){
                continue; // 要变化的数和当前数一直，不变
            }
            tmpNum = f1*1000+f2*100+f3*10+i;

            if (!visit[tmpNum] && isPrime_all[tmpNum]){
                // 是素数则入队，步数+1
                q.push(make_pair(tmpNum, node.second+1));
            }
            visit[tmpNum] = 1; // 标记已访问过
        }
    }
    return -1;
}


/**
 * POJ 3126 bfs 搜索，素数线性筛
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    // 1. 首先构造素数表 1000-9999
    // 2. 对每个数，除了第一个位置，每个位置有9个搜索方向，故共有35个搜索方向，但要是素数才可入队
    // 3. 若是素数，入队，并标记该数已经访问，并记录步数
    // 4. 循环上述条件直至队列为空或找到目标数

    // 构造素数表
    getPrime(isPrime_all, primeArr_all, maxn);
    int t, m, n;
    scanf("%d", &t);
    while (t--){
        scanf("%d%d", &m, &n);

        int step = bfs(m, n);

        if (step == -1){
            printf("Impossible\n");
        } else{
            printf("%d\n", step);
        }
    }
    return 0;
}
```