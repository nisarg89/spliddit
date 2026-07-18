import numpy as np

import sys

from rent_division import fair_rent_sharing


class RentInstanceLoader(object):
    def __init__(self):
        self.room_ids = None
        self.agent_ids = None
        self.vals = None
        self.rent = None

    def load_from_file(self, f_name):
        with open(f_name, 'r') as f:
            n = int(f.readline())
            self.rent = int(f.readline())
            self.vals = np.zeros((n, n), dtype=int)

            self.room_ids = dict()
            self.agent_ids = dict()
            for _ in range(n * n):
                a_id, r_id, v = f.readline().split()
                a_id = int(a_id)
                v = int(float(v))
                if a_id not in self.agent_ids:
                    self.agent_ids[a_id] = len(self.agent_ids)
                    assert len(self.agent_ids) <= n
                if r_id not in self.room_ids:
                    self.room_ids[r_id] = len(self.room_ids)
                    assert len(self.room_ids) <= n
                self.vals[self.agent_ids[a_id], self.room_ids[r_id]] = v
            assert len(self.agent_ids) == n and len(self.room_ids) == n


def solve_rent_division(f_name):
    r_loader = RentInstanceLoader()
    r_loader.load_from_file(f_name)
    matching, prices = fair_rent_sharing(r_loader.vals, r_loader.rent)
    if prices is None:
        print("failure")
        return
    reverse_to_room_id = {ind: room_id for room_id, ind in r_loader.room_ids.items()}
    for agent_id, a_ind in r_loader.agent_ids.items():
        assigned_room_ind = matching[a_ind]
        print(agent_id, reverse_to_room_id[assigned_room_ind], prices[assigned_room_ind])


if __name__ == '__main__':
    _f_name = sys.argv[1]
    solve_rent_division(_f_name)
