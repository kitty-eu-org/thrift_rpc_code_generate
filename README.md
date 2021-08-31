### Prerequisites
On Unix (Linux, OS X)
  - Install CMake
  - Install flex and bison
  - A compiler with C++11 support
  - CMake >= 3.4 or Pip 10+
  - Ninja or Pip 10+ 

On Windows
  - Visual Studio 2015 or newer (required for all Python versions, see notes below)
  - CMake >= 3.8 (3.8 was the first version to support VS 2015) or Pip 10+


### python install

- git clone https://github.com/hezhaozhao-git/thrift_rpc_code_generate.git
- cd  thrift_rpc_code_generate
- python setup.py install 

### use in your python code
```python
from thrift_code import generate_code
language = "py"
out_path = "./" # your rpc code output path
input_file_path = "./text1.thrift" # your .thrift file path
generate_code(language, input_file_path, out_path)
```

### reference
- [pybind11](https://github.com/pybind/pybind11)
- [thrift](https://github.com/apache/thrift)