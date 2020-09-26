# 包含min函数的栈

## 1、题目

定义栈的数据结构，请在该类型中实现一个能够得到栈的最小元素的 min 函数在该栈中，调用 min、push 及 pop 的时间复杂度都是 O(1)。

示例:

	MinStack minStack = new MinStack();
	minStack.push(-2);
	minStack.push(0);
	minStack.push(-3);
	minStack.min();   --> 返回 -3.
	minStack.pop();
	minStack.top();      --> 返回 0.
	minStack.min();   --> 返回 -2.
 

提示：

	各函数的调用总次数不超过 20000 次

## 2、思路

方法1：定义两个栈，一个栈a存push进的数据，一个栈b存随时更新的最小值。当入栈a时，判断栈b的peek()值是不是还是最小值，不是的话，则入栈b。所以在取最小值时，直接从栈b取。

方法2：先定义一个最小值入栈，当数据入栈时，和当前栈中的最小值比较，始终把当前最小值放栈顶。

## 3、解法

```java
class MinStack {

    Stack<Integer> stack1 = null;
    Stack<Integer> stack2 = null;

    /** initialize your data structure here. */
    public MinStack() {
        stack1 = new Stack<Integer>();
        stack2 = new Stack<Integer>();  //最小值栈
    }
    
    public void push(int x) {
        stack1.push(x);
        //B.peek() >= x：当stack1和stack2中的最小值弹出后，如果stack1还有这个最小值，
        //那么，再取最小值的时候，就不是这个值了。
        if(stack2.isEmpty() || stack2.peek()>=x){
        	stack2.push();
        }
    }
    
    public void pop() {
    	//始终保持stack2的栈顶元素是最小值
        if(stack1.pop().equals(stack2.peek())){
        	stack2.pop();
        }
    }
    
    public int top() {
        return stack1.peek();
    }
    
    public int min() {
        return stack2.peek();
    }
}

/**
 * Your MinStack object will be instantiated and called as such:
 * MinStack obj = new MinStack();
 * obj.push(x);
 * obj.pop();
 * int param_3 = obj.top();
 * int param_4 = obj.min();
 */
```
[方法2：](https://leetcode-cn.com/problems/bao-han-minhan-shu-de-zhan-lcof/solution/zui-xiao-zhan-yong-stack-by-xyx1273930793/)

```java
class MinStack {
    private Stack<Integer> stack = new Stack<>();
    private int min = Integer.MAX_VALUE;
    /** initialize your data structure here. */
    public MinStack() {
        
    }
    
    public void push(int x) {
        //先压先前最小值
        //再压一个当前最小值，保证最小值一直在最顶端
        if(x <= min){
            stack.push(min);
            min = x;
        }
        stack.push(x);
    }
    
    public void pop() {
        if(stack.pop() == min){
            min = stack.pop();
        }
    }
    
    public int top() {
        return stack.peek();
    }
    
    public int min() {
        return min;
    }
}

/**
 * Your MinStack object will be instantiated and called as such:
 * MinStack obj = new MinStack();
 * obj.push(x);
 * obj.pop();
 * int param_3 = obj.top();
 * int param_4 = obj.min();
 */
```
