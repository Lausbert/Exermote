from setuptools import setup, find_packages

setup(name='trainer',
      version='0.1',
      packages=find_packages(),
      description='example to run keras on gcloud ml-engine',
      author='Fuyang Liu',
      author_email='fuyang.liu@example.com',
      license='MIT',
      install_requires=[
          'keras==1.2.2',
          'h5py',
          'pandas',
          'coremltools'
      ],
      zip_safe=False)