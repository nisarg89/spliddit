from datetime import datetime
import numpy as np
import networkx as nx

from mnw_ilp import max_nash_welfare_ilp


def find_max_subset_with_positive_utilities(vals, is_divisible=None):
    n, m = vals.shape
    if is_divisible is None:
        is_divisible = [False for _ in range(m)]
    pos_util_graph = nx.Graph()

    def agent_node(x):
        return f'agent_{x}'

    def item_node(x, c=0):
        return f'item_{x}_{c}'

    pos_util_graph.add_nodes_from([agent_node(i) for i in range(n)], bipartite=0)
    for j in range(m):
        if not is_divisible[j]:
            j_nodes = [item_node(j)]
        else:
            j_nodes = [item_node(j, c) for c in range(100)]
        pos_util_graph.add_nodes_from(j_nodes, bipartite=1)
        for i in np.where(vals[:, j] > 0)[0]:
            pos_util_graph.add_edges_from([(agent_node(i), c) for c in j_nodes])
    max_matching = nx.bipartite.maximum_matching(pos_util_graph, top_nodes=[agent_node(i) for i in range(n)])
    return [i for i in range(n) if agent_node(i) in max_matching.keys()]


def find_mnw_allocation(vals, is_divisible=None):
    subset_of_agents = find_max_subset_with_positive_utilities(vals, is_divisible)
    sub_vals = vals[subset_of_agents, :]
    mnw_allocation = max_nash_welfare_ilp(sub_vals, is_divisible)
    final_alloc = np.zeros(vals.shape)
    final_alloc[subset_of_agents, :] = mnw_allocation
    return final_alloc


if __name__ == '__main__':
    _vals = np.array([
        [0, 0, 1],
        [0, 0, 4],
        [0, 1, 0]
    ])
    print(find_mnw_allocation(_vals, [False, False, True]))
