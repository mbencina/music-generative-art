import sys
from musicnn.tagger import top_tags
from musicnn.extractor import extractor
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd


location_name = './music/'
file_name = 'cvet_short.wav'  # song name
file_path = location_name + file_name
input_length = 3.0
input_overlap = 1.0

instruments = {'vocal': ['vocal', 'singing', 'vocals', 'male vocal', 'male voice', 'female vocal', 'female voice'],
               'drums': ['drums'],
               'guitar': ['guitar']}

genre = {'pop_rock': ['rock', 'pop'],
         'ambient': ['ambient', 'classic'],
         'electronic': ['dance', 'electronic']}

data, tags = extractor(file_path, model='MTT_musicnn',
                       extract_features=False, input_length=input_length, input_overlap=input_overlap)

print("input_length", input_length, "input_overlap:", input_overlap, "shape:", np.shape(data))

df = pd.DataFrame(data=data, columns=tags)
num_rows = len(df.index)

res_df = pd.DataFrame(index=range(num_rows), columns=['vocal', 'drums', 'guitar', 'pop_rock', 'ambient', 'electronic'])

for i in range(num_rows):
    best_genre = ""
    genre_max = 0
    for k, v in genre.items():
        max_val = 0
        for val in v:
            if df.at[i, val] > max_val:
                max_val = df.at[i, val]

        res_df.at[i, k] = max_val
        if max_val > genre_max:
            genre_max = max_val
            best_genre = k

    res_df.at[i, "genre"] = best_genre

    best_instrument = ""
    instrument_max = 0
    for k, v in instruments.items():
        max_val = 0
        for val in v:
            if df.at[i, val] > max_val:
                max_val = df.at[i, val]

        res_df.at[i, k] = max_val
        if max_val > instrument_max:
            instrument_max = max_val
            best_instrument = k

    res_df.at[i, "instrument"] = best_instrument

print(file_name)
new_file_name = file_name.split('.')[0]
res_df.to_csv(new_file_name + '.csv', index=False)
