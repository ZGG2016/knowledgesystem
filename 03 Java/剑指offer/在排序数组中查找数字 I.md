# 在排序数组中查找数字 I

## 1、题目

统计一个数字在排序数组中出现的次数。

示例 1:

	输入: nums = [5,7,7,8,8,10], target = 8
	输出: 2

示例 2:

	输入: nums = [5,7,7,8,8,10], target = 6
	输出: 0
 

限制：

	0 <= 数组长度 <= 50000

## 2、思路

二分查找

思路1：这里是查找出现的次数，而不是位置。所以定义一个变量，每当找到一个就加1。

思路2：找到第一个和最后一个出现的值，索引做差。

## 3、解法

```java
class Solution {

    int cnt = 0;

    public int search(int[] nums, int target) {
        if(nums.length==0) return 0;

        helper(nums,target,0,nums.length-1);
        return cnt;
    }

    public void helper(int[] nums, int target,int lo,int hi){
		if(lo>hi) return;

        if(lo<=hi){
            int mid = (lo+hi)/2;
            if(nums[mid]==target){
                cnt++;
                helper(nums,target,lo,mid-1);
                helper(nums,target,mid+1,hi);
            }else if(nums[mid]>target){
                helper(nums,target,lo,mid-1);
            }else if(nums[mid]<target){
                helper(nums,target,mid+1,hi);
            }
        }

    }
}
//执行用时：0 ms
//内存消耗：41.9 MB
```

```java
class Solution {

    public int search(int[] nums, int target) {
        int i=0;
        int j=nums.length-1;
        //找到以后，说明target在[i,j]之间
        while (i<j){
            int mid = (i+j)/2;
            if(nums[mid]<target){
                i = mid+1;
            }
            else if(nums[mid]>target){
                j = mid-1;
            }
            else {
                break;
            }
        }
        int res=0;
        for(int k=i; k<=j;k++){
            if(target == nums[k]) res++;
        }
        return res;
    }

}
//执行用时：1 ms
//内存消耗：42.2 MB
```

```java
//找到第一个和最后一个出现的值，索引做差。
class Solution {

    public int search(int[] nums, int target) {
        if(nums.length==0) return 0;

        ArrayList<Integer> al = new ArrayList<Integer>();
        for(int num:nums){
            al.add(num);
        }

        int start = al.indexOf(target);
        int end = al.lastIndexOf(target);

        if(start!=-1 && end!=-1){
            return end-start+1;
        }

        return 0;
    }

}
//执行用时: 6 ms
//内存消耗: 42.1 MB
```

[分析](https://leetcode-cn.com/problems/zai-pai-xu-shu-zu-zhong-cha-zhao-shu-zi-lcof/solution/mian-shi-ti-53-i-zai-pai-xu-shu-zu-zhong-cha-zha-5/)

```java
//找到第一个和最后一个出现的值，索引做差。
    public int GetNumberOfK1(int [] array , int k) {
        if (array.length == 0 || array[0] > k || array[array.length - 1] < k) return 0;

        int first = getFirstK(array,k,0,array.length-1);
        int last = getLastK(array,k,0,array.length-1);

        if(first != -1 && last != -1){
            return last - first + 1;
        }
        return 0;
    }
    private int getFirstK(int [] array , int k, int start, int end){
        while(start <= end){
            int mid = (start + end) >> 1;
            if(array[mid] > k){
                end = mid-1;
            }else if(array[mid] < k){
                start = mid+1;
            }else{
                if(mid>0 && array[mid-1]!=k||mid==0){
                    return mid;
                }else{
                    end = mid-1;
                }
            }
        }
        return -1;
    }
    private int getLastK(int [] array , int k, int start, int end){
        int length = array.length;

        while(start <= end){
            int mid = (start + end) >> 1;
            if(array[mid] > k){
                end = mid-1;
            }else if(array[mid] < k){
                start = mid+1;
            }else if(mid<length-1 && array[mid+1]!=k||mid==array.length-1){
                return mid;
            }else{
                start = mid+1;
            }
        }
        return -1;
    }
```

--------------------------------------------------------------------

方法2：直接遍历，计数

方法3：遍历、计数后，放hashmap中，再取。

```java
class Solution {
    public int search(int[] nums, int target) {
        if(nums.length==0) return 0;

        int c = 0;
        for(int i=0;i<nums.length;i++){
            if(nums[i]==target){
                c++;
            }
        }
        return c;
    }
}
//执行用时: 1 ms
//内存消耗: 41.9 MB
```

```java
class Solution {
    public int search(int[] nums, int target) {
        if(nums.length==0) return 0;

        HashMap<Integer,Integer> hm = new HashMap<Integer,Integer>();
        for(int num:nums){
            if(hm.containsKey(num)){
                hm.put(num,hm.get(num)+1);
            }else{
                hm.put(num,1);
            }
        }


        for(int num:nums){
            if(num==target){
                return hm.get(num);
            }
        }

        return 0;
    }
}
//执行用时: 12 ms
//内存消耗: 42 MB
```
