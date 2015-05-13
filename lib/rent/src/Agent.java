import java.util.*;

public class Agent extends Node {
	public Map<Room,Rational> value;
	private Set<Room> demand;
	public Rational indirect_util;
	
	public Agent(Map<Room, Rational> values, String label) {
		this.value = new HashMap<Room,Rational>(values);
		this.label = label;
		updateDemand();
	}
	
	public Set<Room> getDemand() {
		return demand;
	}
	
	
	public Set<Room> updateDemand() {
		Rational u;
		Map<Room,Rational> util = new HashMap<Room,Rational>();
		indirect_util = new Rational(Integer.MIN_VALUE,1);
		
		for (Room r : value.keySet()) {
			u = value.get(r).minus(r.price);
			util.put(r, u);
			if (u.compareTo(indirect_util)>0)
				indirect_util = u;
		}
		
		for (Room r : value.keySet()) {
			if (util.get(r).compareTo(indirect_util) != 0) {
				util.remove(r);
			}
		}
		demand = util.keySet();
		return demand;
	}

}
