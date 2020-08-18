=begin

for variable [, variable ...] in expression [do]
   code
end

先计算表达式得到一个对象，然后针对 expression 中的每个元素分别执行一次 code。
=end

# for i in 1..5
#   puts "#{i}"
# end

=begin

for...in 循环几乎是完全等价于：
(expression).each do |variable[, variable...]| code end

但是，for 循环不会为局部变量创建一个新的作用域。

语法中 do 可以省略不写。但若要在一行内写出 for 式，则必须以 do 隔开条件式或程式区块
=end

# (1..5).each do |i|
#   puts "#{i}"
# end

=begin
while conditional [do]
code
end
==============================
语法
while conditional [:]
code
end

当 conditional 为真时，执行 code。

语法中 do 或 : 可以省略不写。但若要在一行内写出 while 式，则必须以 do 或 : 隔开条件式或程式区块。
=end

# $i = 0
# $j = 5
# while $i<$j do
#   puts $i
#   $i +=1
# end

=begin

code while condition
=================================

begin
  code
end while conditional

当 conditional 为真时，执行 code。

如果 while 修饰符跟在一个没有 rescue 或 ensure 子句的 begin 语句后面，
code 会在 conditional 判断之前执行一次。

=end

# begin
#   puts $i
#   $i +=1
# end while $i<$j

=begin

until conditional [do]
   code
end

当 conditional 为假时，执行 code。

语法中 do 可以省略不写。但若要在一行内写出 until 式，则必须以 do 隔开条件式或程式区块。
=end

# until $i>$j
#   puts $i
#   $i +=1
# end

=begin

code until conditional
==================================

begin
   code
end until conditional

当 conditional 为 false 时，执行 code。

如果 until 修饰符跟在一个没有 rescue 或 ensure 子句的 begin 语句后面，
code 会在 conditional 判断之前执行一次。

=end

# begin
#   puts $i
#   $i +=1
# end until $i>$j

=begin

break
终止最内部的循环。如果在块内调用，则终止相关块的方法（方法返回 nil）。

next
跳到循环的下一个迭代。如果在块内调用，则终止块的执行（yield 表达式返回 nil）。
=end

# for i in 1..5
#   if i>3
#     break
#   else
#     puts "#{i}"
#   end
# end
# for i in 1..5
#   if i<3
#     next
#   else
#     puts "#{i}"
#   end
# end

=begin

redo
重新开始最内部循环的该次迭代，不检查循环条件。如果在块内调用，则重新开始 yield 或 call。
=end

for i in 1..5
  if i<3
    puts "#{i}"
    redo
  end
end
