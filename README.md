# A comprehensive resource on chemicals used in aquaculture and their ecotoxicity 

## Contributors

- [Shreyes Rajan Madgaonkar](https://github.com/mshreyes)

## Reference

This repository is associated with the manuscript: 
Shreyes Rajan Madgaonkar, Shrish Vashishth, Nikhil Chivukula, Vasavi Garisetti, Shambanagouda Rudragouda Marigoudar, Krishna Venkatarama Sharma & Areejit Samal\*, *[A comprehensive resource on chemicals used in aquaculture and their ecotoxicity](https://www.biorxiv.org/content/10.64898/2026.01.26.701529)* bioRxiv 2026.01.26.701529 (2026).
(\* Corresponding author: [asamal@imsc.res.in](mailto:asamal@imsc.res.in)) 


---

## Repository Structure

```
.
├── Code
│   ├── Analysis
│   │   ├── Fate_and_solubility
│   │   ├── Scaffold_analysis
│   │   ├── SSD_computation
│   │   └── Trophic_transfer_analysis
│   └── Data_processing
│       ├── CTD
│       ├── ECOTOX
│       ├── GloBI
│       └── Species_data
├── Data
└── README.md
```

---

## Data

The `Data/` folder contains the core ReCAnt database as flat `.tsv` files. These files represent both processed data ready for analysis and intermediate data used within processing pipelines. They serve as the primary data source across all code in this repository. See [`Data/README.md`](Data/README.md) for a description of each file.

---

## Code

All code is organised into two stages: **Data_processing** and **Analysis**. Raw data files are not provided due to size restrictions. However, additional dependency files required to run each script are provided in the `external_data/` subfolder within the respective code folder.

### Data_processing

Scripts to retrieve and process data from external databases and sources, producing input files for downstream analysis.

| Folder | Description |
|---|---|
| `CTD/` | Processing of data from the Comparative Toxicogenomics Database (CTD) |
| `ECOTOX/` | Parsing and processing of ecotoxicity data from the ECOTOX Knowledgebase |
| `GloBI/` | API-based retrieval of species interaction data from the Global Biotic Interactions (GloBI) database |
| `Species_data/` | API-based retrieval of taxonomic and biological data from NCBI and FishBase |

See [`Code/Data_processing/README.md`](Code/Data_processing/README.md) for further details.

### Analysis

Scripts to perform downstream analyses using the processed data.

| Folder | Description |
|---|---|
| `Fate_and_solubility/` | Fate analysis using partition coefficient data |
| `Scaffold_analysis/` | Scaffold cloud construction and heatmap visualisation against regulations, therapeutic actions, and toxic effects |
| `SSD_computation/` | Construction and processing of species sensitivity distributions (SSDs) for acute and chronic toxicity data |
| `Trophic_transfer_analysis/` | Trophic transfer analysis using food web networks and SSD outputs |

See [`Code/Analysis/README.md`](Code/Analysis/README.md) for further details.

---

Note: All codes were tested on Python version 3.11 and R version 4.4.2