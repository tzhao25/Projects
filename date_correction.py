# -*- coding: utf-8 -*-
"""
Created on Thu Jul 25 17:06:18 2019

@author: Jianxiong
"""

import pandas as pd
import numpy as np
names = locals()
address = '/Users/tianhaozhao/Desktop/factors/'
correct_date = pd.read_csv(address+'standard.csv')
correct_date = np.array(correct_date.iloc[:,0]).tolist()
correct_date = correct_date[correct_date.index(20120104):]

performance_columns = ['S_INFO_WINDCODE',
                   'REPORT_PERIOD',
                   'ANN_DT',
                   'S_QFA_YOYGR',
                   'S_QFA_YOYPROFIT',
                   'S_FA_GROSSMARGIN']

invest_columns = ['S_INFO_WINDCODE',
                  'REPORT_PERIOD',
                  'ANN_DT',
                  'S_FA_EBIT',
                  'S_FA_ROIC',
                  'S_FA_ROE']

scale_columns = ['STATEMENT_TYPE',
                 'S_INFO_WINDCODE',
                 'REPORT_PERIOD',
                 'ANN_DT',
                 'TOT_ASSETS',
                 'TOT_LIAB']

efficiency_columns = ['S_INFO_WINDCODE',
                      'REPORT_PERIOD',
                      'ANN_DT',
                      'S_QFA_NETPROFITMARGIN',
                      'S_QFA_GROSSPROFITMARGIN',
                      'S_FA_ASSETSTURN']

stock_name = pd.read_csv(r'%sstock_names.csv'%address,header = None).T
stock_name = np.array(stock_name).tolist()[0]
file_names = ['performance','invest','efficiency','scale']

## read csv, format fixing
for k in range(len(file_names)):
    factor = names[file_names[k]+'_columns']
    loops = len(factor)-1-factor.index('ANN_DT')
    for i in range(loops):
        names[file_names[k]+factor[-(i+1)]] = pd.read_csv('%s%s.csv'
                                                      %(address,(file_names[k]+factor[-(i+1)])))
        names[file_names[k]+factor[-(i+1)]] = names[file_names[k]+factor[-(i+1)]].set_index('Unnamed: 0')
        
for k in range(len(file_names)):
    factor = names[file_names[k]+'_columns']
    loops = len(factor)-1-factor.index('ANN_DT')
    for i in range(loops):    
        temp = pd.DataFrame(np.zeros([len(correct_date),1]),index = correct_date,).replace(0,np.nan)
        names[file_names[k]+factor[-(i+1)]] = temp.join(names[file_names[k]+factor[-(i+1)]])
        names[file_names[k]+factor[-(i+1)]] = names[file_names[k]+factor[-(i+1)]].fillna(method = 'ffill',axis = 0)
        names[file_names[k]+factor[-(i+1)]].to_csv('/Users/tianhaozhao/Desktop/%s.csv'%file_names[k]+factor[-(i+1)])


































            
            
            
            
            
            
            
            
            
            
            
            
            