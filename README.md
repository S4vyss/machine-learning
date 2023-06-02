# machine-learning
A collective of my machine learning lessons done while going along with [Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow](https://www.oreilly.com/library/view/hands-on-machine-learning/9781492032632/)

## Jupyter Notebook
I am using jupyter notebook to follow along with exercises and project provided in this book (it was recommended by author to use jupyter)

### Opening the notebook locally on windows:
To open the notebook locally on windows follow these steps

1. First
Clone the repo into a directory
```
mkdir book
cd book
git clone https://github.com/S4vyss/machine-learning.git
```
2. Second
I recommend you to setup isolated environment with virtualenv,
it's a pip package you can read more about it [here](https://pypi.org/project/virtualenv/)

You install it like that:
``python -m pip install --user virtualenv``

Then create an environment 
``python -m virtualenv venv``

After that everytime you want to open that environment you need to type in that command:
`` .\venv\Scripts\activate``
And that command to deactivate:
``deactivate``

3. Third
Install jupyter-lab [Read more here](https://jupyter.org/install)

``pip install jupyterlab``

And then open the jupyterlab
``jupyter-lab``

**Troubleshooting**

I you are using powershell to execute those commands there might be problem if your **ExecutionPolicy** is set to Restricted
to resolve that problem open PowerShell as an administrator then run this command to check the ExecutionPolicy
``Get-ExecutionPolic``

if it's set to Restricted then run this command
``Set-ExecutionPolicy RemoteSigned``

that will enable you to run local scripts, then you just need to run **.\venv\Scripts\activate** again.

*Note: That is the process that worked for me, if you can do it faster or better then post an issue so i can update this README*
