#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep  8 18:44:53 2019

@author: tianhaozhao
"""

import pandas as pd
import numpy as np
import os
import datetime
names = locals()
## general information
address = "/Users/tianhaozhao/Desktop/cme/"
if os.path.exists('%sfeatures'%(address)) == False:
    os.mkdir('%sfeatures'%(address))
first_year = 2017
last_year = 2019
feature_list = pd.read_csv('%sfeatures_selected.csv'%address,header = None).T.values.tolist()[0]
c_list = ['energy'] 

## Search for all energy commodities
c_names = pd.read_csv('%sc_names.csv'%address).T.values.tolist()[0]
energy_list = []  
for i in range(len(c_names)):
    b = 'FUEL'
    c = 'GAS'
    d = 'CRUDE'
    e = 'PROPANE'
    f = 'HEATING'
    g = 'NATURAL'
    if c in c_names[i] or d in c_names[i] or b in c_names[i] or e in c_names[i] or f in c_names[i] or g in c_names[i]:
        energy_list.append(c_names[i])


## data reshaping 
def data_reshape(address,first_year,last_year):
    year_list = np.arange(first_year,last_year+1,1,dtype = int).tolist()
    year_list = [str(i) for i in year_list]

    for i in year_list:
        names['file_%s'%i] = pd.read_csv("%s/%s.csv"%(address,i))
        date = names['file_%s'%i].iloc[:,2].values.tolist()
        name = names['file_%s'%i].iloc[:,0].values.tolist()
        names['file_%s'%i] = names['file_%s'%i].loc[:,feature_list]
        names['file_%s'%i].insert(0, 'Market_and_Exchange_Names', name)
        if i == '2017':
            names['date_%s'%i] = [datetime.datetime.strptime(i, "%Y/%m/%d").date() for i in date]
            names['file_%s'%i].insert(0,'Report_Date_as_MM_DD_YYYY',names['date_%s'%i])
        else:
            names['date_%s'%i] = [datetime.datetime.strptime(i, "%m/%d/%Y").date() for i in date]
            names['file_%s'%i].insert(0,'Report_Date_as_MM_DD_YYYY',names['date_%s'%i])
            
    for i in range(len(feature_list)):
        print(i)
        ltc = []
        for j in year_list:
            temp = names['file_%s'%j].pivot(index = names['file_%s'%j].columns[0],columns = names['file_%s'%j].columns[1], values = feature_list[i])  
            ltc.append(temp)
        cat = pd.concat(ltc,sort=True)
        names['%s'%feature_list[i]] = cat
        cat.to_csv("%sfeatures/%s.csv"%(address,feature_list[i]))
    for i in range(len(c_list)):
        if os.path.exists('%s%s'%(address,c_list[i])) == False:
            os.mkdir('%s%s'%(address,c_list[i]))
    
    for i in range(len(feature_list)):
        names['%s_energy'%(feature_list[i])] = names[feature_list[i]][energy_list] 
#        names['%s_corn'%(feature_list[i])] = names[feature_list[i]][corn_list] 
        
        names['%s_energy'%(feature_list[i])] = names['%s_energy'%(feature_list[i])].fillna(0).sum(axis =1)
#        names['%s_corn'%(feature_list[i])] = names['%s_corn'%(feature_list[i])].fillna(0).sum(axis =1)
        
    zero_value_features = []
    for j in range(len(c_list)):
        for i in range(len(feature_list)):
            tot_sum = names['%s_%s'%(feature_list[i],c_list[j])].sum()
            if tot_sum == 0:
                zero_value_features.append('%s_%s'%(feature_list[i],c_list[j]))
    file=open('%szero_value_features.txt'%address,'w')
    file.write(str(zero_value_features));
    file.close() 
         
    file=open('%senergy_list.txt'%address,'w')
    file.write(str(energy_list));
    file.close()
    
    file=open('%senergy_list.txt'%address,'w')
    file.write(str(energy_list));
    file.close() 
    
    for j in range(len(c_list)):
        for i in range(len(feature_list)):
            if '%s_%s'%(feature_list[i],c_list[j]) not in zero_value_features:
                names['%s_energy'%(feature_list[i])].to_csv("%s%s/%s_%s.csv"%(address,c_list[j],feature_list[i],c_list[j]))

            
    
    
    
    

data_reshape(address,first_year,last_year)






