from setuptools import setup, find_packages

setup(name='trainer',
      version='0.1',
      packages=find_packages(),
      description='exermotesgan',
      install_requires=[
          'keras==2.1.3',
          'pandas',
          'matplotlib'
      ],
      zip_safe=False)