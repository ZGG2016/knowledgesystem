# 和为s的连续正数序列

## 1、题目

输入一个正整数 target ，输出所有和为 target 的连续正整数序列（至少含有两个数）。

序列内的数字由小到大排列，不同序列按照首个数字从小到大排列。

示例 1：

	输入：target = 9
	输出：[[2,3,4],[4,5]]

示例 2：

	输入：target = 15
	输出：[[1,2,3,4,5],[4,5,6],[7,8]]

限制：

	1 <= target <= 10^5


## 2、思路

方法1：滑动窗口。定义窗口的左右两个边界left、right，实时更新窗口内值的和sum。当sum小于target，右边界右移，当大于时，左边界右移。

方法2：滑动窗口。直接利用等差数列求和公式计算。

## 3、解法

```java
class Solution {
    public int[][] findContinuousSequence(int target) {

        int left = 1,right = 1,sum = 0;
        ArrayList<int[]> rlt = new ArrayList<int[]>();
        while(left<=target/2){//当left超过一半时，不会存在两个数的和等于target

            if(sum<target){ //先判断再加和
                sum+=right;
                right++;
            }else if(sum>target){
                sum-=left;
                left++;
            }else{
                int[] arr = new int[right-left];  
                for(int i=left;i<right;i++){
                    arr[i-left]=i;
                }
                rlt.add(arr);
                
                sum-=left;
                left++; 
            }
        }
        return rlt.toArray(new int[rlt.size()][]);
    }
}
//执行用时：5 ms
//内存消耗：36.9 MB

class Solution {
    public int[][] findContinuousSequence(int target) {

        ArrayList<int[]> rlt = new ArrayList<int[]>();

        for(int l=1,r=2;l<r;){
            int sum = (l + r) * (r - l + 1) / 2;
            if (sum == target){
                int[] arr = new int[r-l+1];
                for (int i = l; i <= r; i++){
                    arr[i-l]=i;
                }
                rlt.add(arr);
                l++;
            }else if (sum < target){
                r++;
            } else{
                l++;
            }
        }

        return rlt.toArray(new int[rlt.size()][]);
    }
}
//执行用时：5 ms
//内存消耗：37.1 MB
```