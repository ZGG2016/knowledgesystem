=begin

if conditional [then]
      code...
[elsif conditional [then]
      code...]...
[else
      code...]
end

通常我们省略保留字 then 。若想在一行内写出完整的 if 式，则必须以 then 隔开条件式和程式区块。如下所示:
if a == 4 then a = 7 end

=end

x = 6
if x>=10
  puts "x>10"
elsif x>5 and x<10
  puts "5<x<10"
else
  puts "其他"
end

=begin

code if condition

if修饰词组表示当 if 右边之条件成立时才执行 if 左边的式子。即如果 conditional 为真，则执行 code。
=end

puts x if x>5 and x<10

=begin

unless conditional [then]
   code
[else
   code ]
end

unless式和 if式作用相反，即如果 conditional 为假，则执行 code。
如果 conditional 为真，则执行 else 子句中指定的 code。
=end

unless x>5
  puts "随便"
 else
  puts x
end

=begin

code unless conditional

如果 conditional 为假，则执行 code。
=end

puts x unless x<4

=begin

case expr0
when expr1, expr2
   stmt1
when expr3, expr4
   stmt2
else
   stmt3
end

==>

基本上类似于：
_tmp = expr0
if expr1 === _tmp || expr2 === _tmp
   stmt1
elsif expr3 === _tmp || expr4 === _tmp
   stmt2
else
   stmt3
end


若想在一行内写出完整的 when 式，则必须以 then 隔开条件式和程式区块。如下所示:
when a == 4 then a = 7 end

=end

$age =  5
case $age
when 0 .. 2
  puts "婴儿"
when 3 .. 6
  puts "小孩"
when 7 .. 12
  puts "child"
when 13 .. 18
  puts "少年"
else
  puts "其他年龄段的"
end

# 当case的"表达式"部分被省略时，将计算第一个when条件部分为真的表达式。
foo = false
bar = true
quu = false

case
when foo then puts 'foo is true'
when bar then puts 'bar is true'
when quu then puts 'quu is true'
else puts 'whatever'
end
# 显示 "bar is true"