from setuptools import setup, find_packages
import os

def read_readme():
    with open(os.path.join(os.path.dirname(__file__), "README.md"), encoding="utf-8") as f:
        return f.read()

setup(
    name="ramanujan-qft",
    version="0.1.0",
    author="Reet",
    description="Ramanujan Algorithm Framework (RAF) for Multi-Loop Feynman Integrals",
    long_description=read_readme(),
    long_description_content_type="text/markdown",
    url="https://github.com/reetanshuh1998/Ramanujan_master_theorem",
    license="MIT",
    packages=find_packages(),
    install_requires=[
        "mpmath>=1.3.0",
        "sympy>=1.12",
        "numpy>=1.24.0",
        "scipy>=1.10.0",
        "matplotlib>=3.7.0"
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Topic :: Scientific/Engineering :: Physics",
    ],
    python_requires=">=3.8",
)
