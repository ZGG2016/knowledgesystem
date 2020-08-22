=begin
1.方法名应以小写字母开头。
2.方法应在调用之前定义

定义方法：
  无参
  def method_name
     expr..
  end

  有参
  def method_name (var1, var2)
     expr..
  end

  带初始值的有参
  def method_name (var1=value1, var2=value2)
     expr..
  end

  当您要调用方法时，只需要使用方法名即可，如下所示：
  method_name

  但是，当您调用带参数的方法时，您在写方法名时还要带上参数，例如：
  method_name 25, 30

=end

# def func1(v1=0,v2=1)
#   puts "#{v1+v2}"
# end
#
# func1 1,2

#每个方法默认都会返回一个值。这个返回的值是最后一个语句的值

# def func2
#   i = 1000
#   j = 100
#   k = 10
# end
# puts func2

=begin
return 语句用于从 Ruby 方法中返回一个或多个值。
语法
return [expr[`,' expr...]]

如果给出超过两个的表达式，包含这些值的数组将是返回值。如果未给出表达式，nil 将是返回值。
=end

# def test
#   i = 100
#   j = 200
#   k = 300
#   [i, j, k]  #return i, j, k
# end
# var = test
# puts var


#可变数量的参数

# def func3(*test)
#   puts "参数个数：#{test.length}"
#   (0...test.length).each do |i|
#     puts "#{test[i]}"
#   end
# end
#
# func3 "a","b","c","d"

=begin
类方法
当方法定义在类的外部，方法默认标记为 private。另一方面，如果方法定义在类中的，则默认标记为 public。
https://www.jianshu.com/p/ae6e78602586
=end

# class ClassMethod
#   def ClassMethod.sayhello(name)
#     puts "#{name} say hello"
#   end
# end
# ClassMethod.sayhello("Ruby")

=begin
alias为方法或全局变量起别名。别名不能在方法主体内定义。即使方法被重写，方法的别名也保持方法的当前定义。

为编号的全局变量（$1, $2,...）起别名是被禁止的。重写内置的全局变量可能会导致严重的问题。
语法
alias 方法名 方法名
alias 全局变量 全局变量
实例
alias foo bar
alias $MATCH $&

在这里，我们已经为 bar 定义了别名为 foo，为 $& 定义了别名为 $MATCH。


undef取消方法定义。undef 不能出现在方法主体内。

通过使用 undef 和 alias，类的接口可以从父类独立修改，但请注意，在自身内部方法调用时，它可能会破坏程序。
undef 方法名

=end