# 从上到下打印二叉树 II

## 1、题目

从上到下按层打印二叉树，同一层结点从左至右输出。每一层输出一行。

例如:

给定二叉树: [3,9,20,null,null,15,7],

        3
       / \
      9  20
        /  \
       15   7

返回其层次遍历结果：

    [
      [3],
      [9,20],
      [15,7]
    ]

## 2、解法

用一个队列来保存将要打印的结点，左右孩子依次入队列。（宽度遍历）

定义两个变量分别记录当前层和下一层的结点数。

```java

import java.util.ArrayList;
import java.util.Queue;
import java.util.LinkedList;

/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     int val;
 *     TreeNode left;
 *     TreeNode right;
 *     TreeNode(int x) { val = x; }
 * }
 */
class Solution {
    public List<List<Integer>> levelOrder(TreeNode root)  {
    	if(root == null) return new ArrayList<>();

        // 有返回值，先定义返回值
        List<List<Integer>> rlt = new ArrayList<>();
        // 内层ArrayList：装每层的结点
        List<Integer> layer = new ArrayList<Integer>();
        Queue<TreeNode> queue = new LinkedList<>();
        queue.offer(root);
        TreeNode p = null;

        int curLayerNum = 1;  // 当前层的结点个数
        int nextLayerNum = 0;  // 记录下一层的结点个数

        while(!queue.isEmpty()){
            p = queue.poll();
            curLayerNum--;     // 弹出后，当前层结点数减一
            layer.add(p.val);

            // 将其左右子孩子装进入，并记录下层的结点数(方便判断当前层的结点是不是都处理了)。
            if(p.left != null){
                queue.offer(p.left);
                nextLayerNum++;
            }
            if(p.right != null){
                queue.offer(p.right);
                nextLayerNum++;
            }

            // 当前层的结点都处理了
            if(curLayerNum == 0){
                // public ArrayList(Collection<? extends E> c) {}
                rlt.add(new ArrayList<Integer>(layer));
                layer.clear();
                curLayerNum = nextLayerNum;  // 把记录的下层结点数赋给 curLayerNum
                nextLayerNum = 0;   // 下层结点数的标记置0，方便下次继续使用
            }
        }

        return rlt;
    }
    
}

```

递归

```java

import java.util.ArrayList;
import java.util.Queue;
import java.util.LinkedList;

/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     int val;
 *     TreeNode left;
 *     TreeNode right;
 *     TreeNode(int x) { val = x; }
 * }
 */
class Solution {
    public List<List<Integer>> levelOrder(TreeNode root) {
        List<List<Integer>> list = new ArrayList<>();
        depth(root, 1, list);
        return list;
    }
     
    private void depth(TreeNode root, int depth, List<List<Integer>> list) {
        if(root == null) return;
        if(depth > list.size())
            list.add(new ArrayList<Integer>());
        list.get(depth -1).add(root.val);  
         
        depth(root.left, depth + 1, list);
        depth(root.right, depth + 1, list);
    }
}
```