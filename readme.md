# JOS

北京大学操作系统实习（实验班）作业

# 环境配置

Ubuntu 18.04 64位 (使用WSL)

sudo apt-get install qemu

sudo apt-get install gcc-multilib

在JOS目录下，输入make qemu，如果正常运行，说明环境配置成功

# lab 1

kern/kdebug.c：找到指令所在的语句是函数的第几行

kern/monitor.c：输出调用栈的信息

Challenge:

​	lib/printfmt.c：输出八进制，并尝试修改输出字体的颜色

# lab 2

kern/pmap.c：模拟物理内存的分配、释放；虚拟内存的寻址、查询；内存空间的映射

Challenge：

​	kern/monitor.c