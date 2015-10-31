#Misc

These are just miscellaneous scripts that I've written to automate basic functions such as compilation or string creation when shellcoding. Enjoy.

###compile
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This will simply take a **.asm** file as a parameter. You can append "64" to compile it for x64.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*./compile program.asm 64*

###opcoder
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This will use objdump (binutils) and format the output to be in \x format. Use '**-q**' to omit the objdump output.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*./opcoder a.out*

###shellstring.py
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Simple python script to create strings on the stack. Append "64" for 64-bit shellcode. Uses r8/r9 registers.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*./shellstring.py "/bin/bash" 64*
