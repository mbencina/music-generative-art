# Generative art based on music  
A generative art heavily influenced by the currently played song.  

## Running the visualization  
open gen_art.pde and run it (for that you need to download [Processing](https://processing.org/download/))  

for a different song you can change the songPath variable in line 62  

if you have a good GPU you can also uncomment line 261 for a special effect :)  

## Running with your music  
- add a music file of your choice to gen_art/extracting/music/ folder  
- [generate](#generating-new-csv-files) a new CSV file  
- change songPath variable to your song in line 62 in gen_art.pde   
- [run](#running-the-visualization) the visualization  

## Generating new CSV files
- install requirements listed in requirenments.txt (pip install -r requirements.txt)  
- change the file_name variable to the name of desired song in line 10 in extract.py
- run extract.py
