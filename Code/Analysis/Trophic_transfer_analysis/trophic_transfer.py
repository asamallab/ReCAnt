import pandas as pd
import numpy as np
import networkx as nx
from collections import defaultdict

def analyze_chemical_predator_paths(G, node_table):
    """
    This function analyzes chemical -> prey -> predator paths where shortest path length >= 2
    (i.e., at least one intermediate prey node exists).

    Sensitive edges (Type == 'Sensitive') are removed before analysis.
    A prey node left with in-degree 0 after that removal is also dropped
    (cascade), since it can no longer receive a chemical transfer.

    Only chemicals and predators connected via such paths are counted.
    Top prey species by path frequency are reported.
    """

    G_filtered = nx.DiGraph()
    G_filtered.add_nodes_from(G.nodes(data=True))
    for u, v, data in G.edges(data=True):
        if data.get('Type') != 'Sensitive':
            G_filtered.add_edge(u, v, **data)

    sensitive_removed = G.number_of_edges() - G_filtered.number_of_edges()

    prey_set_full = set(node_table[node_table['node_type'].isin(['prey', 'both'])]['node'])
    cascade_removed = []
    while True:
        to_drop = [n for n in prey_set_full if n in G_filtered and G_filtered.in_degree(n) == 0]
        if not to_drop:
            break
        for n in to_drop:
            cascade_removed.append(n)
            G_filtered.remove_node(n)
            prey_set_full.discard(n)

    isolates = list(nx.isolates(G_filtered))

    print(" Filtering stats ")
    print(f"  Sensitive edges removed : {sensitive_removed}")
    print(f"  Prey nodes cascaded out : {len(cascade_removed)}{f'  {sorted(cascade_removed)}' if cascade_removed else ''}")
    print(f"  Degree-0 isolates left  : {len(isolates)}{f'  {sorted(isolates)}' if isolates else ''}")
    print(f"  Nodes after filtering   : {G_filtered.number_of_nodes()}  (was {G.number_of_nodes()})")
    print(f"  Edges after filtering   : {G_filtered.number_of_edges()}  (was {G.number_of_edges()})")

    # - Node type sets -
    chemicals = set(node_table[node_table['node_type'] == 'chemical']['node'])
    prey      = set(node_table[node_table['node_type'].isin(['prey', 'both'])]['node'])
    predators = set(node_table[node_table['node_type'].isin(['predator', 'both'])]['node'])

    # - Filter to pairs with shortest path length >= 2 -
    chemical_to_predators = defaultdict(set)
    pred_from_chem        = defaultdict(set)
    prey_path_counts      = defaultdict(int)

    for chem in chemicals:
        for pred in predators:
            try:
                path = nx.shortest_path(G_filtered, chem, pred)
            except (nx.NetworkXNoPath, nx.NodeNotFound):
                continue

            if len(path) - 1 < 2:
                continue

            chemical_to_predators[chem].add(pred)
            pred_from_chem[pred].add(chem)

            for node in path[1:-1]:
                if node in prey:
                    prey_path_counts[node] += 1

    # - Chemical ranking -
    chemical_impact = {c: len(preds) for c, preds in chemical_to_predators.items()}
    summary_df = (
        pd.DataFrame([
            {'chemical': c, 'num_predators_affected': n}
            for c, n in chemical_impact.items()
        ])
        .sort_values('num_predators_affected', ascending=False)
        .reset_index(drop=True)
    )
    print("\n Chemicals ranked by predators affected (shortest path >= 2) ")
    print(summary_df.head(10).to_string(index=False))

    # - Predator ranking -
    pred_impact = {p: len(chems) for p, chems in pred_from_chem.items()}
    pred_df = (
        pd.DataFrame([
            {'predator': p, 'num_chemicals_affecting': n}
            for p, n in pred_impact.items()
        ])
        .sort_values('num_chemicals_affecting', ascending=False)
        .reset_index(drop=True)
    )
    print("\n Predators ranked by chemicals affecting them (shortest path >= 2) ")
    print(pred_df.head(10).to_string(index=False))

    if pred_impact:
        max_pred = max(pred_impact, key=pred_impact.get)
        min_pred = min(pred_impact, key=pred_impact.get)
        print(f"\nMost impacted predator : {max_pred} ({pred_impact[max_pred]} chemicals)")
        print(f"Least impacted predator: {min_pred} ({pred_impact[min_pred]} chemicals)")

    # - Top prey by appearance in qualifying shortest paths 
    prey_df = (
        pd.DataFrame([
            {'prey': node, 'path_count': cnt}
            for node, cnt in prey_path_counts.items()
        ])
        .sort_values('path_count', ascending=False)
        .reset_index(drop=True)
    )
    print("\n Top 10 prey species in qualifying shortest paths ")
    print(prey_df.head(10).to_string(index=False))

    return {
        'chemical_to_predators': dict(chemical_to_predators),
        'pred_from_chem':        dict(pred_from_chem),
        'chemical_ranking':      summary_df,
        'predator_ranking':      pred_df,
        'prey_path_counts':      prey_df,
    }