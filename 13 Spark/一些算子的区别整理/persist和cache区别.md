# persist和cache区别

RDD 通过 `persist()` 或 `cache()` 将计算结果缓存，但是并不是被调用时立即缓存，而是触发后面的 action 时，才会被缓存在计算节点的内存中。

其中，`unpersist()` 取消缓存。

`persist` 和 `cache` 区别是：

`cache` 底层调用的是 `persist` 的无参方法`def cache(): this.type = persist()`，这个无参方法的存储级别是`MEMORY_ONLY`

`persist` 有三个对应的方法，分别是:

- `def persist(): this.type = persist(StorageLevel.MEMORY_ONLY)`
- `def persist(newLevel: StorageLevel): this.type`
- `private def persist(newLevel: StorageLevel, allowOverride: Boolean): this.type`

一个方法是无参方法，其存储级别是MEMORY_ONLY；一个方法是可以指定存储级别；一个方法是private，可以指定存储级别和是否覆盖旧的存储级别。