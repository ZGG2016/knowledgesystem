# 链表中倒数第k个节点

## 1、题目

输入一个链表，输出该链表中倒数第k个节点。为了符合大多数人的习惯，本题从1开始计数，即链表的尾节点是倒数第1个节点。例如，一个链表有6个节点，从头节点开始，它们的值依次是1、2、3、4、5、6。这个链表的倒数第3个节点是值为4的节点。

示例：

	给定一个链表: 1->2->3->4->5, 和 k = 2.

	返回链表 4->5.

## 2、思路

方法1：因为要取链表的倒数第x个节点，所以考虑使用栈，再计数，弹出。【和链表倒着取数，考虑栈】

方法2：定义两个指针，一前一后，前面的指针先走到k的位置。(前后两指针始终差k个距离)当前指针走到头时，后指针也就到目标位置了。

## 3、解法

**方法1：栈**

```java
/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode(int x) { val = x; }
 * }
 */
class Solution {
    public ListNode getKthFromEnd(ListNode head, int k) {
        if(head==null) return null;

        ListNode tmp = head;
        int count = 0;
        Stack<ListNode> stack = new Stack<>();
        while(tmp!=null){
        	stack.push(tmp);
            tmp = tmp.next; 
            count++;        
        }
        if(count<k){
            return null;
        }

        ListNode rlt = null;
        for(int i=1;i<=k;i++){
            rlt = stack.pop();
        }
        return rlt;

    }
}
```

**方法2：前后双指针**

```java
/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode(int x) { val = x; }
 * }
 */
class Solution {
    public ListNode getKthFromEnd(ListNode head, int k) {
        if(head==null) return null;

        ListNode i = head;  //前指针
        ListNode j = head;  //后指针

        // 1.让前指针先走到k的位置，那么前后两指针就相差k个距离。
        for(int n=1;n<k;n++){  
            if(i.next!=null){
                i = i.next;
            }else{         
                return null;   //还没到k，就null了，说明超过链表范围了
            }
        }

        // 2.然后让两个指针同时走，当前指针到头了，后指针也就到k的位置了。
        while(i.next!=null){
            i = i.next;
            j = j.next;
        }

        return j;

    }
}
```