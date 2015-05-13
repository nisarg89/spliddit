import java.util.*;


public class Auction {
	public List<Agent> agents;
	public List<Room> rooms;
	public Set<Edge> matching;
	public Rational cost;
	
	public Auction(List<Agent> agents, List<Room> rooms, int cost) {
		this.agents = new ArrayList<Agent>(agents);
		this.rooms = new ArrayList<Room>(rooms);
		this.cost = new Rational(cost,1);
	}
	
	public int runAuction() {
		//if (!inputValid()) return 0;
		int iterations = 0;
		while (true) {
			iterations ++;
			//System.out.println("Updating Demand...");
			for (Agent a : agents) {
				a.updateDemand();
				//System.out.println("Demand for "+ a.label+": "+a.getDemand());
			}
			
			/*
			//for convergence, let's calculate sum of indirect utilities	
			Rational iu_sum = new Rational(0,1);
			for (Agent a : agents) {
				iu_sum = iu_sum.plus(a.indirect_util);
			}
			System.out.println("Iteration " + iterations + " (indirect util sum: "+iu_sum.toString()+")");
			*/
			
			//System.out.println("Computing OD set...");
			SDgraph graph = new SDgraph(rooms, agents);
			Set<Room> OD = graph.ODrooms();
			if (OD.isEmpty()) {
				matching = graph.maximalMatching();
				//System.out.println("Found matching of size " + matching.size());
				printMatching(iterations-1);
				return iterations-1;
			}
			
			//System.out.println("Computing J set...");
			Set<Agent> J = new HashSet<Agent>();
			for (Agent a : agents) {
				boolean inJ = true;
				for (Room r : a.getDemand()) {
					if (!OD.contains(r)) {
						inJ = false;
						break;
					}
				}
				if (inJ) J.add(a);
			}
			
			/*
			System.out.print("J set is ");
			for (Agent a : J) {
				System.out.print(a.label+ " ");
			}
			System.out.println();
			*/
			
			
			Set<Room> notOD = new HashSet<Room>(rooms);
			notOD.removeAll(OD);
			//System.out.println("Calculating minDiff..."+J.size()+" "+notOD.size());
			Rational minDiff = new Rational(Integer.MAX_VALUE,1);
			for (Agent j : J) {
				Rational maxNotOD = new Rational(Integer.MIN_VALUE,1);
				for (Room r : notOD) {
					if (j.value.get(r).minus(r.price).compareTo(maxNotOD) > 0) {
						maxNotOD = j.value.get(r).minus(r.price);
					}
				}
				if (j.indirect_util.minus(maxNotOD).compareTo(minDiff) < 0) {
					minDiff = j.indirect_util.minus(maxNotOD);
				} 
			}
			//System.out.println("minDiff is "+minDiff.toString()+". Updating prices...");
			
			Rational ODmult = new Rational(notOD.size(),rooms.size());
			Rational nODmult = new Rational(OD.size(),rooms.size());
			for (Room r : OD) {
				r.price = r.price.plus(ODmult.times(minDiff));
				//System.out.println("price of room "+r.label+" increased to "+r.price.toString());
			}
			for (Room r : notOD) {
				r.price = r.price.minus(nODmult.times(minDiff));
				//System.out.println("price of room "+r.label+" decreased to "+r.price.toString());
			}
		
		}
	}
	
	public void printMatching(int iters) {
		//checkEnvy();
		for (Edge e : matching) {
			System.out.println(e.agent.label + " " + e.room.label + " " + e.room.price.toDouble());
		}
	}
	
	public boolean checkEnvy() {
		for (Edge e : matching) {
			Rational util = e.agent.value.get(e.room).minus(e.room.price);
			for (Edge f : matching) {
				if (e.agent != f.agent){
					if (e.agent.value.get(f.room).minus(f.room.price).compareTo(util)>0) {
						//System.out.println("  Agent "+e.agent.label+" is envious of agent "+f.agent.label);
						return false;
					}
				}
			}
		}
		return true;
	}
	
	public boolean inputValid() {
		if (agents == null || rooms == null || agents.size() == 0 || rooms.size() == 0) {
			//System.out.println("Need at least 1 room and 1 agent.");
			return false;
		}
		if (agents.size() != rooms.size()) {
			//System.out.println("Need the same number of rooms and agents.");
			return false;
		}
		for (Agent i : agents) {
			Rational sum = new Rational(0,1);
			for (Room r : rooms){
				sum = sum.plus(i.value.get(r));
				//System.out.println("Agent " + i.label + " values room " + r.label + " at " + i.value.get(r).toString());
			}
			if (sum.compareTo(cost) < 0) {
				//System.out.println("Each agent must have sum of values equal to the cost.");
				return false;
			}
		}
		return true;
	}
	
	public boolean outputValid() {
		return true;
	}
}
