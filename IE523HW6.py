#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 24 21:53:48 2018

@author: tianhaozhao
"""
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

# data processing
data = pd.read_csv('/Users/tianhaozhao/Desktop/IE523_HW6_data.csv')
data.columns = ['GA5', 'GA10', 'GA15', 'GA', 'GO5', 'GO10', 'GO15', 'GO', 'MA5', 'MA10', 'MA15', 'MA', 'MS5', 'MS10', 'MS15', 'MS', 'aa']
cols = data.columns

plt.figure(figsize=(12,10))
for i in data.columns[0:4]:
    plt.plot(data['aa'], data[i])
    plt.title('GOOGLE_AUG23_2017')
    plt.legend(['5 term','10 term','15 term','Orignial'],loc = 'best')
plt.show()
plt.figure(figsize=(12,10))
for i in data.columns[4:8]:
    plt.plot(data['aa'], data[i])
    plt.title('GOOGLE_OCT13_2017')
    plt.legend(['5 term','10 term','15 term','Orignial'],loc = 'best')
plt.show()
plt.figure(figsize=(12,10))
for i in data.columns[8:12]:
    plt.plot(data['aa'], data[i])
    plt.title('MSFT_AUG23_2017')
    plt.legend(['5 term','10 term','15 term','Orignial'],loc = 'best')
plt.show()
plt.figure(figsize=(12,10))
for i in data.columns[12:16]:
    plt.plot(data['aa'], data[i])
    plt.title('MSFT_Sept_20_2016')
    plt.legend(['5 term','10 term','15 term','Orignial'],loc = 'best')  
plt.show()
