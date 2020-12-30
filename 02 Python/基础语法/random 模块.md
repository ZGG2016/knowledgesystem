# random 模块

[TOC]

该模块实现了各种分布的伪随机数生成器。

对于整数，从范围中有统一的选择，【randrange、randint】

对于序列，存在随机元素的统一选择，【choice、choices】

用于生成列表的随机排列的函数，【shuffle】

以及用于随机抽样而无需替换的函数。【sample】

在实数轴上，有计算均匀、正态（高斯）、对数正态、负指数、伽马和贝塔分布的函数。 为了生成角度分布，可以使用 von Mises 分布。

**几乎所有模块函数都依赖于基本函数 random() ，它在半开放区间 [0.0,1.0) 内均匀生成随机浮点数**。 Python 使用 Mersenne Twister 作为核心生成器。 它产生 53 位精度浮点数，周期为 `2**19937-1`，其在 C 中的底层实现既快又线程安全。 Mersenne Twister 是现存最广泛测试的随机数发生器之一。 但是，因为完全确定性，它不适用于所有目的，并且完全不适合加密目的。

这个模块提供的函数实际上是 random.Random 类的隐藏实例的绑定方法。 你**可以实例化自己的 Random 类实例以获取不共享状态的生成器**。

**如果你想使用自己设计的不同基础生成器，类 Random 也可以作为子类**：在这种情况下，重载 random() 、seed() 、getstate() 以及 setstate() 方法。可选地，新生成器可以提供 getrandbits() 方法，这允许 randrange() 在任意大的范围内产生选择。

random 模块还提供 **SystemRandom 类，它使用系统函数 os.urandom() 从操作系统提供的源，生成随机数**。

