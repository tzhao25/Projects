# -*- coding: utf-8 -*-
"""
Created on Sat Sep  8 16:10:09 2018

@author: zhth1202
""" 

print("My name is Tianhao Zhao")
print("My NetID is: tzhao25")
print("I hereby certify that I have read the University policy on Academic Integrity and that I am not in violation.")
print('')

# Decision Tree
from sklearn import datasets
iris = datasets.load_iris()
X_iris, y_iris = iris.data, iris.target
from sklearn.tree import DecisionTreeClassifier
from sklearn.cross_validation import train_test_split
from sklearn import preprocessing
from sklearn.metrics import accuracy_score
import numpy as np
import matplotlib.pyplot as plt
import sklearn
from matplotlib.colors import ListedColormap
print( 'The scikit learn version is {}.'.format(sklearn.__version__))

## Part1
X, y = X_iris, y_iris
randomstate = np.arange(1, 11, 1)
in_sample = []
out_sample = []

for k in randomstate:
    X_train, X_test, y_train, y_test = train_test_split(X, y,test_size=0.1, random_state=k)

    scaler = preprocessing.StandardScaler().fit(X_train)
    dt = DecisionTreeClassifier(max_depth = 6, criterion = 'gini', random_state = 1)
    dt.fit(X_train, y_train)
    y_pred_out = dt.predict(X_test)
    y_pred_in = dt.predict(X_train)
    out_sample_score = accuracy_score(y_test, y_pred_out)
    in_sample_score = accuracy_score(y_train, y_pred_in)
    in_sample.append(in_sample_score)
    out_sample.append(out_sample_score)
    print('Random State: %d, in_sample: %.3f, out_sample: %.3f'%(k, in_sample_score,out_sample_score))

plt.scatter(randomstate, in_sample, c='red', label = 'In Sample')
plt.scatter(randomstate, out_sample, c='black', label = 'Out Sample')
plt.title('Random State vs in_sample and out_sample Accuracy')
plt.xlabel('Random State')
plt.ylabel('Accuracy')
plt.legend(loc = 'lower left')
plt.show()
mean_in = np.mean(in_sample)
mean_out = np.mean(out_sample)
std_in = np.std(in_sample)
std_out = np.std(out_sample)
print('In sample Mean: %.3f, Out sample Mean: %.3f \nIn sample STD: %.3f, Out sample STD: %.3f'%(mean_in, mean_out, std_in, std_out))
print('')

## Part2
from sklearn.model_selection import cross_val_score



cv_scores = cross_val_score(dt, X_train, y_train, cv = 10)
print('CV Scores: ', cv_scores)
print("mean of cv score: {:.6f}".format(np.mean(cv_scores)))
print("variance of cv score: {:.6f}".format(np.var(cv_scores)))
y_pred = dt.predict(X_test)
out_sample_score_CV= accuracy_score(y_test, y_pred) 
print("out sample CV accuracy: {:.6f}".format(out_sample_score_CV))













