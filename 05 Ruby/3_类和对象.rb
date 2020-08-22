class Customer
  @@no_of_customers = 0

  def initialize(id, name, addr)
    @cust_id = id
    @cust_name = name
    @cust_addr = addr
  end

  def display_detail()
    puts "customer id #{@cust_id}"
    puts "customer name #{@cust_name}"
    puts "customer addr #{@cust_addr}"
  end

  def total_no_of_customer()
    @@no_of_customers += 1
    puts "Total number of customers: #@@no_of_customers"
  end
end

cust1 = Customer.new("1", "mike", "sdut")
cust1.display_detail
cust1.total_no_of_customer

cust2 = Customer.new("2", "tom", "sdut")
cust2.display_detail
cust2.total_no_of_customer

#=================================================================================================
# 在 Ruby 中，类总是以关键字 class 开始，后跟类的名称。类名的首字母应该大写。类 Customer 如下所示：
# class Customer
# end
# 您可以使用关键字 end 终止一个类。
#=================================================================================================
# 四种类型的变量：
#
# 局部变量：局部变量是在方法中定义的变量。局部变量在方法外是不可用的。局部变量以小写字母或 _ 开始。
#           当调用一个未初始化的局部变量时，它被解释为调用一个不带参数的方法。
# 实例变量：实例变量可以跨任何特定的实例或对象中的方法使用。
#           这意味着，实例变量可以从对象到对象的改变。实例变量在变量名之前放置符号（@）。
#           未初始化的实例变量的值为 nil
# 类变量：类变量可以跨不同的对象使用。类变量属于类，且是类的一个属性,不能跨类使用。
#         类变量在变量名之前放置符号（@@）。引用一个未初始化的类变量会产生错误。
#         类变量在定义它的类或模块的子类或子模块中可共享使用。
# 全局变量：可以跨类使用的变量，全局变量总是以美元符号（$）开始。
#=================================================================================================
# 使用类的方法 new 创建对象。
# 方法 new 是一种独特的方法，在 Ruby 库中预定义。new 方法属于类方法。
#
# 想要声明带参数的 new 方法时，您需要在创建类的同时声明方法 initialize。
# initialize 方法是一种特殊类型的方法，将在调用带参数的类的 new 方法时执行
#=================================================================================================
# 类中的每个方法是以关键字 def 开始，后跟方法名。
# 方法名总是以小写字母开头。在 Ruby 中，您可以使用关键字 end 来结束一个方法。