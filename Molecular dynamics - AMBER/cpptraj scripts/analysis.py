#!/usr/bin/env python
# coding: utf-8

# In[11]:


from matplotlib import pyplot as plt
import numpy as np
import pandas as pd


# In[12]:


def RMSD(file1='./rmsd.dat', file2=None, legend1='file1', legend2='file2', out='RMSD', top=None, bottom=None):
    rmsd1 = np.loadtxt(file1)
    plt.plot(rmsd1.T[0], rmsd1.T[1])
    if file2 != None:
        rmsd2 = np.loadtxt(file2)
        plt.plot(rmsd2.T[0], rmsd2.T[1])
        plt.legend([legend1, legend2])
    plt.xlabel("Frame #")
    plt.ylabel("RMSD (Å)")
    plt.ylim(top=top, bottom=bottom)
    plt.savefig(out+'.svg')


# In[13]:


RMSD('./298K/rmsd.dat', './323K/rmsd.dat', '298K', '323K', out='RMSD_298v323K', top=8)


# In[14]:


def RMSD2D(nombre_archivo='./rmsd-2d.dat', vmax=None, out='RMSD-2D'):
    rmsd2d = np.loadtxt(nombre_archivo)[:,1:]
    plt.imshow(rmsd2d, cmap='viridis', origin='lower', extent=(0.5,rmsd2d.shape[0]+0.5,0.5,rmsd2d.shape[1]+0.5), vmax=vmax)
    plt.xlabel('Frame #')
    plt.ylabel('Frame #')
    plt.colorbar(label=r'RMSD ($\AA$)')
    plt.savefig(out+'.svg')


# In[15]:


RMSD2D('./298K/rmsd-2d.dat', out='RMSD-2D-298K.svg')


# In[16]:


RMSD2D('./323K/rmsd-2d.dat', out='RMSD-2D-323K.svg')


# In[17]:


def RMSF(file1='./rmsf.dat', file2=None, legend1='file1', legend2='file2', out='RMSF', top=None, bottom=None):
    rmsf1 = np.loadtxt(file1)
    plt.plot(rmsf1.T[0], rmsf1.T[1])
    if file2 != None:
        rmsf2 = np.loadtxt(file2)
        plt.plot(rmsf2.T[0], rmsf2.T[1])
        plt.legend([legend1, legend2])
    plt.xlabel("residue #")
    plt.ylabel("RMSF (Å)")
    plt.ylim(top=top, bottom=bottom)
    plt.savefig(out+'.svg')


# In[18]:


RMSF('./298K/rmsf.dat', './323K/rmsf.dat', '298K', '323K', out='RMSF_298v323K', top=27)


# In[19]:


def SAS(file1='./sas.dat', top=None, bottom=None, out='SAS'):
    sas1 = pd.read_fwf(file1)
    sas1 = sas1[sas1.iloc[:, 1]>0]
    plt.plot(sas1.iloc[:, 0], sas1.iloc[:, 1])
    sas1_mean = sas1.rolling(100, min_periods=1, center=False).mean()
    sas1_std = sas1.rolling(100, min_periods=1, center=False).std()
    plt.plot(sas1_mean.iloc[:, 1])
    plt.fill_between(sas1.iloc[:, 0], sas1_mean.iloc[:, 1]-sas1_std.iloc[:, 1], sas1_mean.iloc[:, 1]+sas1_std.iloc[:, 1], alpha=0.5, color='orange')
    plt.ylim(top=top, bottom=bottom)
    plt.xlabel("Frame #")
    plt.ylabel("SAS (Å²)")
    plt.savefig(out+'.svg')


# In[20]:


SAS('./298K/sas.dat', out='SAS-298K', top=32000, bottom=25000)


# In[21]:


SAS('./298K/sasa_nonpolar.dat', out='SAS_nonpolar', top=9500, bottom=7200)


# In[22]:


SAS('./323K/sas.dat', out='SAS-323K', top=32000, bottom=25000)


# In[23]:


SAS('./323K/sasa_nonpolar.dat', out='SAS_nonpolar', top=9500, bottom=7200)


# In[24]:


def RADGYR(file1='./rmsd.dat', file2=None, legend1='file1', legend2='file2', out='RADGYR', top=None, bottom=None):
    rog1 = np.loadtxt(file1)
    plt.plot(rog1.T[0], rog1.T[1])
    if file2 != None:
        rog2 = np.loadtxt(file2)
        plt.plot(rog2.T[0], rog2.T[1])
        plt.legend([legend1, legend2])
    plt.xlabel("Frame #")
    plt.ylabel("ROG")
    plt.ylim(top=top, bottom=bottom)
    plt.savefig(out+'.svg')


# In[25]:


