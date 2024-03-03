import numpy as np
import networkx as nx

from mnw_ilp import max_nash_welfare_ilp


def find_max_subset_with_positive_utilities(vals):
    n, m = vals.shape
    pos_util_graph = nx.Graph()

    def agent_node(x):
        return x

    def item_node(x):
        return n + x

    pos_util_graph.add_nodes_from([agent_node(i) for i in range(n)], bipartite=0)
    pos_util_graph.add_nodes_from([item_node(j) for j in range(m)], bipartite=1)
    pos_util_graph.add_edges_from([
        (agent_node(i), item_node(j)) for i, j in np.argwhere(vals > 0)
    ])
    max_matching = nx.bipartite.maximum_matching(pos_util_graph, top_nodes=list(range(n)))
    return [i for i in max_matching.keys() if i < n]


def find_mnw_allocation(vals):
    subset_of_agents = find_max_subset_with_positive_utilities(vals)
    sub_vals = vals[subset_of_agents, :]
    mnw_allocation = max_nash_welfare_ilp(sub_vals)
    final_alloc = np.zeros(vals.shape)
    final_alloc[subset_of_agents, :] = mnw_allocation
    return final_alloc


if __name__ == '__main__':
    _vals = np.array([
        [0, 0, 3],
        [0, 0, 4],
        [0, 1, 0]
    ])
    print(find_mnw_allocation(_vals))
