
# 题目大意

给定两个长度为 n 的序列 S1, S2 以及一个长为 2n 的目标序列，模拟洗牌的 shuffle 操作：S2 第一个元素先放在下面，然后是 S1 第一个元素，依次交替，最终得到新的长为 2n 的序列 S12 = (S2_1, S1_1, S2_2, S1_2, ..., S2_n, S1_n)，然后重新将 S12 拆成 S1, S2，前 n 个作为 S1，后 n 个作为 S2，问给定的 S1, S2 需要至少经过几次才能得到目标序列

# 解题思路

- BFS 搜索，字符串存储
- 首先，直接将 S1, S2 连接起来，标记该字符串已出现，并插入队列
- 取出队列首元素，拆成 S1, S2，模拟 shuffle 操作，得到新的字符串
- 判断新的字符串是否已经出现过，未出现则步数+1，并将节点加入队列中
- 循环上述步骤直至找到目标数（有解）或队列为空（无解）

# 题解

```C++
#include <cstring>
#include <iostream>
#include <queue>
#include <map>
#include <cstdio>
using namespace std;

/**
 * 清空队列，实际上是替换为一个新创建的空队列，STL中的队列无清空功能
 * @param q
 */
void clearQueue(queue<pair<string, int> >& q) {
    queue<pair<string, int> > empty;
    swap(empty, q);
}

/**
 * POJ 3087 BFS
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL

    // 1. 以字符串形式读取两段数据S1,S2，并连接成S12，步数为0，然后将节点加入队列
    // 2. 取出队首元素，对字符串模拟shuffle操作，得到新的字符串，判断该串是否已经出现过（使用map维护某串是否已经出现过）
    // 3. 未出现，则将步数+1，节点入队，若已出现则放弃该串
    // 4. 循环上述情况直至队列为空或已经遇到目标串

    int t,n;
    string s1, s2, targetStr;
    queue<pair<string, int> > q;
    map<string, bool> visit;
    int kase = 0;
    bool findSolution;

    scanf("%d", &t);
    while (t--){
        // 输入
        scanf("%d", &n);
        cin >> s1 >> s2 >> targetStr;
        // 数据初始化
        clearQueue(q);
        visit.clear();
        findSolution = 0;
        // 连接字符串s1,s2并加入队首，并标记串已出现
        string origin = s1 + s2;
        q.push(make_pair(origin, 0));
        visit[origin] = true;

        while (!q.empty()){
            // 取出并弹出队首元素
            pair<string, int> node = q.front();
            q.pop();

            if (node.first == targetStr){
                // 找到目标串，标记已找到，之后打印结果并结束循环
                findSolution = 1;
                printf("%d %d\n", ++kase, node.second);
                break;
            }

            // 模拟shuffle操作，注意前n个字符为s1，后n个字符为s2，且s2的第一个字符
            string newString = node.first; // 拷贝主要是为了确定长度一致
            for (int i = 0; i < n; ++i) {
                newString[2*i] = node.first[n+i]; // 先复制S2的字符
                newString[2*i+1] = node.first[i]; // 再复制S1的字符
            }
            // 判定字符串是否出现过，未出现则入队，并标记已出现过
            if (visit.find(newString) == visit.end()){
                // 根据key查找为找到，表示字符串没出现过，可以入队，注意步数+1
                q.push(make_pair(newString, node.second+1));
                // 标记串已出现
                visit[origin] = true;
            }
        }
        // 若不是提前break，则表示队列为空时结束，没有找到结果，打印-1
        if (!findSolution){
            printf("%d %d\n", ++kase, -1);
        }
    }
    return 0;
}
```