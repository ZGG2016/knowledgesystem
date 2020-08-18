# 常量以大写字母开头。定义在类或模块内的常量可以从类或模块的内部访问，
# 定义在类或模块外的常量可以被全局访问。
# 常量不能定义在方法内==>报错

class Class1
  ABCD = 10

  def function()
    # QWER = 10
    puts "ABCD is #{ABCD}"
    puts "#{__FILE__ }"
  end
end

Class1.new.function

# 它们是特殊的变量，有着局部变量的外观，但行为却像常量。您不能给这些变量赋任何值。
#
# self: 当前方法的接收器对象。
# true: 代表 true 的值。
# false: 代表 false 的值。
# nil: 代表 undefined 的值。
# __FILE__: 当前源文件的名称。
# __LINE__: 当前行在源文件中的编号。
