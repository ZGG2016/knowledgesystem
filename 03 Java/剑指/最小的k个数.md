# 最小的k个数

## 1、题目

输入整数数组 arr ，找出其中最小的 k 个数。例如，输入4、5、1、6、2、7、3、8这8个数字，则最小的4个数字是1、2、3、4。

示例 1：

	输入：arr = [3,2,1], k = 2
	输出：[1,2] 或者 [2,1]

示例 2：

	输入：arr = [0,1,2,1], k = 1
	输出：[0]
 

限制：

	0 <= k <= arr.length <= 10000
	0 <= arr[i] <= 10000


## 2、思路

方法1：利用Arrays，先排序，再截取。

方法2：利用大根堆，Java 中提供了现成的 PriorityQueue（默认小根堆），所以需要重写比较器。

**方法3**：利用快速排序思想。如果取到的切分元素索引等于k，那么左子数组就是结果，否则递归的处理子数组。

## 3、解法

**方法1**

```java
class Solution {
    public int[] getLeastNumbers(int[] arr, int k) {
        if(arr.length==0 || k==0) return new int[0];
        
        Arrays.sort(arr);

        return Arrays.copyOf(arr,k);
    }
}
//执行用时：7 ms, 在所有 Java 提交中击败了69.06%的用户
//内存消耗：40.3 MB, 在所有 Java 提交中击败了24.49%的用户
```

**方法2**

```java
class Solution {
    public int[] getLeastNumbers(int[] arr, int k) {
        if(arr.length==0 || k==0) return new int[0];
        
        PriorityQueue<Integer> pq = new PriorityQueue<Integer>(new MyComparator());
        for(int a:arr){
        	pq.offer(a);
        }
        int[] res = new int[k];
        int i=0;
        while(k>0){
        	res[i] = pq.poll();
        	k--;
            i++;
        }
        return res;
    }
    public class MyComparator implements Comparator<Integer> {
        public int compare(Integer o1, Integer o2) {
            // TODO Auto-generated method stub
            return o1 - o2;
        }
    }
}
//执行用时：21 ms, 在所有 Java 提交中击败了27.37%的用户
//内存消耗：40.2 MB, 在所有 Java 提交中击败了49.80%的用户
```

```java
class Solution {
    public int[] getLeastNumbers(int[] arr, int k) {
        if(arr.length==0 || k==0) return new int[0];
        else if(arr.length<=k) return arr;

        return helper(arr,0,arr.length-1,k);
    }

    public int[] helper(int[] arr,int lo,int hi, int k){
        int j = partition(arr,lo,hi);
        if(j==k){
            return Arrays.copyOf(arr,k);
        }
        return j>k?helper(arr,lo,j-1,k):helper(arr,j+1,hi,k);
        
    }

	public int partition(int[] a, int lo, int hi) {
        int i = lo;
        int j = hi + 1;
        int v = a[lo];
        while (true) {
            while (a[++i]< v){
                if (i == hi) break;  // 遍历到 hi 位置，仍比 v 小，就得退出循环，否则数组越界。
            }
            while (v<a[--j]){
                if (j == lo) break;
            }
            if (i >= j){   //  当两个指针i、j相遇交换后，i 大于 j。等于是两指针在同一位置
                break;
            }
            exch(a, i, j);

        }
        exch(a, lo, j); //当两个指针相遇交换后，再交换 A 和左子数组的最右侧元素交换。
        return j;
    }
    
    public void exch(int[] arr,int i,int j){
        int t = arr[i];
        arr[i] = arr[j];
        arr[j] = t;
    }
}

//执行用时：2 ms, 在所有 Java 提交中击败了99.53%的用户
//内存消耗：40.1 MB, 在所有 Java 提交中击败了53.55%的用户
```
```java
//还有再考虑下
public int[] getLeastNumbers(int[] arr, int k) {
        if (k == 0 || arr.length == 0) {
            return new int[0];
        }
        // 最后一个参数表示我们要找的是下标为k-1的数
        return quickSearch(arr, 0, arr.length - 1, k - 1);
    }

    private int[] quickSearch(int[] nums, int lo, int hi, int k) {
        // 每快排切分1次，找到排序后下标为j的元素，如果j恰好等于k就返回j以及j左边所有的数；
        int j = partition(nums, lo, hi);
        if (j == k) {
            return Arrays.copyOf(nums, j + 1);
        }
        // 否则根据下标j与k的大小关系来决定继续切分左段还是右段。
        return j > k? quickSearch(nums, lo, j - 1, k): quickSearch(nums, j + 1, hi, k);
    }

    // 快排切分，返回下标j，使得比nums[j]小的数都在j的左边，比nums[j]大的数都在j的右边。
    private int partition(int[] nums, int lo, int hi) {
        int v = nums[lo];
        int i = lo, j = hi + 1;
        while (true) {
            while (++i <= hi && nums[i] < v);
            while (--j >= lo && nums[j] > v);
            if (i >= j) {
                break;
            }
            int t = nums[j];
            nums[j] = nums[i];
            nums[i] = t;
        }
        nums[lo] = nums[j];
        nums[j] = v;
        return j;
    }
}

//作者：sweetiee
//链接：https://leetcode-cn.com/problems/zui-xiao-de-kge-shu-lcof/solution/3chong-jie-fa-miao-sha-topkkuai-pai-dui-er-cha-sou/
//来源：力扣（LeetCode）
//著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

```java
//????
public class test {
    public static void main(String[] args){
        int[] arr = {0,0,2,3,2,1,1,2,0,4};
        //Exception in thread "main" java.lang.ArrayIndexOutOfBoundsException: 10
        System.out.println(Arrays.toString(getLeastNumbers(arr, 10)));
    }
    public static int[] getLeastNumbers(int[] arr, int k) {
        if(arr.length==0 || k==0) return new int[0];
//        else if(arr.length<=k) return arr;

        return helper(arr,0,arr.length-1,k);
    }

    public static int[] helper(int[] arr,int lo,int hi, int k){
        int j = partition(arr,lo,hi);
        if(j==k){
            return Arrays.copyOf(arr,k);
        }
        return j>k?helper(arr,lo,j-1,k):helper(arr,j+1,hi,k);

    }

    public static int partition(int[] a, int lo, int hi) {
        int i = lo;
        int j = hi + 1;
        int v = a[lo];
        while (true) {
            while (a[++i]< v){
                if (i == hi) break;  // 遍历到 hi 位置，仍比 v 小，就得退出循环，否则数组越界。
            }
            while (v<a[--j]){
                if (j == lo) break;
            }
            if (i >= j){   //  当两个指针i、j相遇交换后，i 大于 j。等于是两指针在同一位置
                break;
            }
            exch(a, i, j);

        }
        exch(a, lo, j); //当两个指针相遇交换后，再交换 A 和左子数组的最右侧元素交换。
        return j;
    }

    public static void exch(int[] arr,int i,int j){
        int t = arr[i];
        arr[i] = arr[j];
        arr[j] = t;
    }
}

```