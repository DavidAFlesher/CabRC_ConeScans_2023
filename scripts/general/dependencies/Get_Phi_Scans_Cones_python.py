import glob, os, json
from collections import defaultdict

files = sorted(glob.glob(os.path.join("PlotDensity", "*ED")))
abs_path = os.path.abspath(files[0])
fdir = os.path.basename(os.path.dirname(os.path.dirname(abs_path)))


data = dict()
for file in files:
    chl = os.path.basename(file).split("_")[0]
    angle = os.path.basename(file).split("_")[-1]
    angle2 = os.path.splitext(angle)[0]
    try:
        data[chl][f'angle_{angle2}'] = []
    except KeyError:
        data[chl] = {f'angle_{angle2}': []}
    #data[chl][f'angle_{angle2}'] = []
    print(chl, angle2)
    with open(file, 'r') as f:
        lines = f.readlines()
        dist = []
        amp = []
        #print(f'angle_{angle2}')
        for line in lines:
             dist.append(line.split()[0])
             amp.append(line.split()[-1])
             #tmp.append([distance, amp])
        data[chl][f'angle_{angle2}'] = [dist, amp]
print('writing to file')
fname = f'plotdensity_data_{fdir}.json'
with open(fname, 'w') as f2:
    json.dump(data, f2, indent=4)
