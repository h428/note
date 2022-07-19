
# 编译相关

- 编译: `xelatex.exe -synctex=1 -interaction=nonstopmode gougu.tex`
- 文献编译：`bibtex.exe gougu`，注意不加后缀名
- 普通tex编译一次（xelatex）
- 带交叉引用的tex需要编译两次（xelatex->xelatex）
- 带参考文献的tex需要编译四次（xelatex-bibtex->xelatex->xelatex），后两次就是处理交叉引用


# 代码如下：

```C++
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const int maxn = 1024;

// 删除多余文件 
void del(){
	//system("del *.");
	system("del *.log");
	system("del *.nav");
	system("del *.out");
	system("del *.aux");
	system("del *.gz");
	system("del *.bbl");
	system("del *.blg");
	system("del *.toc");
}

void openPDF(char* filename){
	strcat(filename, ".pdf");
	system(filename);
}

int main(int argc, char** argv)
{
	if (argc > 1){
		
//		for(int i = 0; i < argc; ++i){
//			printf("参数%d : %s\n", i, argv[i]);
//		}
//		
//		printf("\n");
		
		// 处理名称后缀 
		char filename[maxn];
		strcpy(filename, argv[1]);
		// 1. 判断最后一个.的位置，确定后缀
		char* idx = strrchr(filename, '.');
		// 2. 若有后缀，补0，删除文件后缀
		if (idx != NULL){
			*idx = 0;
		}
		// 3. 若本身无后缀，不做额外操作 

		// printf("文件名：%s\n", filename); 
		
		// 提前定义编译字符串 
		char xelatex_compile[maxn], bibtex_compile[maxn];
		strcpy(xelatex_compile, "xelatex.exe -synctex=1 -interaction=nonstopmode ");
		strcat(xelatex_compile, filename);
		strcpy(bibtex_compile, "bibtex.exe ");
		strcat(bibtex_compile, filename);
		
		// printf("%s\n", xelatex_compile);
		
		if(argc < 2){
			// 只有一个参数，参数不足，进行提示 
			printf("参数不足，至少两个参数！"); 
		} else if(argc < 3){
			// 只有两个参数，表示无检查引用，只编译一次 xelatex
			system(xelatex_compile);
			printf("编译普通的tex：%s.tex成功\n", filename);
			del(); 
			openPDF(filename);
		}else {
			// 三个参数 
			if (strcmp("ref", argv[2]) == 0){
				// 处理交叉引用类型，编译两次 xelatex -> xelatex
				system(xelatex_compile);
				system(xelatex_compile);
				printf("编译带交叉引用的tex：%s.tex成功\n", filename);
				del();
				openPDF(filename);
			}else if (strcmp("bib", argv[2]) == 0){
				// 处理论文类型，编译四次 xelatex -> bibtex -> xelatex -> xelatex
				system(xelatex_compile);
				system(bibtex_compile);
				system(xelatex_compile);
				system(xelatex_compile);
				printf("编译带参考文献的tex：%s.tex成功\n", filename);
				del();
				openPDF(filename);
			}else{
				printf("第三个参数有误！请检查输入！\n");
			}
		}
		
		
		
	}else{
		printf("No Parameters...End Program!\n");
	}
	
} 
```