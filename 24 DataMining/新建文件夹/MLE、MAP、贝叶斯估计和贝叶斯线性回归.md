# MLE、MAP、贝叶斯估计和贝叶斯线性回归

## 极大似然估计(MLE)

目的：利用已知的样本结果，反推最有可能（最大概率）导致这样结果的参数值。

原理：极大似然估计是建立在极大似然原理的基础上的一个统计方法，是概率论在统计学中的应用。极大似然估计提供了一种给定观察数据来评估模型参数的方法，即：“模型已定，参数未知”。通过若干次试验，观察其结果，利用试验结果得到某个参数值能够使样本出现的概率为最大，则称为极大似然估计。

由于样本集中的样本都是独立同分布，可以只考虑一类样本集D，来估计参数向量θ。记已知的样本集为：

![](https://i.imgur.com/fmhHvr6.jpg)

似然函数（linkehood function）：联合概率密度函数p(D|θ)称为相对于D的θ的似然函数。

![](https://i.imgur.com/XZWZ6lO.jpg)

![](https://i.imgur.com/gmRUiWm.jpg)

![](https://i.imgur.com/akXo6DU.jpg)

![](https://i.imgur.com/0e3Xmlb.jpg)

方程的解只是一个估计值，只有在样本数趋于无限多的时候，它才会接近于真实值。

	https://blog.csdn.net/zengxiantao1994/article/details/72787849

## 最大后验概率估计(MAP)

![](https://i.imgur.com/eUzWqod.jpg)

![](https://i.imgur.com/hvyKcGM.jpg)

## 贝叶斯估计 

https://blog.csdn.net/daunxx/article/details/51725086
https://blog.csdn.net/zengxiantao1994/article/details/72889732

##  贝叶斯线性回归