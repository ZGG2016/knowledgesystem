# 数组中数字出现的次数 II

## 1、题目

在一个数组 nums 中除一个数字只出现一次之外，其他数字都出现了三次。请找出那个只出现一次的数字。

示例 1：

	输入：nums = [3,4,3,3]
	输出：4

示例 2：

	输入：nums = [9,1,7,9,7,9,7]
	输出：1

限制：

	1 <= nums.length <= 10000
	1 <= nums[i] < 2^31

## 2、思路

方法1：

	对于出现三次的数字，各 二进制位 出现的次数都是 3 的倍数。
	因此，统计所有数字的各二进制位中 1 的出现次数，并对 3 求余，结果则为只出现一次的数字。

[详细解释及有限状态自动机](https://leetcode-cn.com/problems/shu-zu-zhong-shu-zi-chu-xian-de-ci-shu-ii-lcof/solution/mian-shi-ti-56-ii-shu-zu-zhong-shu-zi-chu-xian-d-4/)

方法2:
	
	因为除一个数字只出现一次之外，其他数字都出现了三次。那么，先定义一个结果变量，对于这些出现三次的数字，第一次出现的时候加这个数的二倍，后面如果再出现，出现一次就减一次，这样结果就抵消了，最后只剩个只出现一次的数字。

方法3：

	先排序，再判断当前数字和前后两个数字是不是相等。
	要考虑开始和结尾的特殊情况。

方法4：
	
	HashMap 遍历统计出现次数

## 3、解法

```java
// 方法1
class Solution {
    public int singleNumber(int[] nums) {

        int[] counts = new int[32];  //java int类型有32位
        for(int num:nums){  //一个数一个数的计算
        	for(int i=0;i<32;i++){  
        		//更新第 i 位
        		counts[i] += num&1;  //&：同为1，才为1。所以只有在第一位是1，才能计数加1
        		// 第 i 位 --> 第 i + 1 位
        		num>>>=1;  //将num右移，才将num的每一个依次和1位与
        	}
        }
        for(int i=0;i<32;i++){
        	// 得到 只出现一次的数字 的第 (31 - i) 位
        	counts[i]%=3;    //得到余数

        }
        int rlt = 0;
		for(int i=0;i<32;i++){
			rlt<<=1;   //将 counts 数组中的二进位的值从左到右依次恢复到数字 rlt 
        	rlt|=counts[31-i]; // |：只有有一个1，就为1

        }
        return rlt;
    }
}
//执行用时：5 ms
//内存消耗：39.1 MB

//只需要修改求余数值 m ，即可实现解决 除了一个数字以外，其余数字都出现 m 次
class Solution {
    public int singleNumber(int[] nums) {
        int[] counts = new int[32];
        for(int num : nums) {
            for(int j = 0; j < 32; j++) {
                counts[j] += num & 1;
                num >>>= 1;
            }
        }
        int res = 0, m = 3;
        for(int i = 0; i < 32; i++) {
            res <<= 1;
            res |= counts[31 - i] % m;
        }
        return res;
    }
}


// 方法2
class Solution {
    public int singleNumber(int[] nums) {
        if(nums.length==0) return -1;

        HashSet<Long> hs = new HashSet<>();
        long rlt = 0;
        for(long n:nums){
        	if(!hs.contains(n)){
        		hs.add(n);
        		rlt+=n<<1;
        	}else{
        		rlt-=n;
        	}
        }
        return (int)(rlt/2);
    }
}
//执行用时：12 ms
//内存消耗：39.6 MB

// 方法3
class Solution {
    public int singleNumber(int[] nums) {
        if(nums.length==0) return -1;

    	Arrays.sort(nums);

    	if(nums[0]!=nums[1]){
    		return nums[0];
    	}

    	for(int i=1;i<nums.length-1;i++){
    		if(nums[i]!=nums[i-1] && nums[i]!=nums[i+1]){
    			return nums[i];
    		}
    	}
    	return nums[nums.length-1];
    }
}
//执行用时：7 ms
//内存消耗：39.4 MB

class Solution {
    public int singleNumber(int[] nums) {
        if(nums.length==0||nums==null) return -1;
        Arrays.sort(nums);
        int i = 0,j=1;
        while(j<nums.length){
            if (nums[i]!=nums[j]) break;
            else {
                i+=3;
                j+=3;
            }
        }
        return nums[i];

    }
}


//方法4
class Solution {
    public int singleNumber(int[] nums) {
        if(nums.length==0) return -1;

        HashMap<Integer,Integer> hm = new HashMap<>();
        for(int n:nums){
            if(hm.containsKey(n)){
                hm.put(n,hm.get(n)+1);
            }else{
                hm.put(n,1);
            }
        }

        Set<Integer> keys = hm.keySet();
        for(Integer key:keys){
            if(hm.get(key)==1){
                return key;
            }
        }
        return -1;
    }
}
//执行用时：15 ms
//内存消耗：39.7 MB
```