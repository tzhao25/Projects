#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jul 13 17:42:16 2019

@author: tianhaozhao
"""

import pandas as pd
import numpy as np
names= locals()
address = 'C:/Users/Jianxiong/Desktop/'

stock_name = pd.read_csv(r'%sstock_names.csv'%address,header = None).T
stock_name = np.array(stock_name).tolist()[0]
performance = pd.read_csv(r'%sperformance.csv'%address)
invest = pd.read_csv(r'%sinvest.csv'%address)
scale = pd.read_csv(r'%sscale.csv'%address)
efficiency = pd.read_csv(r'%sefficiency.csv'%address)

file_names = ['performance','invest','efficiency']

statement_type = 408001000

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



for k in range(len(file_names)):
    
    names[file_names[k]] = names[file_names[k]].drop(columns = 'Unnamed: 0')
    names[file_names[k]].columns = names[file_names[k]+'_columns']
    names[file_names[k]]= names[file_names[k]].set_index('ANN_DT')

scale = scale.loc[scale.STATEMENT_TYPE == statement_type]
scale = scale.reset_index()



def get_value_to_csv(dataframe1_str_name):
    
    dataframe1 = names[dataframe1_str_name]
    factor = names[dataframe1_str_name+'_columns']
    loops = len(factor)-1-factor.index('ANN_DT')
    ## Report date  and create dataframe
    #num = dataframe1.shape[1]
    if dataframe1_str_name == 'scale':
        dataframe1 = dataframe1.set_index('ANN_DT')
    num_nan_date = sum(dataframe1.index.isna())
    dataframe1 = dataframe1.sort_index()
    dataframe1 = dataframe1.iloc[0:len(dataframe1.index)-num_nan_date,:]
    date1 = (pd.DataFrame(dataframe1.index)
            .drop_duplicates().sort_index())
    dataframe1_1 = dataframe1.set_index('S_INFO_WINDCODE')
    num_nan_company = sum(dataframe1_1.index.isna())
    dataframe1_1 = dataframe1_1.sort_index()
    dataframe1_1 = dataframe1_1.iloc[0:len(dataframe1.index)-num_nan_company,:]
    company1 = (pd.DataFrame(dataframe1_1.index)
                .drop_duplicates().sort_index())

    d1_report_date= np.zeros([len(company1),len(date1)])
    date1 = date1.T.values.flatten().tolist()
    company1 = company1.values.flatten().T
    d1_report_date = pd.DataFrame(d1_report_date, columns = date1, index=company1)
    dataframe1 = dataframe1.loc[20090109:,:]
    date1 = date1[date1.index(20090109):]
    d1_report_date = d1_report_date.loc[:,20090109:]
    print ('step1 done')
    for i in range(len(date1)):
        names['temp_%s'%i] = dataframe1.loc[date1[i],:]
        if type(names['temp_%s'%i]) == pd.core.series.Series:
            names['temp_%s'%i] = pd.DataFrame(names['temp_%s'%i]).T
    for i in range(len(date1)):

        names['company_names_%s'%i] = pd.DataFrame(names['temp_%s'%i]
                                            .loc[:,'S_INFO_WINDCODE']).drop_duplicates()
        names['temp_%s'%i] = names['temp_%s'%i].set_index('S_INFO_WINDCODE')
        for j in range(len(names['company_names_%s'%i])):
            names['temp1_%s'%i] = names['temp_%s'%i].loc[names['company_names_%s'%i].iloc[j],:]
            report_date = max(names['temp1_%s'%i].loc[:,'REPORT_PERIOD'])
            
            d1_report_date.loc[names['company_names_%s'%i].iloc[j,0],date1[i]] = report_date 
    for i in range(len(date1)):
        del names['temp_%s'%i], names['temp1_%s'%i], names['company_names_%s'%i] 
    d1_report_date.to_csv('%sreport_date_%s.csv'%(address,dataframe1_str_name))  
    print ('report date exported')
    ## report date location in dataframe
    d1_report_date = d1_report_date.replace(0,np.nan)
    val_loc = d1_report_date.isna() 
    index = np.where(val_loc==False)[0]
    columns = np.where(val_loc == False)[1]
    report_loc_code = company1[index]
    report_loc_date = np.array(date1)[columns]   
    report_loc_report = []         
    for i in range(len(index)):
        temp = d1_report_date.iloc[index[i],columns[i]]
        report_loc_report.append(temp)
    print ('report date finished')
    ## report date dataframe finished, run loops for all other factors that need to be searched   
    ## the locations of report date are also assigned in two arrays
    
    ## create zeros dataframe for factors 
    for i in range(loops):

        names[factor[-(i+1)]+'_file'] = pd.DataFrame(np.zeros([len(company1),len(date1)])
                                                 ,columns = date1, index=company1)                   
        names[factor[-(i+1)]+'_file']  = names[factor[-(i+1)]+'_file'] .loc[:,20090109:]
    
        names[factor[-(i+1)]+'_file']  = names[factor[-(i+1)]+'_file'] .replace(0,np.nan)
        names[factor[-(i+1)]+'_file'][val_loc == False] = 1
        print (factor[-(i+1)],'created')
    ## fill in values of each factor
    for j in range(loops):
        for i in range(len(index)):
            temp = dataframe1[(dataframe1.S_INFO_WINDCODE == report_loc_code[i])]
            temp1 = temp[(temp.REPORT_PERIOD == report_loc_report[i])]
            temp2 = temp1[temp1.index.tolist() == report_loc_date[i]]
            names[factor[-(j+1)]+'_file'].iloc[index[i],columns[i]] = temp2.loc[:,factor[-(j+1)]].item()
        names[factor[-(j+1)]+'_file']  = names[factor[-(j+1)]+'_file'].fillna(method = 'ffill',axis = 1)
        print (factor[-(j+1)],'done')
    ## export factor as csv files
    for i in range(loops):
        names[factor[-(i+1)]+'_file'] = names[factor[-(i+1)]+'_file'].loc[:,20100104:]
        names[factor[-(i+1)]+'_file'] = names[factor[-(i+1)]+'_file'].T
        names[factor[-(i+1)]+'_file'] = names[factor[-(i+1)]+'_file'].loc[:,stock_name]
        names[factor[-(i+1)]+'_file'].to_csv('%s%s.csv'
                                      %(address,(dataframe1_str_name+factor[-(i+1)])))
        print (factor[-(i+1)],'_file exported')

for k in range(len(file_names)):
    get_value_to_csv(file_names[k])
    
get_value_to_csv('scale')

def stock_concat(dataframe1):
    d1_values.loc[:,stock_name[0]]








aa = pd.read_csv('C:/Users/Jianxiong/Desktop/tot_assets.csv')



def get_file(dataframe_str):
    names['%s'%dataframe_str] = pd.read_csv('C:/Users/Jianxiong/Desktop/%s.csv'%dataframe_str)
    names['%s'%dataframe_str] = names['%s'%dataframe_str].drop(columns = 'Unnamed: 0')
    names['%s'%dataframe_str] = names['%s'%dataframe_str].T
    
get_file('tot_assets')


dataframe.to_csv('C:/Users/Jianxiong/Desktop/tot_assets.csv')






#    for i in range(d1_report_date.shape[1]):
#        for j in range(d1_report_date.shape[0]):
#            if d1_report_date.iloc[j,i] != 0 and d1_report_date.iloc[j,i]<20190719:
#                print(i,j)
#                d = d1_report_date.columns[i]
#                c = d1_report_date.index[j]
#                r = d1_report_date.iloc[j,i]
#                names['temp3_%s'%(i*1000+j)] = pd.DataFrame(dataframe1.loc[d])
#                if names['temp3_%s'%(i*1000+j)].shape[1] == 1:
#                    names['temp3_%s'%(i*1000+j)] = names['temp3_%s'%(i*1000+j)].T
#                names['temp3_%s'%(i*1000+j)] = pd.DataFrame(names['temp3_%s'%(i*1000+j)].set_index('S_INFO_WINDCODE').loc[c])
#                names['temp4_%s'%(i*1000+j)] = names['temp3_%s'%(i*1000+j)]
#                if type(names['temp4_%s'%(i*1000+j)]) == pd.core.series.Series:
#                    names['temp4_%s'%(i*1000+j)] = pd.DataFrame(names['temp4_%s'%(i*1000+j)]).T
#                if names['temp4_%s'%(i*1000+j)].shape[1] == 1:
#                    names['temp4_%s'%(i*1000+j)] = names['temp4_%s'%(i*1000+j)].T
#                names['temp4_%s'%(i*1000+j)]=names['temp4_%s'%(i*1000+j)].set_index('REPORT_PERIOD')
#    columns = dataframe1.columns.tolist()
#    
#    for k in range(num):
#        for i in range(d1_report_date.shape[1]):
#            for j in range(d1_report_date.shape[0]):
#                names['%s'%columns[columns.index('REPORT_PERIOD')+1]].index[i].iloc[j,i] = names['temp4_%s'%(i*1000+j)].loc[r,'TOT_ASSETS'] 



#for i in range(len(date1)):
#    print(i)
#    for j in range(len(names['company_names_%s'%i])):
#        c = names['company_names_%s'%i].iloc[j,0]
#        rd = d1_report_date.iloc[j,i]
#        names['temp2_%s'%i] = names['temp_%s'%i].set_index('c')
#        val =  names['temp2_%s'%i].loc[(names['temp_%s'%i].REPORT_PERIOD==bb)
#        d1_values[j,i] = val

for i in range(len(date1)):
    del names['temp_%s'%i], names['temp1_%s'%i], names['company_names_%s'%i] 
for i in range(d1_report_date.shape[1]):
    for j in range(d1_report_date.shape[0]):   
        if d1_report_date.iloc[j,i] != 0 and d1_report_date.iloc[j,i]<20190719:
            del  names['temp3_%s'%(i*1000+j)] 
    return d1_report_date,d1_values 
d1_report_date = aaa(scale)            
           
        
        

        
        