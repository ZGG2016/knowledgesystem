puts "hello world"

# 源代码文件中，若包含中文编码，则需要注意两点：
# 1. 必须在首行添加 # -*- coding: UTF-8 -*-,告诉解释器使用utf-8来解析源码。
# 2. 必须设置编辑器保存文件的编码为utf-8。

puts "你好 世界"

# 在 Ruby 代码中的空白字符，如空格和制表符一般会被忽略，除非当它们出现在字符串中时才不会被忽略。
# 然而，有时候它们用于解释模棱两可的语句。当启用 -w 选项时，这种解释会产生警告。

# 把分号和换行符解释为语句的结尾。但是，如果 Ruby 在行尾遇到运算符，比如 +、- 或反斜杠，它们表示一个语句的延续。
a = 1 +
    2
puts a

# Ruby 标识符的名称可以包含字母、数字和下划线字符（ _ ）。大小写敏感的

# "Here Document" 是指建立多行字符串。在 << 之后，您可以指定一个字符串或标识符来终止字符串，
# 且当前行之后直到终止符为止的所有行是字符串的值。
# 如果终止符用引号括起，引号的类型决定了面向行的字符串类型。请注意<< 和终止符之间必须没有空格。

print <<EOF
test,test,test
EOF

print <<"EOF"
test,test,test
EOF

#执行命令
print <<`EOF`
echo test,test,test
EOF

print <<"A",<<"B"
test
A
test,test
B

## puts print 都是向控制台打印字符，其中puts带回车换行符

# BEGIN {
#   code
# }
# 声明 code 会在程序运行之前被调用

BEGIN{
  puts "learn ruby"
}

# END {
#   code
# }
# 声明 code 会在程序的结尾被调用。

END{
  puts "part-1 finished"  # this is annotation
}

# 这种块注释会对解释器隐藏 =begin/=end 之间的行：
# =begin
# 这是注释。
# 这也是注释。
# 这也是注释。
# 这还是注释。
# =end
