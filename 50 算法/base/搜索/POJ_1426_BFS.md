
# 题目大意

给定整数n，找到一个目标数，该目标数只含有0和1，且是n的倍数

# 解题思路

- bfs：从1开始，两个搜索方向 x\*10+0，x\*10+1，但是该方法可能导致数值越界
- 越界问题可以采用同余模定理求解，如k%n的值利用k/10%n的值求解
- 每个问题派生出两个搜索方向，可看成一棵二叉树，详细参看代码注释

# 题解

```C++
#include <cstdio>
#include <cstring>
using namespace std;

const int maxn = 550000;

int mod[maxn]; // 存各个节点的模
int res[205]; // 存最终数的反序列

/**
 * POJ 1426 BFS 及 搜索改进
 * @return
 */
int main()
{
#ifdef _LOCAL
    freopen("E:/in.txt", "r", stdin);
#endif // _LOCAL


    // 原本的两个搜索方向： x*10+0, x*10+1，由于直接bfs结果数可能因为太大而导致越界，因此需要优化
    // 首先，明确目标数只有0和1
    // 利用同余模定理可以避免越界问题来求解到这个数k，但注意我们此时并不能明确k的值，只是能确定这个k所在位置且能整除n
    // 如：数组0不存，1,2,3,4,5,6,7,8,9,10,11... 分别存储 1,10,11,100,101,110,111,1000,1001,1010,1011,....模n的余数
    // 注意10相当于100和101的父节点，101的模利用10的模求得，即子节点的模要利用父节点的模
    // 则利用同余模定理，必定能不越界确定这个数k在数组中的下标（此时还不知道k，因为已经被同余模了）
    // 实际上由于序列只含有0和1，我们可以根据k求解得这个原来的目标数（类似二叉树逆过程）
    // 比如上例1011的模存储在下标11中，此时我们只知道下标11不知道1011，但实际上可以根据11求得1011
    // 11%2=1,
    // 11/2=5, 5%2=1
    // 5/2=2, 2%2=0
    // 2/2=1, 1%2=1
    // 1/2=0, 结束，反过来就是1011，上述过程类似二叉树求解父节点过程
    // 会产生这种过程，是因为原序列是按奇偶奇偶排列的，恰好和存储位置的奇偶性保持一致，可用下标模2取出


    int n;

    while (scanf("%d", &n) == 1 && n){
        mod[1] = 1;
        int idx = 1;
        do{
            ++idx;
            // 同余模定理：子节点的模要利用父节点的模求解，idx分别表示+0或+1
            // 1110%10 --> (111%10 + 0)%10, 111是1110的父节点，mod[idx/2]相当于111%10的值
            mod[idx] = (mod[idx/2]*10 + idx%2) % n;
        }while (mod[idx] != 0); // 搜索直至idx处模为零，此时表示找到k，具体值位置，但其位置为idx

        // 之后要用下标还原出元素，这是利用下标奇偶性和目标序列奇偶性的一致性进行还原的，但要注意翻转序列
        int len = 0;

        // 还有父节点，则一直搜索
        while (idx){
            res[len++] = idx % 2;
            idx /= 2;
        }

        // 反向输出序列
        for (int i = len-1; i >= 0; --i) {
            printf("%d", res[i]);
        }
        printf("\n");
    }
    return 0;
}
```