# groupByKey和reduceByKey的区别

相同点：

	都作用于pair RDD

	都是根据key来分组或聚合

	都可以通过参数来指定分区数量，都是默认HashPartitioner

	执行逻辑均在combineByKeyWithClassTag

不同点：

	groupByKey默认没有聚合函数，得到的返回值类型是RDD[ k,Iterable[V]]。是对key对应的values分组，成一个序列。

	reduceByKey 必须传聚合函数，得到的返回值类型 RDD[(K,聚合后的V)]。通过传入的函数进行聚合操作。

	groupByKey().map() = reduceByKey

	reduceByKey会先在本地进行聚合，而groupByKey不会。

### (1)groupByKey:

对rdd中每个key对应的values分组，成一个序列。每组内的元素不一定是有序的。

使用HashPartitioner对结果分区。

主要执行逻辑在combineByKeyWithClassTag

所以：

	作用域是key-value类型的键值对(pair RDD)

	transformation类型的算子，是懒加载的。

	作用：把相同key的values转成一个序列(sequence)

	如果相对序列做聚合操作，可以使用groupByKey，但是优先选择reduceByKey\aggregateByKey
	第二个实现，key-values对被保存在内存中，如果一个key有太多的values,，会导致OutOfMemoryError


### (2)reduceByKey:

根据用户传入的函数对每个key对应的所有values做merge操作(具体的操作类型根据用户定义的函数)

在将结果发送给reducer前，首先它会在每个mapper上执行本地的合并，类似于mapreduce中的combiner。

使用HashPartitioner对结果分区

主要执行逻辑在combineByKeyWithClassTag

所以：

	作用域是key-value类型的键值对(pair RDD)，并且只对每个key的value进行处理，
    如果含有多个key的话，那么就对多个values进行处理。

	transformation类型的算子，是懒加载的。

	需要传递一个相关的函数作为参数，这个函数将会被应用到源RDD上并且创建一个新的RDD作为返回结果

