# tesseract安装


1、下载

https://github.com/tesseract-ocr/tessdoc

2、将可执行文件路径添加到Path

3、安装pytesseract

直接使用pip install pytesseract

4、测试

```python
import pytesseract
from PIL import Image

img = Image.open("tesseracttest.jpg")
img_s = pytesseract.image_to_string(img)
print(img_s)


This is some text, written in Arial, that will be read by
Tesseract. Here are some symbols: !@#$%"&*()
```
