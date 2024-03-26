# @changwei/chardet

Chardet 是一个检测文本编码的库，移植自npm两千多万下载量的同名包。

- 非常轻量
- 性能优秀
- 无外部依赖
- 纯TS/ArkTS编写

## 安装

```
ohpm install @changwei/chardet
```

## 使用

返回最可能的字符编码

```typescript
import * as chardet from '@changwei/chardet';
import fs from '@ohos.file.fs'

let file=fs.openSync('/path/to/file',fs.OpenMode.READ_ONLY);
let arrayBuffer=new ArrayBuffer(1024);//读取文本文件内容
let readLen = fs.readSync(file.fd, arrayBuffer,{
    offset: 0,
    length: arrayBuffer.length
});
//提取前512个字节内容以提高性能，长文本建议这样做
let charset = chardet.detect(new Uint8Array(arrayBuffer, 0, 512));
// or
const encoding = await chardet.detectFile('/path/to/file');
// or
const encoding = chardet.detectFileSync('/path/to/file');
```

使用`analyse`方法分析所有字符编码的可能性，结果返回列表

```typescript
chardet.analyse(new Uint8Array(arrayBuffer, 0, 512));
```

返回值格式如下：
```typescript
[
  { confidence: 90, name: 'UTF-8' },
  { confidence: 20, name: 'windows-1252', lang: 'fr' },
];
```

## 支持的字符编码:

- UTF-8
- UTF-16 LE
- UTF-16 BE
- UTF-32 LE
- UTF-32 BE
- ISO-2022-JP
- ISO-2022-KR
- ISO-2022-CN
- Shift_JIS
- Big5
- EUC-JP
- EUC-KR
- GB18030
- ISO-8859-1
- ISO-8859-2
- ISO-8859-5
- ISO-8859-6
- ISO-8859-7
- ISO-8859-8
- ISO-8859-9
- windows-1250
- windows-1251
- windows-1252
- windows-1253
- windows-1254
- windows-1255
- windows-1256
- KOI8-R

目前支持以上编码，注意gb18030兼容gbk和gb2312.


### 引用项目

- node-chardet https://github.com/runk/node-chardet

## 开源协议

本项目基于 [MIT](https://gitee.com/openharmony-sig/axios/blob/master/LICENSE) ，请自由地享受和参与开源。

## 联系我

B站 @[Changwei同学](https://space.bilibili.com/395257724)

抖音/西瓜 @梦断代码

**求点赞 求关注 求分享**

