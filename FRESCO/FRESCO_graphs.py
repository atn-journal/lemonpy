# %%
#Import libraries
from matplotlib import cm
from matplotlib import pyplot as plt
from matplotlib_venn import venn2
from matplotlib.colors import Normalize 
from scipy.stats import gaussian_kde
from scipy.interpolate import interpn
from natsort import natsorted
import seaborn as sns
import pandas as pd
import numpy as np

# %%
def venn_diagram(tab1, tab2, label1, label2, title, out, size=(10,10)):
    '''
    Get the mutants from two FoldX/Rosetta tab files
    and construct a Venn diagram
    '''
    # Open files, ignore title line, get mutants into list
    with open(tab1) as f:
        next(f)
        df1 = pd.read_csv(f, sep='\s+', names=['mut','ddg','sd'])
        list1 = df1['mut'].values.tolist()

    with open(tab2) as f:
        next(f)
        df2 = pd.read_csv(f, sep='\s+', names=['mut','ddg','sd'])
        list2 = df2['mut'].values.tolist()
    
    set1 = set(list1)
    set2 = set(list2)

    # Plot the Venn diagram
    fig = plt.figure()
    venn2([set1, set2], (label1, label2))
    plt.title(title, size=20)
    plt.figure(figsize=size)
    fig.savefig(out, bbox_inches = 'tight')
    plt.show()

# %%
def heatmap(tab, title, out, vmax=20, vmin=-20, size=(25,8)):
    '''
    Plot heatmap of mutation vs. residue number, with predicted ddg as magnitude.
    '''
    
    # Open file, ignore first line and save to dataframe
    with open(tab) as f:
        next(f)
        df = pd.read_csv(f, sep='\s+', names=['mut','ddg','sd'])

    # Create new columns with wt resiude, position and new residue
    df[['old', 'pos', 'new']] = df['mut'].str.extract('([A-Za-z])(\d+)([A-Za-z])', expand = True)
    
    # Save position, new residue and ddg to new dataframe, and
    # perform modifications to provide as input for plotting
    df2 = df[['pos','new','ddg']]
    df2 = df2.pivot_table(index='pos', columns='new', values='ddg')
    df2 = df2.reindex(natsorted(df2.index)).transpose()

    # Plot heatmap
    plt.figure(figsize = size)
    plt.title(title, size=20)
    fig = sns.heatmap(df2, vmax=vmax, vmin=vmin, cmap='icefire', cbar_kws={'label': 'ddg (kJ/mol)'})
    fig.invert_yaxis()
    plt.ylabel('mutant')
    fig.figure.savefig(out, bbox_inches = 'tight')
    plt.show()

# %%
def density_scatter(x, y, ax=None, sort=True, bins=250, bar=False, **kwargs):
    """
    Scatter plot colored by 2d histogram, modified from https://stackoverflow.com/a/53865762
    """
    
    if ax is None:
        fig, ax = plt.subplots()
    data, x_e, y_e = np.histogram2d(x, y, bins = bins, density = True )
    z = interpn((0.5*(x_e[1:] + x_e[:-1]), 0.5*(y_e[1:]+y_e[:-1])), data, np.vstack([x,y]).T, method = "splinef2d", bounds_error = False)

    #To be sure to plot all data
    z[np.where(np.isnan(z))] = 0.0

    # Sort the points by density, so that the densest points are plotted last
    if sort:
        idx = z.argsort()
        x, y, z = x[idx], y[idx], z[idx]

    ax.scatter(x, y, c=z, **kwargs)

    norm = Normalize(vmin = np.min(z), vmax = np.max(z))
    
    # Show density bar (false by default)
    if bar:
        cbar = fig.colorbar(cm.ScalarMappable(norm = norm), ax=ax)
        cbar.ax.set_ylabel('Density')

    return ax

# %%
def scatter_plot(tab1, tab2, label1, label2, title, out, xlim=None, ylim=None, s=5, bins=100):
    '''
    Find ddg for every mutant from two different calculations
    and check visual correlation with a scatter plot
    '''

    # Open files, ignore first line, load to a dataframe
    with open(tab1) as f:
        next(f)
        df1 = pd.read_csv(f, sep='\s+', names=['mut', 'ddg1', 'sd'])
    
    with open(tab2) as f:
        next(f)
        df2 = pd.read_csv(f, sep='\s+', names=['mut', 'ddg2', 'sd'])

    # Concatenate dataframes
    concat = pd.concat([df1, df2], axis='columns')
    x = concat['ddg1']
    y = concat['ddg2']

    # Plot
    density_scatter(x, y, s=s, bins=bins)
    plt.xlabel(f'{label1} (kJ/mol)')
    plt.ylabel(f'{label2} (kJ/mol)')
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.title(title, size=20)
    plt.savefig(out, bbox_inches = 'tight')
