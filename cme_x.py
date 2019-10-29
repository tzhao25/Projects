#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 23 21:24:37 2019

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
first_year = 2011
last_year = 2019
feature_list = pd.read_csv('%sfeatures_selected.csv'%address,header = None).T.values.tolist()[0]
c_list = ['NATGAS','CRUDE_OIL','REFINE','BIO','COAL','PETRO'] 

## Search for all energy commodities 
c_names = pd.read_csv('%sc_names.csv'%address).T.values.tolist()[0]

key_char={'natgas':['NATURAL','NAT GAS'],
          'cl':['CRUDE'],
          'rf':['ULSD','GASOLINE','HARBOR'],
          'bio':['ETHANOL','METHANOL','BIO'],
          'coal':['COAL'],
          'petro':['PROPANE','BUTANE','NATURAL_GASOLINE']}
natgas = [x for x in c_names if any([y in x for y in key_char['natgas']])]
cl = [x for x in c_names if any([y in x for y in key_char['cl']])]
rf = [x for x in c_names if any([y in x for y in key_char['rf']])]  
bio = [x for x in c_names if any([y in x for y in key_char['bio']])]  
coal = [x for x in c_names if any([y in x for y in key_char['coal']])]  
petro = [x for x in c_names if any([y in x for y in key_char['petro']])]  
product_namelist = [natgas,cl,rf,bio,coal,petro]

## data reshaping         
# Import feature files
year_list = np.arange(first_year,last_year+1,1,dtype = int).tolist()
year_list = [str(i) for i in year_list]

for i in year_list:
    names['file_%s'%i] = pd.read_csv("%s/%s.csv"%(address,i))
    date = names['file_%s'%i].iloc[:,2].values.tolist()
    name = names['file_%s'%i].iloc[:,0].values.tolist()
    names['file_%s'%i] = names['file_%s'%i].loc[:,feature_list]
    names['file_%s'%i].insert(0, 'Market_and_Exchange_Names', name)
    
    if (i in ['2017','2011','2012','2013','2014']) == True:       
        names['date_%s'%i] = [datetime.datetime.strptime(str(i), "%Y/%m/%d").date() for i in date]
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
       

## Loop through all commodities types 
SUM_output = []
namelist_output = []

for i in range(len(c_list)):
    SUM_output.append(('%s_SUM.csv'%c_list[i]))
    namelist_output.append('%s_list.csv'%c_list[i])
    
for k in range(len(product_namelist)):          
    # Feature reshaping by each commodity 
    for i in range(len(product_namelist[k])): 
        print(i)
        for j in range(len(feature_list)):
            if j == 0:
                temp = pd.DataFrame(names[feature_list[j]][product_namelist[k][i]])
            else:
                temp = pd.concat([temp,names[feature_list[j]][product_namelist[k][i]]],axis=1)
        temp.columns  = feature_list        
        names['%s'%(product_namelist[k][i])] = temp
        
    for i in range(len(product_namelist[k])): 
        if i == 0:
            temp = np.array(names[product_namelist[k][i]].fillna(0))
        else:
            temp = temp + np.array(names[product_namelist[k][i]].fillna(0))
        names[SUM_output[k].replace('.csv','')] = pd.DataFrame(temp,index = names[product_namelist[k][0]].index, columns = feature_list)
        names[SUM_output[k].replace('.csv','')].to_csv(address+SUM_output[k])        
    # Export       
    for i in range(len(product_namelist[k])):           
        temp = (product_namelist[k][i].replace(' ','_').replace('#','').replace('%','')
                .replace('-','').replace('/',''))      
        names['%s'%(product_namelist[k][i])].to_csv('%s%s/%s.csv'%(address,c_list[k],temp))
    
    
    for i in range(len(product_namelist[k])):           
        product_namelist[k][i] = (product_namelist[k][i].replace(' ','_').replace('#','').replace('%','')
                .replace('-','').replace('/',''))  
    product_namelist[k] = pd.DataFrame(product_namelist[k])
    product_namelist[k].to_csv(address+namelist_output[k])        
## Delete variables
for i in range(len(feature_list)):
    del names[feature_list[i]]
## make ratio
feature_list = [i.replace('_All','') for i in feature_list]
feature_list = [i.replace('_ALL','') for i in feature_list]

## 5 weeks
#create columns for each past dataset
n = 5
for i in range(n):
    day = str(n-i)
    print(day)
    names['columns_%s'%str(i+1)] = []
    for j in range(len(feature_list)):
        names['columns_%s'%str(i+1)].append(feature_list[j]+'_%sweeks_ago'%day)
        
for i in range(len(SUM_output)):
    temp = names[SUM_output[i].replace('.csv','')]
    temp_f = temp.iloc[5:,:]
    index = temp_f.index
    for j in range(n):
        print(j)                                        
        names['temp_%s'%str(j+1)] = pd.DataFrame(temp.iloc[j:(j-5),:])
        names['temp_%s'%str(j+1)].columns = names['columns_%s'%str(j+1)]
        names['temp_%s'%str(j+1)].index = index
        temp_f = pd.concat([temp_f,names['temp_%s'%str(j+1)]],axis = 1)
        temp_f.to_csv(address+(SUM_output[i].replace('.csv',''))+'_with_old_data.csv')
        names[SUM_output[i].replace('.csv','')]=temp_f
        
date_len = temp_f.shape[0]

## commodity indicator
one = np.zeros([1,date_len]).tolist()[0]
zero = np.zeros([1,date_len]).tolist()[0]
one = [1 for i in one]
for i in range(len(SUM_output)):
    temp = names[SUM_output[i].replace('.csv','')]
    for j in range(len(c_list)):
        if i == j:
            temp[c_list[j]] = one 
        else:
            temp[c_list[j]] = zero
        names[SUM_output[i].replace('.csv','')] = temp
        names[SUM_output[i].replace('.csv','')].to_csv(address+(SUM_output[i].replace('.csv',''))+'_with_old_data.csv')
        
    
## Convert feature to monthly data
def to_monthly(filename):
    product = pd.read_csv(address+filename,index_col=None, parse_dates=True)
    product.Report_Date_as_MM_DD_YYYY = pd.to_datetime(product.Report_Date_as_MM_DD_YYYY)
    product = product.resample('M', on='Report_Date_as_MM_DD_YYYY').sum()
    product.to_csv(address+(SUM_output[i].replace('.csv',''))+'_with_old_data_monthly.csv')
    return product

for i in range(len(SUM_output)):
    to_monthly(SUM_output[i].replace('.csv','')+'_with_old_data.csv')

