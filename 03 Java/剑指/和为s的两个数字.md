# 和为s的两个数字

## 1、题目

输入一个递增排序的数组和一个数字s，在数组中查找两个数，使得它们的和正好是s。如果有多对数字的和等于s，则输出任意一对即可。

示例 1：

	输入：nums = [2,7,11,15], target = 9
	输出：[2,7] 或者 [7,2]

示例 2：

	输入：nums = [10,26,30,31,47,60], target = 40
	输出：[10,30] 或者 [30,10]
 
限制：

	1 <= nums.length <= 10^5
	1 <= nums[i] <= 10^6

## 2、思路

方法1：定义前后两个指针，一个从0开始，一个从nums.length-1开始，相加，和target比较。如果小于，让前面的指针自增，后面的指针不变。

方法2：因为是递增排序的数组，所以使用二分查找。确定一个值，再二分查找另一个值，

## 3、解法

```java
class Solution {

    public int[] twoSum(int[] nums, int target) {
        if(nums.length==0 || nums.length < 2) return new int[0];
        int[] rlt = new int[2];
        int lo=0,hi=nums.length-1;
        while(lo<=hi){
            if(nums[lo]+nums[hi]==target){
                rlt[0] = nums[lo];
                rlt[1] = nums[hi];
                break;
            }else if(nums[lo]+nums[hi]<target){
                lo++;
            }else{
                hi--;
            }
        }
        return rlt;
    }

}
//执行用时：2 ms
//内存消耗：55.9 MB
```

```java
class Solution {

    int[] rlt = new int[2];
    public int[] twoSum(int[] nums, int target) {
        if(nums.length==0 || nums.length < 2) return new int[0];

        for(int i=0;i<nums.length;i++){
            bs(nums,i+1,nums.length-1,nums[i],target);
            if(rlt[0]!=0 && rlt[1]!=0) break;
        }
        return rlt;
    }

    public void bs(int[] nums,int lo,int hi,int base,int target){
        if(lo>hi) return;

        while(lo<=hi){
            int mid = lo+(hi-lo)/2;
            if(nums[mid]+base==target){
                rlt[1]=base;
                rlt[0]=nums[mid];
                return;
            }else if(nums[mid]+base>target){
                hi = mid-1;
            }else{
                lo = mid+1;
            }
        }
        return;
    }
}
//执行用时：46 ms
//内存消耗：55.9 MB
```