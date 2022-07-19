
# 题目大意

给定 n 个整数，求他们的最大连续子序列和以及序列起始位置

# 解题思路

- 首先，这题也能采用分治法求解，采用分治法时间复杂度为 O(nlog)
- 若采用动态规划解法，时间复杂度只需要 O(n)
- 定义状态：dp\[i\] 表示以 a\[i\] 为结尾的最大连续序列的和（因而每个状态的终点必为当前的 i，只需记录序列起点）
- 则可得状态转移方程：dp\[i\] = max(dp\[i-1\]+a\[i\], a\[i\])，由于要记录序列的起始位置，求解时不能直接使用 max 函数，要分别判断，因为不同分支导致的序列区间不一样
- 若是 dp[i-1]+a[i] >= a[i]，即 dp[i-1] >= 0，表示前面的有贡献，那么当前以 a[i] 为结尾的要加上前面的
- 因此 dp[i] = dp[i-1]+a[i]，得到区间为 [head[i-1],i]，记录起始位置为 head[i-1]
- 还要注意题目要求和相等时，在前面的序列优先输出，因此上面一定要大于等于0，
- 前面即使为 0，加上 a[i] 结果仍然为 a[i]，但起点在前面的满足条件，因此要取等于 0
- 若是 dp[i-1] < 0，则前面的无贡献，会导致以 a[i] 为结尾的序列和更小，直接抛弃，只需要留下 a[i]
- 即 dp[i] = a[i]，得到的区间为 [i,i]，记录起始位置为 i
- 最后遍历整个 dp 数据，找到最大值，相等时优先取前面的（更靠前的序列）

# 题解

```C++
#include <bits/stdc++.h>
using namespace std;


const int maxn = 100005;
int arr[maxn]; // 输入数据，由于只需要遍历一遍，可以省略
int dp[0];
int head[maxn]; // 记录序列起点

/**
 * HDU 1003 最大连续和，动态规划解法
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    // 0. 假设输入数据为 arr[i], n 个数 [0, n)
    // 0. 由于只遍历一遍，该数组被省略了，只用一个变量即可
    // 1. 定义状态：dp[i] 表示以 a[i] 为结尾的最大连续序列的和（因而每个状态的终点必为当前的 i，只需记录序列起点）
    // 2. 则可得状态转移方程：dp[i] = max(dp[i-1]+a[i], a[i]);
    // 由于要记录序列的起始位置，求解时不能直接使用 max 函数，要分别判断，因为不同分支导致的序列区间不一样
    // 3. 若是 dp[i-1]+a[i] >= a[i]，即 dp[i-1] >= 0，表示前面的有贡献，那么当前以 a[i] 为结尾的要加上前面的
    // 因此 dp[i] = dp[i-1]+a[i]，得到区间为 [head[i-1],i]，记录起始位置为 head[i-1]
    // 还要注意题目要求和相等时，在前面的序列优先输出，因此上面一定要大于等于0，
    // 前面即使为 0，加上 a[i] 结果仍然为 a[i]，但起点在前面的满足条件，因此要取等于 0
    // 4. 若是 dp[i-1] < 0，则前面的无贡献，会导致以 a[i] 为结尾的序列和更小，直接抛弃，只需要留下 a[i]
    // 即 dp[i] = a[i]，得到的区间为 [i,i]，记录起始位置为 i
    // 最后遍历整个 dp 数据，找到最大值，相等时优先取前面的（更靠前的序列）


    int t, n;
    int kase = 0;

    scanf("%d", &t);
    while (t--){
        scanf("%d", &n);
        // 输入数据
        for (int i = 0; i < n; ++i) {
            scanf("%d", arr+i);
        }
        // 初始状态
        head[0] = 0;
        dp[0] = arr[0];

        // dp[i] 表示以 a[i] 为结尾的最大连续子序列和
        for (int i = 1; i < n; ++i) {
            if (dp[i-1] >= 0){
                // 前面的序列有贡献，接着前面的序列累加
                dp[i] = dp[i-1] + arr[i];
                head[i] = head[i-1];
            } else {
                // 前面的序列没有贡献，直接抛弃，设置起点为i
                dp[i] = arr[i];
                head[i] = i;
            }
        }

        // 遍历所有a[i]，即可求得最优解
        int maxSum = dp[0];
        int start = 0;
        int end = 0;

        for (int i = 1; i < n; ++i) {
            if (dp[i] > maxSum){
                maxSum = dp[i];
                start = head[i]; // 取出记录的起点
                end = i; // 状态定义为以a[i] 为结尾
            }
        }

        if (kase){
            printf("\n");
        }

        printf("Case %d:\n", ++kase);
        printf("%d %d %d\n", maxSum, start+1, end+1);

    }



    return 0;
}
```

