import pandas as pd
import numpy as np
import requests as rq

aquachem_df = pd.read_csv('./data/aquaculture_relevant_species.txt', dtype=str, header=None)
print(aquachem_df.shape)

species = set(list(aquachem_df[0])) - {''}

import json
df_all = pd.DataFrame(columns=['source_taxon_name', 'interaction_type', 'target_taxon_name'])

for k in species:
    url = "https://api.globalbioticinteractions.org/taxon/"
    taxon_id = str(k)
    full_url = url + taxon_id + "/eats"

    response = rq.get(url=full_url)
    
    r = json.loads(response.text)

    colnames = r['columns']
    data = r['data']

    df = pd.DataFrame(data, columns=colnames)
    df_all = pd.concat([df_all, df])

    print(str(k)+" done")

df_all = df_all.explode(column=['target_taxon_name'])

df_all.to_csv('../Output/food_web_data.tsv', sep='\t', index=False)