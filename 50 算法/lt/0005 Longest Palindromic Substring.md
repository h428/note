


# 1. 题目大意

给定一个字符串，求最长的回文子串，若存在多个可返回任意一个


# 2. 解题思路

- 定义 `dp[i][j]` 表示子串 `[i, j]` 的回文长度，若不是回文串则赋值为 -1，最开始初始化为 0
- 则状态转移方程为：
    - 若 `a[i] == a[j] and dp[i+1][j-1] >= 0` 则 `dp[i, j] = dp[i+i, j-1] + 2`
    - 否则说明 `dp[i][j]` 不是回文串，则 `dp[i][j] = -1`，避免后续的 `dp[i-1][j+1]` 的搜索
- 初始化：
    - `dp[i][i]` 显然是回文，初始化为 1
    - 对于 i, j 相邻的情况, `dp[i][j]` 的子状态会变为负串，例如 `dp[2][3] -> dp[3][2]`，但实际上此时 `dp[i][j]` 的子状态结果应该为 0，因此为了方便，需要将这些位置初始化为 0，主要是 `dp[2][1], dp[3][2], dp[4][3] ...`，而其他左下角的负串如 `dp[3][1]` 不会用到



# 3. 题解

- C++ 版本
```C++

const int maxn = 1005;
int dp[maxn][maxn];

class Solution {

public:
    string longestPalindrome(string s) {

        // dp[i][j] 表示 s 对应位置的子串的回文长度，不是回文则为 -1  
        // dp[i][j] = dp[i+1][j-1] + 2 if (s[i] == s[j] && dp[i+1][j-1] >= 0)
        // 初始化为 0，对角线为 -1，然后从 dp[i][i] 开始往两端扩散搜索
        // 注意要从后往前搜索，即要先求出所有 dp[3][j]，才能进一步求 dp[2][j]，否则子状态会未求解就使用

        memset(dp, 0, sizeof dp);

        for (int i = 0; i < s.length(); ++i) {
            dp[i][i] = 1;
        }

        int maxSize = 1, startIdx = 0, endIdx = 1;

        for (int i = s.length() - 2; i >= 0; --i) {
            for (int j = i + 1; j < s.length(); ++j) {
                if ((dp[i+1][j-1] >= 0) && (s[i] == s[j])) {
                    dp[i][j] = dp[i+1][j-1] + 2;

                    // 记录 maxSize，记忆对应子串
                    if ((j - i + 1) > maxSize) {
                        maxSize = j - i + 1;
                        startIdx = i;
                        endIdx = j + 1;
                    }
                } else {
                    dp[i][j] = -1;
                }
            }
        }

        return s.substr(startIdx, maxSize);

    }
};
```


- Java 版本

```java
class Solution {
    public String longestPalindrome(String s) {
        
        if (s.length() == 0) {
            return "";
        }
        
        // dp[i][j] 表示子串 [i, j] 的回文长度，若不是回文则 -1，刚开始全部初始化为 0
        // 注意 dp[3][2] 表示空串，为了迭代方便，其应该为 0， dp[2][3] = dp[3][2] + 2 = 0 + 2，因为 dp[2][3] 的前一个子状态串是空串
        int[][] dp = new int[s.length()][s.length()];

        int maxSize = 1;
        int beginIdx = 0, endIdx = 1;
        
        for (int i = 0; i < s.length(); ++i) {
            dp[i][i] = 1;
        }
        
        for (int i = s.length() - 2; i >= 0; --i) {
            for (int j = i + 1; j < s.length(); ++j) {
                if ((dp[i+1][j-1] >= 0) && (s.charAt(i) == s.charAt(j))) {
                    dp[i][j] = dp[i+1][j-1] + 2;
                    
                    if (j - i + 1 > maxSize) {
                        maxSize = j-i+1;
                        beginIdx = i;
                        endIdx = j+1;
                    }
                    
                } else {
                    dp[i][j] = -1;
                }
            }
        }
        
        
        return s.substring(beginIdx, endIdx);
        
    }
}
```