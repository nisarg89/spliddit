import gurobipy as gp
from gurobipy import GRB
import numpy as np
import networkx as nx


def fair_rent_sharing(vals, rent):
    max_welfare_matching = max_weight_matching(vals)
    prices = find_maximin_prices(vals, max_welfare_matching, rent, True)
    if prices is None:
        prices = find_maximin_prices(vals, max_welfare_matching, rent, False)
    return max_welfare_matching, prices


def max_weight_matching(vals):
    n, _m = vals.shape
    assert n == _m

    weighted_g = nx.Graph()

    def agent_node(x):
        return x

    def room_node(x):
        return n + x

    weighted_g.add_nodes_from([agent_node(i) for i in range(n)])
    weighted_g.add_nodes_from([room_node(j) for j in range(n)])
    weighted_g.add_edges_from([
        (agent_node(i), room_node(j), {'weight': vals[i, j]}) for i in range(n) for j in range(n)
    ])
    max_matching = nx.max_weight_matching(
        weighted_g, weight='weight', maxcardinality=True)
    return dict((min(x), max(x) - n) for x in max_matching)


def find_maximin_prices(vals, assignment, rent, non_negative_prices):
    n = vals.shape[0]
    with gp.Env(empty=True) as env:
        env.setParam("OutputFlag", 0)  # comment this line if you want the gurobi logs
        env.start()
        with gp.Model("RentPrices", env=env) as model:
            min_util = model.addVar(lb=0.0, vtype=GRB.CONTINUOUS, name="min_util")
            model.setObjective(min_util, GRB.MAXIMIZE)

            lb_price = 0.0 if non_negative_prices else -GRB.INFINITY

            price = model.addVars(n, lb=lb_price, vtype=GRB.CONTINUOUS, name="price")
            model.addConstr(price.sum() == rent, name="price_sum_to_rent")  # prices sum up to rent

            for i in range(n):
                room_i = assignment[i]
                u_i = vals[i, room_i] - price[room_i]
                model.addConstr(u_i >= min_util, name=f"min_util_of_{i}")  # min utility bounding

                for j in range(n):
                    if i == j:
                        continue
                    room_j = assignment[j]
                    u_i_room_j = vals[i, room_j] - price[room_j]
                    model.addConstr(u_i >= u_i_room_j, name=f"no_envy_{i}_to_{j}")  # envy-freeness

            model.optimize()
            if model.status == GRB.INFEASIBLE:
                return None

            return [price[i].x for i in range(n)]


if __name__ == '__main__':
    print(fair_rent_sharing(np.array(
        [
            [1, 0, 3],
            [3, 1, 1],
            [1, 2, 1],
        ]
    ), 3))
