import gurobipy as gp
from gurobipy import GRB
import math
import numpy as np


def max_nash_welfare_ilp(vals, is_divisible=None):
    """
    Assumes that an assignment that gives positive utility to all agents is feasible
    """
    vals = vals.copy()
    n, m = vals.shape
    if is_divisible is None:
        is_divisible = [False for _ in range(m)]
    div_items = [i for i in range(m) if is_divisible[i]]
    m_div = len(div_items)
    if m_div > 0:
        for i in range(n):
            nonzero_vals = vals[i, div_items] > 0
            if nonzero_vals.sum():
                min_nonzero_div = vals[i, div_items][nonzero_vals].min()
                vals[i] *= int(100 / min_nonzero_div) + 1
        # vals *= 100
    indiv_items = [i for i in range(m) if not is_divisible[i]]
    m_indiv = len(indiv_items)
    max_utilities = vals.sum(axis=1)
    with gp.Env(empty=True) as env:
        env.setParam("OutputFlag", 0)  # comment this line if you want the gurobi logs
        env.start()
        with gp.Model("NashWelfare", env=env) as model:
            # model.setParam('MIPFocus', 3)
            log_utils = model.addVars(
                n, lb=0, ub=int(np.log(np.max(max_utilities) + 1)) + 1,
                vtype=GRB.CONTINUOUS, name=f"log_u")
            model.setObjective(log_utils.sum(), GRB.MAXIMIZE)

            x_divisible = model.addVars(
                n, m_div, lb=0, ub=100, vtype=GRB.INTEGER, name="x")
            x_indivisible = model.addVars(n, m_indiv, vtype=GRB.BINARY, name="x")
            for j in range(m_div):
                model.addConstr(
                    gp.quicksum(x_divisible[i, j] for i in range(n)) == 100,
                    f"divisible_item_{j}_{div_items[j]}_is_allocated")
            for j in range(m_indiv):
                model.addConstr(
                    gp.quicksum(x_indivisible[i, j] for i in range(n)) == 1,
                    f"indivisible_item_{j}_{indiv_items[j]}_is_allocated")

            for i in range(n):
                u_i = gp.quicksum(x_indivisible[i, j] * vals[i, indiv_items[j]] for j in range(m_indiv))
                u_i += gp.quicksum(
                    x_divisible[i, j] * vals[i, div_items[j]] for j in range(m_div)
                ) / 100
                model.addConstr(u_i >= 1, f"agent_{i}_has_positive_utility")
                for k in range(1, int(max_utilities[i]) + 1, 2):
                    model.addConstr(
                        log_utils[i] <= math.log(k) + (math.log(k + 1) - math.log(k)) * (u_i - k),
                        name=f"log_utility_{i}_lte_{k}"
                    )

            model.optimize()
            if model.status == GRB.INFEASIBLE:
                raise RuntimeError("Infeasible. Nash welfare should be at least 0.")
            mnw_allocation = np.zeros((n, m))
            for j in range(m_indiv):
                for i in range(n):
                    mnw_allocation[i, indiv_items[j]] = int(x_indivisible[i, j].x > 0.5)
            for j in range(m_div):
                for i in range(n):
                    mnw_allocation[i, div_items[j]] = max(x_divisible[i, j].x / 100, 0)
            return mnw_allocation


if __name__ == '__main__':
    print(max_nash_welfare_ilp(np.array([
        [0, 2, 1],
        [0, 1, 2],
        [1, 0, 2]
    ]), [True, True, True]))

    from datetime import datetime

    n = 4
    m = 10
    for _ in range(1000):
        d1 = datetime.now()
        print("Begin", d1)
        print(
            max_nash_welfare_ilp(
                np.random.multinomial(1000, [1/m]*m, size=n),
                np.random.multinomial(1, [1/m]*m)
            )  # #np.random.randint(0, 2, m))
        )
        d2 = datetime.now()
        print("End", d2, "duration", d2 - d1)
