#! /usr/bin/env python

# This file can build and install cmf


# Change these pathes to your sundials 2.4+ installation
sundials_lib_path = r"D:\Code\sundials-2.4.0\inst_msvc\lib"
sundials_include_path = r"D:\Code\sundials-2.4.0\inst_msvc\include"

# Change this path to your boost installation (not needed for gcc)
boost_path = r"D:\Code\boost_1_41_0"

# Change these variables to match your compiler. (gcc or 
# For Visual Studio 2008 no action is needed
gcc = 0
msvc = 1


# No user action required beyond this point
import os

from distutils.core import setup,Extension

def make_cmf_core():
    library_dirs=[sundials_lib_path]
    include_dirs=[sundials_include_path]
    include_dirs += [boost_path,boost_path+r"\boost\tr1"]
    if msvc: compile_args = ["/openmp","/EHsc"]
    if gcc: compile_args = ["-std=gnu++98","-fopenmp","-w"]
    libraries=["sundials_cvode","sundials_nvecserial"]
    cmf_files=[]
    for root,dirs,files in os.walk('.'):
        cmf_files.extend(os.path.join(root,f) for f in files if f.endswith('.cpp'))
    print "Compiling %i source files" % (len(cmf_files)+1)
    cmf_files.append("cmf/cmf_core_src/cmf_wrap.cxx")
    cmf_core = Extension('cmf._cmf_core',
                            sources=cmf_files,
                            library_dirs=library_dirs,
                            libraries = libraries,
                            include_dirs=include_dirs,
                            extra_compile_args=compile_args,
                        )
    return cmf_core
def make_raster():
    files=[r'cmf\raster\raster_src\raster_wrap.cxx']
    if msvc: compile_args = ["/openmp","/EHsc"]
    if gcc: compile_args = ["-std=gnu++98","-fopenmp","-w"]
    raster = Extension('cmf.raster._raster',
                        sources=files,
                        extra_compile_args=compile_args,
                    )
    return raster
if __name__=='__main__':
    ext = [make_raster(),make_cmf_core()]
    author = "Philipp Kraft"
    author_email = "philipp.kraft@umwelt.uni-giessen.de"
    url = "www.uni-giessen.de/ilr/frede/cmf"
    py=[]
    for root,dirs,files in os.walk('cmf'):
        py.extend(os.path.join(root,f[:-3]).replace('\\','.') for f in files if f.endswith('.py'))
    
    
    setup(name='cmf',
          version='0.1',
          license='GPL',
          ext_modules=ext,
          py_modules=py, 
          requires=['shapely (>=1.0)'],
          data_files=[('help',['cmf.chm'])])
    
    print "build ok"
