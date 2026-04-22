from setuptools import setup, find_packages

setup(
    name="ramanujan-qft",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "mpmath",
        "sympy",
        "numpy",
    ],
    author="Antigravity AI",
    description="A high-performance analytic QFT library based on the Ramanujan Algorithm Framework and DL-MoB.",
    python_requires=">=3.7",
)
