# -*- coding: utf-8 -*-
"""
Created on Wed Apr 19 15:09:56 2023

@author: davidflesher_oldman
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.lines as mlines
import json, os, glob
from matplotlib.collections import LineCollection



# %% Loading data into a data frame

data_name = 'bchl_2p0'
json_fname = glob.glob(os.path.join('..', 'data', f'plotdensity_data_{data_name}.json'))[0]
with open(json_fname, 'r') as f:
    raw_data = json.load(f)

ind_0 = raw_data["A905"]["angle_1"][0].index("0.000")
ind_1 = raw_data["A905"]["angle_1"][0].index("4.000")
plot_len = ind_1 - ind_0

clean_data = dict()

# initialize data
for chl_id in raw_data:
    clean_data[chl_id] = np.zeros((72, plot_len+1))
for chl_id in raw_data:
    for angle, data in raw_data[chl_id].items():
        #print(angle)
        angle_int = int(angle.split("_")[-1])
        angle_int2 = int((angle_int+54+18)%72) # Mod to start at 270°
        amp_data = data[-1][ind_0:ind_1+1]
        dist_data = data[0][ind_0:ind_1+1] #sanity check for dist range
        clean_data[chl_id][angle_int2-1, :] = amp_data


#np.savetxt(os.path.join("..", "data", "clean_data_BChl_2p22.csv"), clean_data["A905"].T, delimiter = ",", header = "axis 1 = ESP signal (spaced every 0.01 ang) axis 2 = bond angle (spaced every 5 deg)")

plot_data = clean_data["A905"].T


# %% plot

import matplotlib.pyplot as plt
from matplotlib.colors import BoundaryNorm
from matplotlib.ticker import MaxNLocator
import numpy as np

Z = plot_data[25:, :]*10 # start at bond length 0.25 Å
y = np.arange(0.25, 4.01, 0.01) # bond lengths for data in Z
x = np.arange(0, 72) # bond angles for data in Z

fig, ax = plt.subplots(figsize = (8, 6), dpi=200)
plt.setp(fig, tight_layout = True)
hmap = ax.pcolormesh(x, y, Z, cmap = "inferno", shading = "gouraud", vmin = -0.5, vmax = 9.5)

plt.xticks(ticks = [0, 18, 36, 54, 71], labels = ['270', '360', '90', '180', '270'])
#cbar_ax = fig.add_axes([1.1, 0.1, 0.02, 0.8]) # left, bottom, width, height
#fig.colorbar(hmap, cax = cbar_ax)
#fig.subplots_adjust(wspace=0.05, hspace=0.4, right=0.8)
plt.setp(ax, ylabel = 'Bond Distance (Å)', xlabel = 'Scan Angle ($^\circ$)')


# %%

fname = os.path.join("..", "figures", f'heatmap_{data_name}.png')
plt.savefig(fname, dpi = 500, format = "png", )
