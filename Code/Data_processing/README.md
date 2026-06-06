# Data_processing

This folder contains scripts for retrieving and processing data from external databases and sources. The outputs feed into the `Data/` folder and the downstream analysis pipelines. Raw data files are not provided due to size restrictions. Additional dependency files required to run each script are provided in the `external_data/` subfolder within each code folder.

---

## Subfolders

### CTD
Scripts to process data downloaded from the [Comparative Toxicogenomics Database (CTD)](http://ctdbase.org/).

CTD version used: Oct 23, 2025
Gene2Go version used: Oct 1 2025

| File | Description |
|---|---|
| `extract_CTD_data.ipynb` | Processes raw CTD data to extract chemical–disease, chemical–gene, and chemical–phenotype associations for aquaculture-relevant chemicals |
| `external_data/aquaculture_relevant_species.txt` | List of aquaculture-relevant species used to filter CTD data |

---

### ECOTOX
Scripts to parse and process ecotoxicity data from the [ECOTOX Knowledgebase](https://cfpub.epa.gov/ecotox/).

ECOTOX version used: 11 Sept 2025

| File | Description |
|---|---|
| `parsing_raw_files.ipynb` | Parses raw ECOTOX data files |
| `processing_parsed_data.ipynb` | Processes parsed ECOTOX data to extract toxicity records for chemicals of interest |
| `external_data/aquaculture_relevant_species.txt` | List of aquaculture-relevant species used to filter ECOTOX data |
| `external_data/Unit_conversion_modified_aquaculture.tsv` | Unit conversion table for standardising toxicity values |
| `external_data/ecotox-terms-appendix.xlsx` | ECOTOX terminology reference |

---

### GloBI
Scripts to retrieve species interaction data from the [Global Biotic Interactions (GloBI)](https://www.globalbioticinteractions.org/) database via its API.

Data retrieved on: 17 Nov 2025

| File | Description |
|---|---|
| `GloBI_API.py` | API code snippet to retrieve biotic interaction data for aquaculture-relevant species |
| `external_data/aquaculture_relevant_species.txt` | List of aquaculture-relevant species used to query GloBI |

---

### Species_data
Scripts to retrieve taxonomic and biological data for aquaculture-relevant species from NCBI and FishBase.

Data retrieved on: 28 May 2026

| File | Description |
|---|---|
| `NCBI_API.py` | API code snippet to retrieve taxonomic data from NCBI |
| `fishbase_data.r` | API code snippet to retrieve biological and ecological data from FishBase |
| `external_data/spdata_std_for_fishbase_fetching.tsv` | Standardised species data used as input for FishBase queries |