# 疑问

- 刚开始为了省空间，只用一个变量输入数据而开没开数组，结果超时，我佛了，难道是因为把 scanf 和计算融合在一起导致输入很慢的原因？
- 下面是 TLE 的代码：
```C++
#include <bits/stdc++.h>
using namespace std;


const int maxn = 100005;
//int arr[maxn]; // 输入数据，由于只需要遍历一遍，可以省略
int dp[0];
int head[maxn]; // 记录序列起点

/**
 * HDU 1003 最大连续和，动态规划解法
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    // 0. 假设输入数据为 arr[i], n 个数 [0, n)
    // 0. 由于只遍历一遍，该数组被省略了，只用一个变量即可
    // 1. 定义状态：dp[i] 表示以 a[i] 为结尾的最大连续序列的和（因而每个状态的终点必为当前的 i，只需记录序列起点）
    // 2. 则可得状态转移方程：dp[i] = max(dp[i-1]+a[i], a[i]);
    // 由于要记录序列的起始位置，求解时不能直接使用 max 函数，要分别判断，因为不同分支导致的序列区间不一样
    // 3. 若是 dp[i-1]+a[i] >= a[i]，即 dp[i-1] >= 0，表示前面的有贡献，那么当前以 a[i] 为结尾的要加上前面的
    // 因此 dp[i] = dp[i-1]+a[i]，得到区间为 [head[i-1],i]，记录起始位置为 head[i-1]
    // 还要注意题目要求和相等时，在前面的序列优先输出，因此上面一定要大于等于0，
    // 前面即使为 0，加上 a[i] 结果仍然为 a[i]，但起点在前面的满足条件，因此要取等于 0
    // 4. 若是 dp[i-1] < 0，则前面的无贡献，会导致以 a[i] 为结尾的序列和更小，直接抛弃，只需要留下 a[i]
    // 即 dp[i] = a[i]，得到的区间为 [i,i]，记录起始位置为 i
    // 最后遍历整个 dp 数据，找到最大值，相等时优先取前面的（更靠前的序列）


    int t, n, arr;
    int kase = 0;

    scanf("%d", &t);
    while (t--){
        scanf("%d", &n);

        // 基础状态
        scanf("%d", &arr);
        head[0] = 0;
        dp[0] = arr;

        // dp[i] 表示以 a[i] 为结尾的最大连续子序列和
        for (int i = 1; i < n; ++i) {
            scanf("%d", &arr);

            if (dp[i-1] >= 0){
                // 前面的序列有贡献，接着前面的序列累加
                dp[i] = dp[i-1] + arr;
                head[i] = head[i-1];
            } else {
                // 前面的序列没有贡献，直接抛弃，设置起点为i
                dp[i] = arr;
                head[i] = i;
            }
        }

        // 遍历所有a[i]，即可求得最优解
        int maxSum = dp[0];
        int start = 0;
        int end = 0;

        for (int i = 1; i < n; ++i) {
            if (dp[i] > maxSum){
                maxSum = dp[i];
                start = head[i]; // 取出记录的起点
                end = i; // 状态定义为以a[i] 为结尾
            }
        }

        if (kase){
            printf("\n");
        }

        printf("Case %d:\n", ++kase);
        printf("%d %d %d\n", maxSum, start+1, end+1);

    }

    return 0;
}
```