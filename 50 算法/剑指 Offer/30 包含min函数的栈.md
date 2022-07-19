

# 1. 题意

- 定义栈的数据结构，请在该类型中实现一个能够得到栈的最小元素的 min 函数在该栈中，调用 min、push 及 pop 的时间复杂度都是 O(1)

# 2. 旧 min 入栈

- 遇到新 min 时，将上旧的 min 也入栈，这样 pop 出 min 时，可以再 pop 出旧的 min 以更新 min 值

```java
class MinStack {

    int[] buf = new int[40001];
    int size = 0;
    int min = Integer.MAX_VALUE;

    /** initialize your data structure here. */
    public MinStack() {

    }

    public void push(int x) {
        if (x <= min) {
            buf[size++] = min;
            min = x;
        }
        buf[size++] = x;
    }

    public void pop() {
        if (buf[size - 1] == min) {
            min = buf[size-2];
            size -= 2;
        } else {
            --size;
        }
    }

    public int top() {
        return buf[size - 1];
    }

    public int min() {
        return min;
    }
}
```