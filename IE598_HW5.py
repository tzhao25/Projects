import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
print("My name is Tianhao Zhao")
print("My NetID is: tzhao25")
print("I hereby certify that I have read the University policy on Academic Integrity and that I am not in violation.")
print(" ")
# data processing
df_wine = pd.read_csv('https://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data',header=None)
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
X, y = df_wine.iloc[:, 1:].values, df_wine.iloc[:, 0].values
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, stratify=y, random_state=42)
sc = StandardScaler()
X_train_std = sc.fit_transform(X_train)
X_test_std = sc.transform(X_test)

## Part 1 Exploratory Data Analysis 
print(df_wine.head())
print(df_wine.tail())
print(df_wine.describe())
print("# of rows：", df_wine.shape[0])
print("# of cols ", df_wine.shape[1])
plt.figure()
columns = df_wine.columns
sns.set(font_scale=1.5)
cm = np.corrcoef(df_wine[columns].values.T)
hm = sns.heatmap(cm,cbar=True,annot=True,square=True,fmt='.2f',annot_kws={'size': 5},yticklabels=columns,xticklabels=columns)
plt.xlabel("features")
plt.ylabel("features")
plt.figure(figsize=(60,30))
plt.show()

## Part 2 
from sklearn import metrics
## Logistic Regression
from sklearn.linear_model import LogisticRegression
lr = LogisticRegression()
lr.fit(X_train, y_train)
lr_y_train_pred = lr.predict(X_train)
print( "Part 2\n","Logistic Regression accurancy score for training: ",metrics.accuracy_score(y_train, lr_y_train_pred) )
lr_y_test_pred = lr.predict(X_test)
print( "Logistic Regression accurancy score for testing: ",metrics.accuracy_score(y_test, lr_y_test_pred) )

## SVM
from sklearn.svm import SVC
svm = SVC(kernel='linear', C=1.0, random_state=0)
svm.fit(X_train, y_train)
svm_train_predict = svm.predict(X_train)
svm_test_predict = svm.predict(X_test)
print("SVM Accuracy Score for Training: ", metrics.accuracy_score(y_train, svm_train_predict))
print("SVM Accuracy Score for Testing: ", metrics.accuracy_score(y_test, svm_test_predict))
print(" ")
## Part 3 PCA
from sklearn.decomposition import PCA
## Logistic Regression
from sklearn.linear_model import LogisticRegression
pca = PCA(n_components=2)
lr = LogisticRegression()
X_train_pca = pca.fit_transform(X_train_std)
X_test_pca = pca.transform(X_test_std)
lr.fit(X_train_pca, y_train)
lr_y_train_pred = lr.predict(X_train_pca)
print( "Part 3\n", "With PCA, Logistic Regression accurancy score for training: ",metrics.accuracy_score(y_train, lr_y_train_pred) )
lr_y_test_pred = lr.predict(X_test_pca)
print( "With PCA, Logistic Regression accurancy score for testing: ",metrics.accuracy_score(y_test, lr_y_test_pred) )

## SVM
from sklearn.svm import SVC
svm = SVC(kernel='linear', C=1.0, random_state=0)
svm.fit(X_train_pca, y_train)
svm_train_predict = svm.predict(X_train_pca)
svm_test_predict = svm.predict(X_test_pca)
print("With PCA, SVM Accuracy Score for Training: ", metrics.accuracy_score(y_train, svm_train_predict))
print("With PCA, SVM Accuracy Score for Testing: ", metrics.accuracy_score(y_test, svm_test_predict))
print(" ")

## Part 4 LDA
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as lda
lda = lda(n_components=2)
X_train_lda = lda.fit_transform(X_train_std, y_train)
X_test_lda = lda.transform(X_test_std)

## Logistic Regression
from sklearn.linear_model import LogisticRegression
lr = LogisticRegression()
lr.fit(X_train_lda, y_train)
lr_y_train_pred = lr.predict(X_train_lda)
print( "Part 4\n", "With LDA, Logistic Regression accurancy score for training: ",metrics.accuracy_score(y_train, lr_y_train_pred) )
lr_y_test_pred = lr.predict(X_test_lda)
print( "With LDA, Logistic Regression accurancy score for testing: ",metrics.accuracy_score(y_test, lr_y_test_pred) )
## SVM
from sklearn.svm import SVC
svm = SVC(kernel='linear', C=1.0, random_state=0)
svm.fit(X_train_lda, y_train)
svm_train_predict = svm.predict(X_train_lda)
svm_test_predict = svm.predict(X_test_lda)
print("Part 4\n", "With LDA, SVM Accuracy Score for Training: ", metrics.accuracy_score(y_train, svm_train_predict))
print("With LDA, SVM Accuracy Score for Testing: ", metrics.accuracy_score(y_test, svm_test_predict))
print(" ")

## Part 5 kPCA
from sklearn.decomposition import KernelPCA
gamma_space = np.linspace(0.01,1, endpoint = True)
lr_train_score=[]
lr_test_score=[]
svm_train_score=[]
svm_test_score=[]
## Logistic Regression
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
gamma_range = np.linspace(0.01,1, num=50)
for gamma in gamma_range:
    scikit_kpca.gamma = gamma
    X_train_skernpca = scikit_kpca.gamma.fit_transform(X_train_std, y_train)
    X_test_skernpca= scikit_kpca.gamma.transform(X_test_std)

    lr = LogisticRegression()
    lr.fit(X_train_skernpca, y_train)
    kpca_lr_y_train_pred = lr.predict(X_train_skernpca)
    kpca_lr_y_pred = lr.predict(X_test_skernpca)
    lr_train_score.append(metrics.accuracy_score(y_train, kpca_lr_y_train_pred))
    lr_test_score.append(metrics.accuracy_score(y_test, kpca_lr_y_pred))

    svm = SVC(kernel = 'rbf', C= 1.0, random_state= 1)
    svm.fit(X_train_skernpca, y_train)
    kpca_svm_y_train_pred = svm.predict(X_train_skernpca)
    kpca_svm_y_pred = svm.predict(X_test_skernpca)
    svm_train_score.append(metrics.accuracy_score(y_train, kpca_svm_y_train_pred))
    svm_test_score.append(metrics.accuracy_score(y_test, kpca_svm_y_pred))
##print( "Part 5\n", "With kPCA, Logistic Regression accurancy score for training: ", lr_train_score)
##print( "With kPCA, Logistic Regression accurancy score for testing: ", lr_test_score)

##print("With kPCA, SVM Accuracy Score for Training: ", svm_train_score)
##print("With kPCA, SVM Accuracy Score for Testing: ", svm_test_score)
import sys
from astropy.table import Table
t1 = Table([gamma_range, lr_train_score, lr_test_score], names = ('gamma','Logistic Regression train score','Logistic Regression test score'))
t2 = Table([gamma_range, svm_train_score, svm_test_score], names = ('gamma','SVM train score','SVM test score'))
print(t1)
print(t2)
## plot
plt.figure()
plt.plot(gamma_range, lr_train_score, color = 'red', label='Training')
plt.plot(gamma_range, lr_test_score, color = 'black', label='Testing')
plt.legend()
plt.xlabel("Gamma")
plt.ylabel("Accuracy Scores")
plt.title("Logistic Regression with KPCA")

plt.figure()
plt.plot(gamma_range, svm_train_score, color = 'red', label='Training')
plt.plot(gamma_range, svm_test_score, color = 'black', label='Testing')
plt.legend()
plt.xlabel("Gamma")
plt.ylabel("Accuracy Scores")
plt.title("SVM with KPCA")













