#在方法名称前加上类或模块名称和 . 来调用类或模块中的方法。

# MC_COUNT = 0
# module Foo
#   ::MC_COUNT = 1
#   MC_COUNT = 2
# end
#
#
# puts MC_COUNT       # 1  :: 是一元运算符，允许在类或模块内定义常量、实例方法和类方法，
#                     # 可以从类或模块外的任何地方进行访问。
# puts Foo::MC_COUNT  # 2  用类或模块名称和两个冒号 :: 来引用类或模块中的常量

#==================================================================================
#在 Ruby 中，类和方法也可以被当作常量。

CONST = ' out there'
class Inside_one
  CONST = proc {' in there'}  #？？？？？
  def foo
    ::CONST + ' inside one'
  end
end
class Inside_two
  CONST = ' inside two'
  def foo
    CONST
  end
end
puts Inside_one.new.foo
puts Inside_two.new.foo
#如果 :: 前的表达式为类或模块名称，则返回该类或模块内对应的常量值
puts Object::CONST + Inside_two::CONST
# 如果 :: 前未没有前缀表达式，则返回主Object类中对应的常量值
puts Inside_two::CONST + CONST
puts Inside_one::CONST
puts Inside_one::CONST.call + Inside_two::CONST # ？？？？？
