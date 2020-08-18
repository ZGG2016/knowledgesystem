
$global_var = 10

class Class1
  def print_global()
    # $global_var += 1
    puts "Class1 中的全局变量为 #{$global_var}"
  end
end

#全局变量：可以跨类使用的变量，全局变量总是以美元符号（$）开始。
# 未初始化的全局变量的值为 nil，在使用 -w 选项后，会产生警告。
# 给全局变量赋值会改变全局状态，所以不建议使用全局变量。

class Class2
  def print_global()
    puts "Class2 中的全局变量为 #{$global_var}"
  end
end

Class1.new.print_global
Class2.new.print_global