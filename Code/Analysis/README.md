# Analysis

This folder contains scripts for downstream analyses using the ReCAnt database and processed data. All additional dependency files required to run each script are provided in the `external_data/` subfolder within each code folder.

---

## Subfolders

### Fate_and_solubility
Scripts for chemical fate analysis using partition coefficient data.

| File | Description |
|---|---|
| `fate_analysis.ipynb` | Performs fate analysis using partition coefficient data to assess the distribution of aquaculture chemicals across environmental media |

---

### Scaffold_analysis
Scripts for scaffold-based structural analysis and visualisation of aquaculture chemicals.

| File | Description |
|---|---|
| `scaffold_cloud.ipynb` | Constructs scaffold clouds and generates heatmaps of chemical scaffolds against regulations, therapeutic actions, and toxic effects |
| `external_data/2D_structures.sdf` | 2D chemical structures in SDF format |
| `external_data/3D_structures.sdf` | 3D chemical structures in SDF format |
| `external_data/combined_regulations.tsv` | Combined regulatory information used for heatmap generation |

---

### SSD_computation
Scripts for the construction and processing of species sensitivity distributions (SSDs).

| File | Description |
|---|---|
| `ssd_data_filtration.ipynb` | Filters ecotoxicity data suitable for SSD construction |
| `acute_ssd_automated.R` | Constructs SSDs for acute toxicity data |
| `chronic_ssd_automated.R` | Constructs SSDs for chronic toxicity data |
| `processing_ssd_results.ipynb` | Processes and summarises SSD outputs |
| `external_data/ssd_chemicals.tsv` | List of chemicals for which SSDs are constructed |
| `external_data/ssd_input_acute_data.tsv` | Filtered acute toxicity data used as input for SSD construction |
| `external_data/ssd_input_chronic_data.tsv` | Filtered chronic toxicity data used as input for SSD construction |

---

### Trophic_transfer_analysis
Scripts for food web-based trophic transfer analysis of aquaculture chemicals.

| File | Description |
|---|---|
| `trophic_transfer.py` | Performs trophic transfer analysis across food web networks |
| `ssd_foodweb.ipynb` | Integrates SSD outputs with the filtered food web network for trophic transfer analysis |
| `external_data/acute_averaged_hc05_all_chemicals.tsv` | Averaged HC05 values from acute SSD analysis used as input |
| `external_data/chronic_averaged_hc05_all_chemicals.tsv` | Averaged HC05 values from chronic SSD analysis used as input |

---