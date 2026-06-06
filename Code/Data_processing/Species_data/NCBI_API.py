import time
import requests
import pandas as pd
from Bio import Entrez

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# configure entrez
Entrez.api_key = ""

spdata = pd.read_csv('./external_data/spdata_std_for_fishbase_fetching.tsv', sep='\t', dtype=str)

taxids = set(spdata['ncbi_taxid']) - {''}

# 1. Fetch from NCBI Taxonomy
def fetch_ncbi_taxonomy(taxid):
    result = {"ncbi_taxid": taxid}

    try:
        handle = Entrez.efetch(db="taxonomy", id=str(taxid), retmode="xml")
        records = Entrez.read(handle)
        handle.close()
        if records:
            rec = records[0]
            result["species_name"] = rec.get("ScientificName", "")
            result["rank"]         = rec.get("Rank", "")

            # Parse lineage for standard ranks
            ranks_wanted = {"kingdom", "phylum", "class", "order", "family", "genus"}
            for node in rec.get("LineageEx", []):
                r = node.get("Rank", "").lower()
                if r in ranks_wanted:
                    result[r] = node.get("ScientificName", "")
    except Exception as e:
        print(f"  NCBI taxonomy error for TaxID {taxid}: {e}")

    time.sleep(0.11)

    for db, key in [("nuccore", "ncbi_nucleotide_count"),
                    ("protein", "ncbi_protein_count"),
                    ("sra",     "ncbi_sra_count")]:
        try:
            handle = Entrez.esearch(db=db, term=f"txid{taxid}[Organism:exp]")
            record = Entrez.read(handle)
            handle.close()
            result[key] = int(record.get("Count", 0))
        except Exception as e:
            print(f"  NCBI {db} count error for TaxID {taxid}: {e}")
            result[key] = None
        time.sleep(0.11)

    try:
        handle = Entrez.esearch(db="assembly", term=f"txid{taxid}[Organism:exp]")
        search  = Entrez.read(handle)
        handle.close()
        result["ncbi_assembly_count"] = int(search.get("Count", 0))

        ids = search.get("IdList", [])
        if ids:
            time.sleep(0.11)
            handle  = Entrez.esummary(db="assembly", id=ids[0], report="full")
            summary = Entrez.read(handle, validate=False)
            handle.close()
            doc = summary["DocumentSummarySet"]["DocumentSummary"][0]
            result["ncbi_assembly_name"]      = doc.get("AssemblyName", "")
            result["ncbi_assembly_level"]     = doc.get("AssemblyStatus", "")
            result["ncbi_assembly_accession"] = doc.get("AssemblyAccession", "")
            result["ncbi_genome_size_mb"]     = round(
                int(doc.get("Meta", "0").split("<Total_length>")[-1]
                    .split("</Total_length>")[0]) / 1e6, 2
            ) if "<Total_length>" in doc.get("Meta", "") else None
    except Exception as e:
        print(f"  NCBI assembly error for TaxID {taxid}: {e}")

    time.sleep(0.11)

    return result


# 2. Main loop
results = []

for taxid in taxids:
    print(f"Processing TaxID: {taxid}")
    ncbi_data = fetch_ncbi_taxonomy(taxid)
    time.sleep(0.11)
    results.append(ncbi_data)

df = pd.DataFrame(results)

id_cols = ["ncbi_taxid", "species_name", "rank", "kingdom", "phylum",
           "class", "order", "family", "genus"]
other_cols = [c for c in df.columns if c not in id_cols]
df = df[id_cols + other_cols]

print(f"\nDone. {len(df)} records saved to species_data.csv")
print(df.head())