import sys
import numpy as np

from mnw import find_mnw_allocation


class GoodsInstanceLoader(object):
    def __init__(self):
        self.goods_ids = None
        self.agent_ids = None
        self.g_divisibility = None
        self.vals = None

    def load_from_file(self, f_name):
        with open(f_name, 'r') as f:
            n = int(f.readline())
            m = int(f.readline())

            self.goods_ids = list()
            self.g_divisibility = list()
            for _ in range(m):
                g_id, g_type = f.readline().split()
                g_id = int(g_id)
                self.goods_ids.append(g_id)
                self.g_divisibility.append(g_type == 'indivisible')
                assert self.g_divisibility[-1]

            self.agent_ids = list()
            self.vals = np.zeros((n, m), dtype=int)
            for i in range(n):
                for j in range(m):
                    a_id, g_id, val = list(map(int, f.readline().split()))
                    if j == 0:
                        self.agent_ids.append(a_id)
                    else:
                        assert self.agent_ids[-1] == a_id
                    assert g_id == self.goods_ids[j]
                    self.vals[i, j] = val


def print_mnw_allocation(f_name):
    g_instance = GoodsInstanceLoader()
    g_instance.load_from_file(f_name)
    alloc = find_mnw_allocation(g_instance.vals)
    n, m = g_instance.vals.shape
    for i in range(n):
        for j in range(m):
            if alloc[i, j] > 0:
                print(g_instance.agent_ids[i], g_instance.goods_ids[j], alloc[i, j])


if __name__ == '__main__':
    f_name = sys.argv[1]
    print_mnw_allocation(f_name)
