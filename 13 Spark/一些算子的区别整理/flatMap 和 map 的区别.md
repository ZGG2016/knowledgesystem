# flatMap 和 map 的区别

map: 

	将函数应用在RDD的所有元素上，返回一个新的RDD

	def map[U: ClassTag](f: T => U): RDD[U]

flatMap: 

	首先将函数应用在RDD的所有元素上，然后将结果展平，返回一个新的RDD。

	传给flatMap的元素要是可迭代类型.

	def flatMap[U: ClassTag](f: T => TraversableOnce[U]): RDD[U]

```python
>>> data = sc.parallelize(["a,b","b,c"])
>>> rdd1 = data.map(lambda x:x.split(','))
>>> rdd1.collect()
[['a', 'b'], ['b', 'c']]                                                        
>>> rdd2 = data.flatMap(lambda x:x.split(','))
>>> rdd2.collect()
['a', 'b', 'b', 'c']

```

    val test = sc.parallelize(List(1,2,3))
    test.map(x=>x+1)
    test.flatMap(x=>x+1) //报错：类型不匹配