RADGYR('./298K/radgyr.dat', './323K/radgyr.dat', '298K', '323K', out='RADGYR_298v323K', top=29, bottom=26)


# In[26]:


def hbonds(file1, file2=None, legend1='file1', legend2='file2', out='hbonds_vtime', top=None, bottom=None):
    hbonds1 = np.loadtxt(file1)[:,1:].sum(axis=1)
    plt.plot(range(1000), hbonds1)
    if file2 != None:
        hbonds2 = np.loadtxt(file2)[:,1:].sum(axis=1)
        plt.plot(range(1000), hbonds2)
        plt.legend([legend1, legend2])    
    plt.xlabel("Frame #")
    plt.ylabel("# of h-bonds")
    plt.savefig(out+'.svg')


# In[27]:


hbonds('./298K/hbonds_series.dat', './323K/hbonds_series.dat', '298K', '323K')


# In[28]:


def cluster_vtime(nombre_archivo='./cluster-population-vs-time.dat', out='cluster-vtime'):
    cluster_vtime = np.loadtxt(nombre_archivo)
    clusters = []
    for cluster in range(1, cluster_vtime.shape[1]):
        plt.plot(cluster_vtime.T[0], cluster_vtime.T[cluster])
        clusters.append(cluster - 1)
    plt.xlabel("Frame #")
    plt.ylabel("Population")
    plt.legend(clusters)
    plt.savefig(out+'.svg')


# In[29]:


cluster_vtime('./298K/cluster-population-vs-time.dat', out='cluster_vtime_298K')


# In[30]:


cluster_vtime('./323K/cluster-population-vs-time.dat', out='cluster_vtime_323K')


# In[31]:


def contacts_vtime_native(file1, file2=None, legend1='file1', legend2='file2', out='contacts_vtime', top=None, bottom=None):
    contacts1 = np.loadtxt(file1)
    plt.plot(contacts1.T[0], contacts1.T[1])
    if file2 != None:
        contacts2 = np.loadtxt(file2)
        plt.plot(contacts2.T[0], contacts2.T[1])
        plt.legend(['native ' + legend1, 'native ' + legend2])
    plt.ylim(top=top, bottom=bottom)
    plt.xlabel('Frame #')
    plt.ylabel('# of contacts')
    plt.savefig(out+'.svg')


# In[32]:


def contacts_vtime_nnative(file1, file2=None, legend1='file1', legend2='file2', out='contacts_vtime', top=None, bottom=None):
    contacts1 = np.loadtxt(file1)
    plt.plot(contacts1.T[0], contacts1.T[2])
    if file2 != None:
        contacts2 = np.loadtxt(file2)
        plt.plot(contacts2.T[0], contacts2.T[2])
        plt.legend(['non-native ' + legend1, 'non-native ' + legend2])
    plt.ylim(top=top, bottom=bottom)
    plt.xlabel('Frame #')
    plt.ylabel('# of contacts')
    plt.savefig(out+'.svg')


# In[33]:


contacts_vtime_native('./298K/contacts_all.dat', './323K/contacts_all.dat', '298K', '323K', out='contacts_vtime_native', top=230000, bottom=50000)


# In[34]:


contacts_vtime_nnative('./298K/contacts_all.dat', './323K/contacts_all.dat', '298K', '323K', out='contacts_vtime_nnative', top=230000, bottom=50000)


# In[35]:


contacts_vtime_native('./298K/contacts-inter_all.dat', './323K/contacts-inter_all.dat', '298K', '323K', out='contacts-inter_vtime_native', top=18000, bottom=4000)


# In[36]:


contacts_vtime_nnative('./298K/contacts-inter_all.dat', './323K/contacts-inter_all.dat', '298K', '323K', out='contacts-inter_vtime_nnative', top=18000, bottom=4000)


# In[37]:


contacts_vtime_native('./298K/contacts-hydrophobic_all.dat', './323K/contacts-hydrophobic_all.dat', '298K', '323K', out='contacts-type_vtime_native', top=106000, bottom=24000)


# In[38]:


contacts_vtime_nnative('./298K/contacts-hydrophobic_all.dat', './323K/contacts-hydrophobic_all.dat', '298K', '323K', out='contacts-type_vtime_nnative', top=106000, bottom=24000)


# In[39]:


contacts_vtime_native('./298K/contacts-hydrophilic_all.dat', './323K/contacts-hydrophilic_all.dat', '298K', '323K', out='contacts-type_vtime_native', top=33000, bottom=8000)


# In[40]:


contacts_vtime_nnative('./298K/contacts-hydrophilic_all.dat', './323K/contacts-hydrophilic_all.dat', '298K', '323K', out='contacts-type_vtime_nnative', top=33000, bottom=8000)

