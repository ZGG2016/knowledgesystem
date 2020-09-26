# 二叉搜索树的第k大节点


## 1、题目

给定一棵二叉搜索树，请找出其中第k大的节点。

示例 1:

	输入: root = [3,1,4,null,2], k = 1
	   3
	  / \
	 1   4
	  \
	   2
	输出: 4

示例 2:

	输入: root = [5,3,6,2,4,null,null,1], k = 3
	       5
	      / \
	     3   6
	    / \
	   2   4
	  /
	 1
	输出: 4 

限制：

	1 ≤ k ≤ 二叉搜索树元素个数

## 2、思路

方法1：中序遍历。二叉搜索树的中序遍历是从小到大排序的。所以遍历后，放列表里，再由索引取值。

方法2：逆中序遍历。二叉搜索树的中序遍历是从大到小排序的。定义一个变量c，当遍历的次数到c时，就取值。

方法3：遍历树，放到一个有序set里，再遍历取值。

## 3、解法

**方法1**

```java
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
    ArrayList<Integer> al = new ArrayList<Integer>();
    public int kthLargest(TreeNode root, int k) {
        midOrder(root);
        
        return al.get(al.size()-k); 
    }
    public void midOrder(TreeNode root){
         if(root==null) return;
         
         midOrder(root.left);
         al.add(root.val);
         midOrder(root.right);
         
     }
}
//执行用时：1 ms
//内存消耗：39.4 MB
```

**方法2**

```java
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

    int i=0,rlt=0;

    public int kthLargest(TreeNode root, int k) {
        midOrder(root,k);
        return rlt; 
    }
    public void midOrder(TreeNode root,int k){
         if(root==null) return;
         
         midOrder(root.right,k);
         
         ++i;
         if(k==i){
            rlt = root.val;
         }

         midOrder(root.left,k);
         
     }
}
//执行用时：0 ms
//内存消耗：38.8 MB
```

**方法3**

```java
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
    public int kthLargest(TreeNode root, int k) {
        if(root==null) return 0;

        TreeSet<Integer> ts = new TreeSet<Integer>(
                new Comparator<Integer>() {
                    @Override
                    public int compare(Integer o1, Integer o2) {
                        return -(o1-o2);
                    }
                }
        );
        Queue<TreeNode> queue = new LinkedList<>();
        queue.add(root);
        while(queue.size()!=0){
            TreeNode tmp = queue.remove();
            ts.add(tmp.val);

            if(tmp.left!=null){
                queue.add(tmp.left);
            }
            if(tmp.right!=null){
                queue.add(tmp.right);
            }           
        }

        Integer[] arr = ts.toArray(new Integer[0]);
        for(int i=0;i<arr.length;i++){
            if(i==k-1){
                return arr[i];
            }
        }
        return 0;
    }
}
//执行用时：11 ms
//内存消耗：39.6 MB
```