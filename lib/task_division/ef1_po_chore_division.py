import numpy as np
from collections import deque


class EF1POChores(object):
    EPSILON = 1e-12

    def __init__(self, vals, supplies=None, log_verbose=False):
        self.vals = np.array(vals)
        assert np.max(self.vals) < 0

        self.n, self.m = self.vals.shape
        self.supplies = np.array(supplies, dtype=int) if supplies is not None else np.ones(self.m, dtype=int)
        self.price = None
        self.alloc = None

        self.log_verbose = log_verbose

        self.steps_run = 0
        self.all_steps_run = 0

    def log(self, *args):
        if self.log_verbose or self.all_steps_run > 1000:
            # print(self.vals)
            print(*args)

    def pain_per_bucks_of(self, i):
        return -self.vals[i] / self.price

    def pain_per_buck(self, i, j):
        return -self.vals[i, j] / self.price[j]

    def calc_min_pain_per_buck_ratios(self):
        return np.min(-self.vals / self.price, axis=1)

    def spending_of(self, i):
        return self.alloc[i] @ self.price

    def utility_of(self, i):
        return self.vals[i] @ self.alloc[i]

    def calc_utilities(self):
        return np.sum(self.vals * self.alloc, axis=1)

    def calc_utilities_upto_one(self):
        return np.sum(self.vals * self.alloc, axis=1) - np.min(self.vals * (self.alloc > 0), axis=1)

    def calc_spendings(self):
        return self.alloc @ self.price

    def calc_all_spendings_upto_one(self):
        return self.calc_spendings() - np.max((self.alloc > 0) * self.price, axis=1)

    def all_price_ef1(self):
        ls = self.calc_spendings().min()
        hs1 = self.calc_all_spendings_upto_one().max()
        return ls + self.EPSILON >= hs1

    @staticmethod
    def __str_column_matrix(x):
        return list(map(str, x.tolist()))

    def print_state(self):
        if not self.log_verbose:
            return

        self.log(f"/*- State @{self.all_steps_run}")
        self.log(f"\tPrices:\t\t{self.__str_column_matrix(self.price)}")
        self.log(f"\tAllocation:\t{self.__str_column_matrix(self.alloc)}")
        self.log(f"\tSpendings:\t{self.__str_column_matrix(self.calc_spendings())}")
        self.log(f"\tUtilities:\t{self.__str_column_matrix(self.calc_utilities())}")
        self.log(f"\tMPB:\t\t{self.__str_column_matrix(self.calc_min_pain_per_buck_ratios())}")
        self.log("--- State */")

    def check_ef1(self):
        u_upto_one = self.calc_utilities_upto_one()
        for i1 in range(self.n):
            for i2 in range(self.n):
                utility_i1_for_i2 = self.vals[i1] @ self.alloc[i2]
                if u_upto_one[i1] < utility_i1_for_i2:
                    self.log("EF1 not satisfied. ", i1, " envies ", i2, " utility: ",
                             u_upto_one[i1], " < ", utility_i1_for_i2)
                    self.log("Alloc: ", self.alloc)
                    return False
        return True

    def next_step(self):
        self.all_steps_run += 1

    def ef1_po(self, **kwargs):
        if 'log_verbose' in kwargs:
            self.log_verbose = kwargs['log_verbose']

        self.log(f"EF1 + PO for:\n{self.vals}")

        # initialization
        p = (-np.max(self.vals, axis=0))
        self.price = p / p.sum()
        self.alloc = np.zeros(self.vals.shape, dtype=int)
        self.alloc[np.argmax(self.vals, axis=0), np.arange(self.vals.shape[1])] = self.supplies

        # if self.all_price_ef1():
        #     return self.alloc

        while True:
            self.log(f"############# \t Step #{self.steps_run} \t #############")
            self.print_state()

            # Phase 2
            self.log(f"#{self.steps_run}: Phase 2 started")
            while True:
                self.next_step()
                made_swap, hierarchy_set = self.ls_hierarchy_swap()
                if not made_swap:
                    break
                else:
                    self.print_state()

            self.log(f"#{self.steps_run}: Phase 2 ended")

            if self.all_price_ef1():
                self.log(f"Run for {self.all_steps_run} steps and {self.steps_run} price rises")
                assert self.check_ef1()
                return self.alloc

            # Phase 3

            # alpha calculation
            self.log(f"#{self.steps_run}: Phase 3 started")
            min_pb = self.calc_min_pain_per_buck_ratios()
            hierarchy = list(hierarchy_set)
            total_alloc_to_hierarchy = self.alloc[hierarchy].sum(axis=0)
            items_outside_hierarchy = np.where(total_alloc_to_hierarchy == 0)[0]
            alpha = np.min(
                (
                        -self.vals[np.ix_(hierarchy, items_outside_hierarchy)] / self.price[items_outside_hierarchy]
                ).T / min_pb[hierarchy]
            )
            self.log("Price rise of factor: ", alpha, " hierarchy: ", hierarchy_set)

            # price rise
            self.price[items_outside_hierarchy] *= alpha

            self.price /= self.price.sum()

            self.log(f"#{self.steps_run}: Phase 3 ended")

            self.steps_run += 1
            self.next_step()

    def ls_hierarchy_swap(self):
        all_spendings = self.calc_spendings()
        ls_spending = all_spendings.min()
        ls_list = np.where(all_spendings <= ls_spending + self.EPSILON)[0].tolist()
        min_pbs = self.calc_min_pain_per_buck_ratios()

        hierarchy_queue = deque(ls_list)
        remaining = set(range(self.n)) - set(ls_list)
        hierarchy = set()
        while len(hierarchy_queue):
            v = hierarchy_queue.pop()
            hierarchy.add(v)

            pbs = self.pain_per_bucks_of(v)
            for j in np.where(pbs <= min_pbs[v] + self.EPSILON)[0]:
                for u in set(np.where(self.alloc[:, j] > 0)[0]) & remaining:
                    amount_of_price_envy = self.spending_of(u) - ls_spending
                    if amount_of_price_envy <= self.price[j] + self.EPSILON:
                        hierarchy_queue.appendleft(u)
                        remaining.remove(u)
                    else:
                        num_copies = self.alloc[u, j]
                        num_swaps = min(int(
                            (amount_of_price_envy + self.EPSILON) / self.price[j]
                        ), num_copies)
                        if num_swaps * self.price[j] + self.EPSILON >= amount_of_price_envy:
                            num_swaps -= 1
                        self.log(
                            f"Note: Num swaps: {num_swaps}, Agent-{u} ({self.spending_of(u)}) -> Chore-{j} ({self.price[j]}) ->"
                            f" Agent-{v} ({self.spending_of(v)}) while ls is Agents-{ls_list} ({ls_spending})")
                        assert num_swaps > 0
                        self.alloc[u, j] -= num_swaps
                        self.alloc[v, j] += num_swaps
                        return True, None
        return False, hierarchy


def find_ef1_po_chores(vals, **kwargs):
    return EF1POChores(vals, **kwargs).ef1_po()


if __name__ == '__main__':
    for _i in range(1000):
        alg = EF1POChores(-np.random.randint(1, 100, size=(5, 15)))
        alc = alg.ef1_po(log_verbose=False)
        print(_i)
