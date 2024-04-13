import sys
import numpy as np

from ef1_po_chore_division import find_ef1_po_chores


class TaskDivisionInstanceLoader(object):
    def __init__(self):
        self.task_ids = None
        self.supplies = list()
        self.agent_ids = None
        self.vals = None

    def load_from_file(self, f_name):
        with open(f_name, 'r') as f:
            n = int(f.readline())
            m = int(f.readline())

            self.task_ids = list()
            for _ in range(m):
                t_id, t_supply = f.readline().split()
                t_id = int(t_id)
                self.task_ids.append(t_id)
                self.supplies.append(int(t_supply))
                assert self.supplies[-1] > 0

            self.agent_ids = list()
            self.vals = np.zeros((n, m), dtype=int)
            for i in range(n):
                for j in range(m):
                    a_id, t_id, cost = f.readline().split()
                    a_id, t_id = int(a_id), int(t_id)
                    cost = np.double(cost)
                    if j == 0:
                        self.agent_ids.append(a_id)
                    else:
                        assert self.agent_ids[-1] == a_id
                    assert t_id == self.task_ids[j]
                    self.vals[i, j] = -cost


def print_ef1_po_allocation(f_name):
    t_instance = TaskDivisionInstanceLoader()
    t_instance.load_from_file(f_name)
    alloc = find_ef1_po_chores(t_instance.vals, supplies=t_instance.supplies)
    n, m = t_instance.vals.shape
    for i in range(n):
        for j in range(m):
            if alloc[i, j] > 0:
                print(t_instance.agent_ids[i], t_instance.task_ids[j], alloc[i, j])


if __name__ == '__main__':
    f_name = sys.argv[1]
    # f_name = '../../tmp/41.txt'
    print_ef1_po_allocation(f_name)