警告：不应将此模块的伪随机生成器用于安全目的。 有关安全性或加密用途，请参阅 [secrets](https://docs.python.org/zh-cn/3.8/library/secrets.html#module-secrets) 模块。

## 1、簿记功能

	random.seed(a=None, version=2)

**初始化随机数生成器**。

如**果 a 被省略或为 None ，则使用当前系统时间**。 如果操作系统提供随机源，则使用它们而不是系统时间（有关可用性的详细信息，请参阅 os.urandom() 函数）。

**如果 a 是 int 类型，则直接使用**。

对于版本2（默认的），str 、 bytes 或 bytearray 对象转换为 int 并使用它的所有位。

对于版本1（用于从旧版本的Python再现随机序列），用于 str 和 bytes 的算法生成更窄的种子范围。

在 3.2 版更改: 已移至版本2方案，该方案使用字符串种子中的所有位。

---------------------------------------------------------------

```sh
>>> import random

>>> random.seed(1)
>>> random.random()
0.13436424411240122

>>> random.seed(2)
>>> print(random.random())
0.9560342718892494

>>> random.seed(1)
>>> random.random()
0.13436424411240122

>>> random.seed(2)
>>> random.random()
0.9560342718892494

>>> random.random()
0.9478274870593494
>>> random.random()
0.05655136772680869
>>> random.random()
0.08487199515892163
>>> random.random()
0.8354988781294496
```

---------------------------------------------------------------

	random.getstate()

**返回捕获的生成器当前内部状态的对象**。 这个对象可以传递给 setstate() 来恢复状态。

	random.setstate(state)

state 应该是从之前调用 getstate() 获得的，并且 setstate() **将生成器的内部状态恢复到 getstate() 被调用时的状态**。

	random.getrandbits(k)

返回具有 k 个随机比特位的 Python 整数。 此方法随 Mersenne Twister 生成器一起提供，其他一些生成器也可能将其作为 API 的可选部分提供。 **在可能的情况下，getrandbits() 会启用 randrange() 来处理任意大的区间**。

## 2、用于整数的函数

	random.randrange(stop)
	random.randrange(start, stop[, step])

**从 range(start, stop, step) 返回一个随机选择的元素**。 这相当于 choice(range(start, stop, step)) ，但实际上并没有构建一个 range 对象。

位置参数模式匹配 range() 。**不应使用关键字参数**，因为该函数可能以意外的方式使用它们。

在 3.2 版更改: randrange() 在生成均匀分布的值方面更为复杂。 以前它使用了像``int(random()*n)``这样的形式，它可以产生稍微不均匀的分布。

	random.randint(a, b)

**返回随机整数 N ，N 满足 a <= N <= b**。相当于 randrange(a, b+1)。

-------------------------------------------------------------------------

```sh
>>> random.randrange(10)
1
>>> random.randrange(10)
4
>>> random.randrange(5,10,2)
5
>>> random.randrange(5,10,2)
7

>>> random.randint(5,10)
8
>>> random.randint(5,10)
8
>>> random.randint(5,10)
10
>>> random.randint(5,10)
8
```

-------------------------------------------------------------------------

## 3、用于序列的函数

	random.choice(seq)

**从非空序列 seq 返回一个随机元素**。 如果 seq 为空，则引发 IndexError。

	random.choices(population, weights=None, *, cum_weights=None, k=1)

**有放回地从*population*中选择，返回大小为 k 的元素列表**。 如果 population 为空，则引发 IndexError。

如果指定了 **weight 序列，则根据相对权重进行选择**。 

如果给出 **cum_weights 序列，则根据累积权重**【？？？】（可能使用 [itertools.accumulate()](https://docs.python.org/zh-cn/3.8/library/itertools.html#itertools.accumulate) 计算）进行选择。

例如，相对权重`[10, 5, 30, 5]`相当于累积权重`[10, 15, 45, 50]`。在内部，**相对权重在进行选择之前会转换为累积权重，因此提供累积权重可以节省工作量**。

**如果既未指定 weight ，也未指定 cum_weights ，则以相等的概率进行选择**。

**如果提供了权重序列，则它必须与 population 序列的长度相同**。 一个 TypeError 指定了 weights 和*cum_weights*。

weights 或 cum_weights 可以使用任何与 random() 所返回的 float 值互操作的数值类型（包括整数、浮点数和分数但不包括十进制小数）。 权重假定为非负数。

对于给定的种子，具有相等加权的 choices() 函数通常产生与重复调用 choice() 不同的序列。 choices() 使用的算法使用浮点运算来实现内部一致性和速度。 choice() 使用的算法默认为重复选择的整数运算，以避免因舍入误差引起的小偏差。

----------------------------------------------------------------------

```sh
>>> random.choice(["a","b","c","d"])
'b'
>>> random.choice(["a","b","c","d"])
'a'

# k 是选取的次数
>>> random.choices(["a","b","c","d","e"],k=2)
['e', 'e']
>>> random.choices(["a","b","c","d","e"],k=2)
['c', 'e']

# "e"在每次选择中，被选的概率是 5/10=50%
>>> for i in range(10):
...     print(random.choices(["a","b","c","d","e"],weights=[1,2,1,1,5]))
...
['a']
['e']
['e']
['e']
['e']
['e']
['e']
['e']
['e']
['c']

```

---------------------------------------------------------------------

	random.shuffle(x[, random])

**将序列 x 随机打乱位置**。

可选参数 random 是一个0参数函数，在 [0.0, 1.0) 中返回随机浮点数，默认情况下是函数 random() 。

要改变一个不可变的序列，并返回一个新的打乱列表，请使用`sample(x, k=len(x))`。

请注意，即使对于小的 len(x)，x 的排列总数也可以快速增长，大于大多数随机数生成器的周期。 这意味着长序列的大多数排列永远不会产生。 例如，长度为2080的序列是可以在 Mersenne Twister 随机数生成器的周期内拟合的最大序列。

	random.sample(population, k)

**返回从总体序列或集合中选择的唯一元素的 k 长度列表。 用于无重复的随机抽样**。

**返回包含来自总体的元素的新列表，同时保持原始总体不变**。结果列表按选择顺序排列，因此所有子切片也将是有效的随机样本。 这允许抽奖获奖者（样本）被划分为大奖和第二名获胜者（子切片）。

总体成员不必是 hashable 或 unique 。 如果总体包含重复，则每次出现都是样本中可能的选择。

要从一系列整数中选择样本，请使用 range() 对象作为参数。对于从大量人群中采样，这种方法特别快速且节省空间：sample(range(10000000), k=60) 。

如果样本大小大于总体大小，则引发 ValueError 。

---------------------------------------------------------------------

```sh
>>> a = [1,2,3,4,5]
>>> random.shuffle(a)
>>> a
[3, 4, 2, 1, 5]

>>> b = "abcd"
>>> random.shuffle(b)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "C:\Soft\python3\lib\random.py", line 278, in shuffle
    x[i], x[j] = x[j], x[i]
TypeError: 'str' object does not support item assignment

>>> random.sample(b,k=len(b))
['d', 'c', 'a', 'b']

>>> random.sample(a,k=2)
[5, 2]
```

---------------------------------------------------------------------

## 4、实值分布

以下函数生成特定的实值分布。如常用数学实践中所使用的那样，函数参数以分布方程中的相应变量命名;大多数这些方程都可以在任何统计学教材中找到。

	random.random()

**返回 [0.0, 1.0) 范围内的下一个随机浮点数**。

	random.uniform(a, b)

**返回一个随机浮点数 N**，当 a <= b 时 a <= N <= b ，当 b < a 时 b <= N <= a 。

取决于等式 a + (b-a) * random() 中的浮点舍入，终点 b 可以包括或不包括在该范围内。

---------------------------------------------------------------------

```sh
>>> random.random()
0.0864675897282483
>>> random.random()
0.6637578048439807

>>> random.uniform(1,2)
1.1079312620941
>>> random.uniform(1,2)
1.163698297149974
```

---------------------------------------------------------------------

	random.triangular(low, high, mode)

返回一个随机浮点数 N ，使得 low <= N <= high 并在这些边界之间使用指定的 mode 。 low 和 high 边界默认为零和一。 mode 参数默认为边界之间的中点，给出对称分布。

	random.betavariate(alpha, beta)

Beta 分布。 参数的条件是 alpha > 0 和 beta > 0。 返回值的范围介于 0 和 1 之间。

	random.expovariate(lambd)

指数分布。 lambd 是 1.0 除以所需的平均值，它应该是非零的。 （该参数本应命名为 “lambda” ，但这是 Python 中的保留字。）如果 lambd 为正，则返回值的范围为 0 到正无穷大；如果 lambd 为负，则返回值从负无穷大到 0。

	random.gammavariate(alpha, beta)

Gamma 分布。 （ 不是 gamma 函数！ ） 参数的条件是 alpha > 0 和 beta > 0。

概率分布函数是:

	          x ** (alpha - 1) * math.exp(-x / beta)
	pdf(x) =  --------------------------------------
	            math.gamma(alpha) * beta ** alpha

	random.gauss(mu, sigma)

高斯分布。 mu 是平均值，sigma 是标准差。 这比下面定义的 normalvariate() 函数略快。

	random.lognormvariate(mu, sigma)

对数正态分布。 如果你采用这个分布的自然对数，你将得到一个正态分布，平均值为 mu 和标准差为 sigma 。 mu 可以是任何值，sigma 必须大于零。

	random.normalvariate(mu, sigma)

正态分布。 mu 是平均值，sigma 是标准差。

	random.vonmisesvariate(mu, kappa)

冯·米塞斯（von Mises）分布。 mu 是平均角度，以弧度表示，介于0和 `2*pi` 之间，kappa 是浓度参数，必须大于或等于零。 如果 kappa 等于零，则该分布在 0 到 `2*pi` 的范围内减小到均匀的随机角度。

	random.paretovariate(alpha)

帕累托分布。 alpha 是形状参数。

	random.weibullvariate(alpha, beta)

威布尔分布。 alpha 是比例参数，beta 是形状参数。

## 5、替代生成器

	class random.Random([seed])

该类实现了 random 模块所用的默认伪随机数生成器。


	class random.SystemRandom([seed])

使用 [os.urandom()](https://docs.python.org/zh-cn/3.8/library/os.html#os.urandom) 函数的类，用从操作系统提供的源生成随机数。 这并非适用于所有系统。 也不依赖于软件状态，序列不可重现。 因此，seed() 方法没有效果而被忽略。 getstate() 和 setstate() 方法如果被调用则引发 NotImplementedError。

## 6、关于再现性的说明

有时能够重现伪随机数生成器给出的序列是有用的。**通过重新使用种子值，只要多个线程没有运行，相同的序列就可以在两次不同运行之间重现**。

大多数随机模块的算法和种子函数都会在 Python 版本中发生变化，但保证两个方面不会改变：

- 如果添加了新的播种方法，则将提供向后兼容的播种机。

- 当兼容的播种机被赋予相同的种子时，生成器的 random() 方法将继续产生相同的序列。

## 7、例子和配方

基本示例:

```sh
>>> random()                             # Random float:  0.0 <= x < 1.0
0.37444887175646646

>>> uniform(2.5, 10.0)                   # Random float:  2.5 <= x < 10.0
3.1800146073117523

>>> expovariate(1 / 5)                   # Interval between arrivals averaging 5 seconds
5.148957571865031

>>> randrange(10)                        # Integer from 0 to 9 inclusive
7

>>> randrange(0, 101, 2)                 # Even integer from 0 to 100 inclusive
26

>>> choice(['win', 'lose', 'draw'])      # Single random element from a sequence
'draw'

>>> deck = 'ace two three four'.split()
>>> shuffle(deck)                        # Shuffle a list
>>> deck
['four', 'two', 'ace', 'three']

>>> sample([10, 20, 30, 40, 50], k=4)    # Four samples without replacement
[40, 10, 50, 30]
```

模拟:

```sh
>>> # Six roulette wheel spins (weighted sampling with replacement)
>>> choices(['red', 'black', 'green'], [18, 18, 2], k=6)
['red', 'green', 'black', 'black', 'red', 'black']

>>> # Deal 20 cards without replacement from a deck of 52 playing cards
>>> # and determine the proportion of cards with a ten-value
>>> # (a ten, jack, queen, or king).
>>> deck = collections.Counter(tens=16, low_cards=36)
>>> seen = sample(list(deck.elements()), k=20)
>>> seen.count('tens') / 20
0.15

>>> # Estimate the probability of getting 5 or more heads from 7 spins
>>> # of a biased coin that settles on heads 60% of the time.
>>> def trial():
...     return choices('HT', cum_weights=(0.60, 1.00), k=7).count('H') >= 5
...
>>> sum(trial() for i in range(10_000)) / 10_000
0.4169

>>> # Probability of the median of 5 samples being in middle two quartiles
>>> def trial():
...     return 2_500 <= sorted(choices(range(10_000), k=5))[2] < 7_500
...
>>> sum(trial() for i in range(10_000)) / 10_000
0.7958
```

[statistical bootstrapping](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)) 的示例，使用重新采样和替换来估计一个样本的均值的置信区间:

```python
# http://statistics.about.com/od/Applications/a/Example-Of-Bootstrapping.htm
from statistics import fmean as mean
from random import choices

data = [41, 50, 29, 37, 81, 30, 73, 63, 20, 35, 68, 22, 60, 31, 95]
means = sorted(mean(choices(data, k=len(data))) for i in range(100))
print(f'The sample mean of {mean(data):.1f} has a 90% confidence '
      f'interval from {means[5]:.1f} to {means[94]:.1f}')
```

使用 [重新采样排列测试](https://en.wikipedia.org/wiki/Resampling_(statistics)#Permutation_tests) 来确定统计学显著性或者使用 [p-值](https://en.wikipedia.org/wiki/P-value) 来观察药物与安慰剂的作用之间差异的示例:

```python
# Example from "Statistics is Easy" by Dennis Shasha and Manda Wilson
from statistics import fmean as mean
from random import shuffle

drug = [54, 73, 53, 70, 73, 68, 52, 65, 65]
placebo = [54, 51, 58, 44, 55, 52, 42, 47, 58, 46]
observed_diff = mean(drug) - mean(placebo)

n = 10_000
count = 0
combined = drug + placebo
for i in range(n):
    shuffle(combined)
    new_diff = mean(combined[:len(drug)]) - mean(combined[len(drug):])
    count += (new_diff >= observed_diff)

print(f'{n} label reshufflings produced only {count} instances with a difference')
print(f'at least as extreme as the observed difference of {observed_diff:.1f}.')
print(f'The one-sided p-value of {count / n:.4f} leads us to reject the null')
print(f'hypothesis that there is no difference between the drug and the placebo.')
```

多服务器队列的到达时间和服务交付模拟:

```python
from heapq import heappush, heappop
from random import expovariate, gauss
from statistics import mean, median, stdev

average_arrival_interval = 5.6
average_service_time = 15.0
stdev_service_time = 3.5
num_servers = 3

waits = []
arrival_time = 0.0
servers = [0.0] * num_servers  # time when each server becomes available
for i in range(100_000):
    arrival_time += expovariate(1.0 / average_arrival_interval)
    next_server_available = heappop(servers)
    wait = max(0.0, next_server_available - arrival_time)
    waits.append(wait)
    service_duration = gauss(average_service_time, stdev_service_time)
    service_completed = arrival_time + wait + service_duration
    heappush(servers, service_completed)

print(f'Mean wait: {mean(waits):.1f}.  Stdev wait: {stdev(waits):.1f}.')
print(f'Median wait: {median(waits):.1f}.  Max wait: {max(waits):.1f}.')
```

------------------------------------------------

[英文官方文档](https://docs.python.org/3.8/library/random.html)

[中文官方文档](https://docs.python.org/zh-cn/3.8/library/random.html)