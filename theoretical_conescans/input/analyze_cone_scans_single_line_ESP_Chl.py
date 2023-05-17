# -*- coding: utf-8 -*-
"""
Created on Thu Mar 23 17:32:52 2023

@author: davidflesher_oldman
"""

# %% Imports

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.lines as mlines
import json, os, glob
from matplotlib.collections import LineCollection


# %% Loading data into a data frame

json_fname = glob.glob(os.path.join('..', 'data', 'plotdensity_data_chl_2p22.json'))[0]
with open(json_fname, 'r') as f:
    raw_data = json.load(f)

ind_0 = raw_data["A910"]["angle_1"][0].index("0.250") # 0.250
ind_1 = raw_data["A910"]["angle_1"][0].index("2.000")
plot_len = ind_1 - ind_0

clean_data = dict()

# initialize data
for chl_id in raw_data:
    clean_data[chl_id] = np.zeros((72, plot_len+1))
for chl_id in raw_data:
    for angle, data in raw_data[chl_id].items():
        angle_int = int(angle.split("_")[-1])
        angle_int2 = int((angle_int+54+18)%72) # Mod to start at 270°
        amp_data = data[-1][ind_0:ind_1+1]
        dist_data = data[0][ind_0:ind_1+1] #sanity check
        clean_data[chl_id][angle_int2-1, :] = amp_data

# %% Chl

fig, ax = plt.subplots(figsize = (8, 6), dpi=500)
plt.setp(fig, tight_layout = True)

# Data
bond_distances = np.arange(0.25, 2.01, 0.01)
faux_x_axis = np.arange(72)
l1_y_vals = clean_data["A910"][:, 119]*10 # 119=ind of bond distance 1.44

# Plotting
l1 = ax.plot(faux_x_axis, l1_y_vals) # 119=ind of bond distance 1.44
h_l = ax.axhline(alpha=0.5)

# Making things pretty
plt.setp(l1, label = 'C=C', ls = '-', color = "black", alpha = 1, linewidth = 3)
plt.setp(h_l, color = 'black', ls = ':', alpha = 1, linewidth = 1)
plt.setp(ax, xlim = [0, 71])
plt.setp(ax, ylim = [-0.5, 9.5])
plt.xticks(ticks = [0, 18, 36, 54, 71], labels = ['270', '360', '90', '180', '270'])
plt.setp(ax, ylabel = 'ESP signal (a.u.)', xlabel = 'Scan Angle ($^\circ$)')

ax_label = fig.add_subplot(111) # label subplot
ax_label.axis('off')
line1 = mlines.Line2D([], [], color = 'black', alpha = 1, ls = '-', linewidth = 3, label = 'C=C, 1.44 Å')
legend = ax_label.legend(handles = [line1], prop = {"size":15}, ncol = 2, loc = 'upper center', bbox_to_anchor = (0.5, 1.15))



# %%

fname = os.path.join("..", "figures", "single_line_cla2p22_blacked.png")
plt.savefig(fname, dpi = 500, format = "png", )
