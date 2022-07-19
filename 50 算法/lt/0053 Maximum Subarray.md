
- 给定整数序列，求该序列的最大连续和

- 题解

```java
class Solution {
    public int maxSubArray(int[] nums) {
        
        // 定义状态 dp[i] 表示以 nums[i] 为结尾的序列的和的最大值，这样结果就是所有 dp[i] 的最大值
        // 状态转移方程： dp[i] = max(nums[i], dp[i-1] + nums[i])
        
        // dp 存储累加到当前第 i 个位置的最大和，默认结果为第一个数
        int dp = 0, ans = nums[0];
        
        
        for (int i = 0; i < nums.length; ++i) {
            dp = Math.max(nums[i], dp + nums[i]);
            ans = Math.max(ans, dp);
        }
        
        return ans;
    }
}
```