import gurobipy as gp
from gurobipy import GRB
import math
import numpy as np


def max_nash_welfare_ilp(vals):
    """
    Assumes that an assignment that gives positive utility to all agents is feasible
    """
    n, m = vals.shape
    max_utilities = vals.sum(axis=1)
    with gp.Env(empty=True) as env:
        env.setParam("OutputFlag", 0)  # comment this line if you want the gurobi logs
        env.start()
        with gp.Model("NashWelfare", env=env) as model:
            log_utils = model.addVars(
                n, lb=0.0, ub=int(np.log(np.max(max_utilities) + 1)) + 1,
                vtype=GRB.CONTINUOUS, name=f"log_u")
            model.setObjective(log_utils.sum(), GRB.MAXIMIZE)

            x = model.addVars(n, m, vtype=GRB.BINARY, name="x")
            for j in range(m):
                model.addConstr(gp.quicksum(x[i, j] for i in range(n)) == 1, f"item_{j}_is_allocated")
            for i in range(n):
                u_i = gp.quicksum(x[i, j] * vals[i, j] for j in range(m))
                model.addConstr(u_i >= 1, f"agent_{i}_has_positive_utility")
                for k in range(1, int(max_utilities[i]) + 1, 2):
                    model.addConstr(
                        log_utils[i] <= math.log(k) + (math.log(k + 1) - math.log(k)) * (u_i - k),
                        name=f"log_utility_{i}_lte_{k}"
                    )
            model.optimize()
            if model.status == GRB.INFEASIBLE:
                raise RuntimeError("Infeasible. Nash welfare should be at least 0.")
            mnw_allocation = [
                [int(x[i, j].x > 0.5) for j in range(m)]
                for i in range(n)
            ]
            return np.array(mnw_allocation)


if __name__ == '__main__':
    print(max_nash_welfare_ilp(np.array([
        [0, 2, 1],
        [0, 1, 2],
        [1, 0, 2]
    ])))
