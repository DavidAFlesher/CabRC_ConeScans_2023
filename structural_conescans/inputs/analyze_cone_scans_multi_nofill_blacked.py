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

json_fname = glob.glob(os.path.join('..', 'data', 'plotdensity_data.json'))[0]
with open(json_fname, 'r') as f:
    raw_data = json.load(f)

ind_0 = raw_data["A901"]["angle_1"][0].index("0.250")
ind_1 = raw_data["A901"]["angle_1"][0].index("2.000")
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


# %% Big plot

list_BChls = ['A902', 'A903', 'A904', 'A905', 'A906', 'A907', 'A908', 'A909', 'a904', 'a905', 'a906', 'a907', 'a908', 'a909', 'a910', 'a911','A901', 'a903'] # Last two are Zn-BChl a'
list_Chls = ['A910', 'A911', 'A912', 'A931', 'A933', 'a901', 'a912', 'a913', 'a914', 'a915']

sorted_BChls = ['A901', 'a903', 'A903', 'A908', 'A909', 'a911', 'a910', 'a905', 'a909', 'A902', 'a904', 'A907', 'a908', 'A906', 'a907', 'A905', 'A904', 'a906']
sorted_Chls = ['a901', 'A910', 'A912', 'a912', 'a914', 'a915', 'A931', 'A933', 'A911', 'a913']

bfact_BChls = [1.63, 1.63, 1.63, 1.63, 1.63, 1.63, 1.64, 1.91, 2.7, 3.56, 4.14, 4.89, 9.24, 9.28, 10.52, 11.29, 13.37, 13.44]
bfact_Chls = [1.63, 1.63, 1.63, 1.63, 1.63, 1.63, 1.63, 1.63, 5.03, 5.03]
#%% BChls

fig, axs = plt.subplots(6, 3, figsize=(4*2.6, 6*2.5), dpi=400, sharex = True, sharey = True)
plt.setp(fig, tight_layout = True)

# Data
bond_distances = np.arange(0.25, 2.01, 0.01)
faux_x_axis = np.arange(72)
for i, (chl_id, b_fact, ax) in enumerate(zip(sorted_BChls, bfact_BChls, axs.flat)):
    # Plotting
    l1 = ax.plot(faux_x_axis, clean_data[chl_id][:, 98]*10) # 98=ind of bond distance 1.23
    l2 = ax.plot(faux_x_axis, clean_data[chl_id][:, 132]*10) # 132=ind of bond distance 1.57
    h_l = ax.axhline(alpha=1)

    # Making things pretty
    plt.setp(l1, label = 'C=O', ls = '-', color = "black", alpha = 1, linewidth = 2)
    plt.setp(l2, label = 'C-C', ls = (0, (5, 3)), color = "black", alpha = 1, linewidth = 2)
    plt.setp(h_l, color = 'black', ls = ':', alpha = 0.5, linewidth = 1)
    plt.setp(ax, xlim = [0, 71])
    plt.setp(ax, ylim = [-12, 33])
    plt.xticks(ticks = [0, 18, 36, 54, 71], labels = ['270', '360', '90', '180', '270'])
    subplot_title = f"{chl_id}"
    ax.set_title(subplot_title)
    plt.setp(ax, ylabel = 'ESP signal (a.u.)', xlabel = 'Scan Angle ($^\circ$)')
    ax.label_outer()

# custom shared legend
ax_label = fig.add_subplot(111) # label subplot
ax_label.axis('off')
line1 = mlines.Line2D([], [], color = 'black', alpha = 1, ls = '-', linewidth = 2, label = 'C=O, 1.23 Å')
line2 = mlines.Line2D([], [], color = 'black', alpha = 1, ls = '--', linewidth = 2, label = 'C—C, 1.57 Å')
legend = ax_label.legend(handles = [line1, line2], prop = {"size":15}, ncol = 2, loc = 'upper center', bbox_to_anchor = (0.5, 1.06))


# %% Chls

fig, axs = plt.subplots(5, 2, figsize=(4*2.2, 6*2.5), dpi=400, sharex = True, sharey = True)
plt.setp(fig, tight_layout = True)

# Data
bond_distances = np.arange(0.25, 2.01, 0.01)
faux_x_axis = np.arange(72)

for i, (chl_id, b_fact, ax) in enumerate(zip(sorted_Chls, bfact_Chls, axs.flat)):
    # Plotting
    l1 = ax.plot(faux_x_axis, clean_data[chl_id][:, 119]*10)# 119=ind of bond distance 1.44
    h_l = ax.axhline()

    # Making things pretty
    plt.setp(l1, label = 'C=C', ls = '-', color = "black", alpha = 1, linewidth = 2)
    plt.setp(h_l, color = 'black', ls = ':', alpha = 0.5, linewidth = 1)
    plt.setp(ax, xlim = [0, 71])
    plt.setp(ax, ylim = [-12, 33])
    plt.xticks(ticks = [0, 18, 36, 54, 71], labels = ['270', '360', '90', '180', '270'])
    subplot_title = f"{chl_id}"
    ax.set_title(subplot_title)
    plt.setp(ax, ylabel = 'ESP signal (a.u.)', xlabel = 'Scan Angle ($^\circ$)')
    ax.label_outer()

# custom shared legend
ax_label = fig.add_subplot(111) # label subplot
ax_label.axis('off')
line1 = mlines.Line2D([], [], color = 'black', alpha = 1, ls = '-', linewidth = 2, label = 'C=C, 1.44 Å')
ax_label.legend(handles = [line1], prop = {"size":15}, ncol = 1, loc = 'upper center', bbox_to_anchor = (0.5, 1.06))


# %% Chls mini

fig, axs = plt.subplots(5, 2, figsize=(7, 12.5), dpi=400, sharex = True, sharey = True)
plt.setp(fig, tight_layout = True)

# Data
bond_distances = np.arange(0.25, 2.01, 0.01)
faux_x_axis = np.arange(72)

for i, (chl_id, b_fact, ax) in enumerate(zip(sorted_Chls, bfact_Chls, axs.flat)):
    # Plotting
    l1 = ax.plot(faux_x_axis, clean_data[chl_id][:, 119]*10)# 119=ind of bond distance 1.44
    h_l = ax.axhline()

    # Making things pretty
    plt.setp(l1, label = 'C=C', ls = '-', color = "black", alpha = 1, linewidth = 2)
    plt.setp(h_l, color = 'black', ls = ':', alpha = 0.5, linewidth = 1)
    plt.setp(ax, xlim = [0, 71])
    plt.setp(ax, ylim = [-12, 33])
    plt.xticks(ticks = [0, 18, 36, 54, 71], labels = ['270', '360', '90', '180', '270'])
    subplot_title = f"{chl_id}"
    ax.set_title(subplot_title)
    plt.setp(ax, ylabel = 'ESP signal (a.u.)', xlabel = 'Scan Angle ($^\circ$)')
    ax.label_outer()

# custom shared legend
ax_label = fig.add_subplot(111) # label subplot
ax_label.axis('off')
line1 = mlines.Line2D([], [], color = 'black', alpha = 1, ls = '-', linewidth = 2, label = 'C=C, 1.44 Å')
ax_label.legend(handles = [line1], prop = {"size":15}, ncol = 1, loc = 'upper center', bbox_to_anchor = (0.5, 1.06))
