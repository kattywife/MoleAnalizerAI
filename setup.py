from setuptools import setup, find_packages

setup(
    name="skinsight",
    version="1.0.0",
    packages=find_packages(),
    install_requires=[
        'PySide6>=6.0.0',
        'tensorflow>=2.7.0',
        'Pillow>=9.0.0',
        'numpy>=1.19.2',
        'mysql-connector-python>=8.0.0',
    ],
    extras_require={
        'dev': [
            'pytest>=7.0.0',
            'pytest-cov>=3.0.0',
            'pytest-qt>=4.2.0',
            'pytest-xvfb>=2.0.0',
            'black>=22.0.0',
            'isort>=5.10.0',
            'flake8>=4.0.0',
            'mypy>=0.950',
            'sphinx>=4.5.0',
            'sphinx-rtd-theme>=1.0.0',
        ]
    },
    python_requires='>=3.7',
    include_package_data=True,
    package_data={
        'skinsight': [
            'frontend/qmldir',
            'frontend/components/qmldir',
            'frontend/screens/qmldir',
            'frontend/**/*.qml',
            'frontend/assets/images/*',
        ],
    },
    entry_points={
        'console_scripts': [
            'skinsight=skinsight.main:main',
        ],
    },
    author='SkinSight Team',
    description='A melanoma detection and analysis application',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Healthcare Industry',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
    ],
)