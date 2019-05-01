#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Oct 14 14:58:18 2018

@author: tianhaozhao
"""
print("My name is Tianhao Zhao")
print("My NetID is: tzhao25")
print("I hereby certify that I have read the University policy on Academic Integrity and that I am not in violation.")
print('')
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn import metrics
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import time
df_wine = pd.read_csv('https://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data', header=None)
df_wine.columns = ['Class label', 'Alcohol','Malic acid', 'Ash','Alcalinity of ash', 'Magnesium','Total phenols', 'Flavanoids','Nonflavanoid phenols','Proanthocyanins','Color intensity', 'Hue','OD280/OD315 of diluted wines','Proline']

X, y = df_wine.iloc[:, 1:].values, df_wine.iloc[:, 0].values
X_train, X_test, y_train, y_test =train_test_split(X, y,test_size=0.1,random_state=42,stratify=y)
feat_labels = df_wine.columns[1:]
n_space = np.linspace(5,45,9,dtype = int)
accu_score = []
for n in n_space:
    time_start = time.time()
    forest = RandomForestClassifier(n_estimators=n,random_state=1, n_jobs=1)
    forest.fit(X_train, y_train)
    forest.n_estimators = n
    y_pred = forest.predict(X_train)
    computation_time = (time.time() - time_start)
    accu_score.append(metrics.accuracy_score(y_train, y_pred))
    print('Computation time for n = %2d is: %.9f' % (n, computation_time))
plt.scatter(n_space, accu_score, label='Random Forest Training Set')
plt.legend(loc = 'best')
plt.xlabel("N_estimator Values")
plt.ylabel("Accuracy Scores")
plt.xticks(n_space)
plt.title("In-sample Accuracy VS. N_estimator Values")
plt.show()
print("Accuracy scores are: ", accu_score)
#Part2
feat_labels = df_wine.columns[1:]
forest = RandomForestClassifier(n_estimators=25,random_state=1)
forest.fit(X_train, y_train)
importances = forest.feature_importances_
indices = np.argsort(importances)[::-1]
for f in range(X_train.shape[1]):
    print("%2d) %-*s %f" % (f + 1, 30,feat_labels[indices[f]],importances[indices[f]]))
plt.title('Feature Importance')
plt.bar(range(X_train.shape[1]),importances[indices],align='center')
plt.xticks(range(X_train.shape[1]),feat_labels, rotation=90)
plt.xlim([-1, X_train.shape[1]])
from sklearn.model_selection import StratifiedKFold
kfold = StratifiedKFold(n_splits=10,random_state=1).split(X_train,y_train)
scores = []
for k, (train, test) in enumerate(kfold):
    forest.fit(X_train[train], y_train[train])
    score = forest.score(X_train[test], y_train[test])
    scores.append(score)
    print('Fold: %2d, Class dist.: %s, Acc: %.3f' % (k+1,np.bincount(y_train[train]), score))
