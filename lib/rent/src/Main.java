import ilog.concert.IloException;
import ilog.concert.IloLinearNumExpr;
import ilog.concert.IloNumVar;
import ilog.cplex.IloCplex;

import java.io.*;
import java.util.*;


public class Main {
	
	public static void main(String[] args) throws NumberFormatException, IOException {
		//for (int i = 1; i < 200000; i++) {
			//Random rand = new Random();
			//testMonotonic(rand.nextInt(7)+3);
		//}
		//fileAuctions();
		//randAuctions(151,250,3);
		//randAuction(5).runAuction(0);
		//fileAuction(args[0]);
		maximinUtility(args[0]);
	}
	
	
	
	/* Find envy-free solution maximizing the minimum utility */
	/* For setting up CPLEX: https://www.youtube.com/watch?v=sf59_7r8QSY */
	public static void maximinUtility(String file_name) throws NumberFormatException, IOException {
		BufferedReader in = new BufferedReader(new FileReader(file_name));
		int n = Integer.parseInt(in.readLine());
		int rent = Integer.parseInt(in.readLine());
		Map<String, Map<String, Integer>> values = new HashMap<String, Map<String, Integer>>();
		Set<String> agent_set = new HashSet<String>();
		Set<String> room_set = new HashSet<String>();
		
		for (int i = 0; i < n*n; i++) {
			String[] tokens = in.readLine().split(" ");
			String agent_id = tokens[0];
			agent_set.add(agent_id);
			String room_id = tokens[1];
			room_set.add(room_id);
			int value = (int)Double.parseDouble(tokens[2]);
			if (!values.containsKey(agent_id)) {
				values.put(agent_id, new HashMap<String, Integer>());
			}
			values.get(agent_id).put(room_id, value);
		}
		
		try {
			// first find a welfare-maximizing allocation
			Map<String, String> allocation = welfareMaximize(values, agent_set, room_set);
			
			// now find nonnegative price vector if possible
			Map<String, Double> prices = maximinPrices(values, agent_set, room_set, allocation, rent, true);
			if (prices == null) {
				prices = maximinPrices(values, agent_set, room_set, allocation, rent, false);
				if (prices == null) {
					System.out.println("failure");
					return;
				}
			}
			for (String agent : agent_set) {
				String room = allocation.get(agent);
				double price = prices.get(room);
				System.out.println(agent + " " + room + " " + price);
			}
			
		} catch (IloException e) {
			System.out.println("failure");
		}
	}
	
	
	private static Map<String, String> welfareMaximize(Map<String, Map<String, Integer>> values, Set<String> agent_set, Set<String> room_set) throws NumberFormatException, IOException, IloException{
		IloCplex cplex = new IloCplex();
	    Map<String, Map<String, IloNumVar>> variables = new HashMap<String, Map<String, IloNumVar>>();
	    for (String a : agent_set) {
	    	variables.put(a, new HashMap<String, IloNumVar>());
	    	for (String r : room_set) {
	    		variables.get(a).put(r, cplex.boolVar("x_" + a + "," + r));
	    	}
	    }
	    
	    // objective is total welfare
	    IloLinearNumExpr objective = cplex.linearNumExpr();
	    for (String a : agent_set) {
	    	for (String r : room_set) {
	    		objective.addTerm(values.get(a).get(r), variables.get(a).get(r));
	    	}
	    }
	    cplex.addMaximize(objective);
	    
	    // each agent assigned 1 room
	    for (String a : agent_set) {
	    	IloLinearNumExpr constraint = cplex.linearNumExpr();
	    	for (String r : room_set) {
	    		constraint.addTerm(1, variables.get(a).get(r));
	    	}
	    	cplex.addEq(constraint, 1);
	    }
	    
	    // each room assigned 1 agent
	    for (String r : room_set) {
	    	IloLinearNumExpr constraint = cplex.linearNumExpr();
	    	for (String a : agent_set) {
	    		constraint.addTerm(1, variables.get(a).get(r));
	    	}
	    	cplex.addEq(constraint, 1);
	    }
	    
	    cplex.setOut(null);
	    if (cplex.solve()) {
	    	// get assignment
	    	Map<String, String> assignment = new HashMap<String, String>();
	    	for (String a : agent_set) {
	    		for (String r : room_set) {
	    			if (cplex.getValue(variables.get(a).get(r)) == 1) {
	    				assignment.put(a, r);
	    			}
	    		}
	    	}
	    	return assignment;
	    }
	    return null;
	}
	
	private static Map<String, Double> maximinPrices(Map<String, Map<String, Integer>> values, Set<String> agent_set, Set<String> room_set, Map<String, String> assignment, int rent, boolean nonnegative_prices) throws IloException {
		IloCplex cplex = new IloCplex();
    	Map<String, IloNumVar> price_variables = new HashMap<String, IloNumVar>();
    	for (String r : room_set) {
    		if (nonnegative_prices) {
    			price_variables.put(r, cplex.numVar(0, rent, "p_" + r));
    		} else {
    			price_variables.put(r, cplex.numVar(-Double.MAX_VALUE, Double.MAX_VALUE, "p_" + r));
    		}
    	}
    	
    	// objective is maximize minimum utility or minimize negative of minimum utility
    	IloNumVar min_utility = cplex.numVar(0, Double.MAX_VALUE, "y");
    	IloLinearNumExpr objective = cplex.linearNumExpr();
    	objective.addTerm(-1, min_utility);
    	cplex.addMinimize(objective);
    	
    	// ensure prices sum to rent
    	IloLinearNumExpr constraint = cplex.linearNumExpr();
    	for (IloNumVar v : price_variables.values()) {
    		constraint.addTerm(1, v);
    	}
    	cplex.addEq(constraint, rent);
    	
    	// ensure envy-free
    	for (String i : agent_set) {
    		for (String j : agent_set) {
    			if (i.equals(j)) continue;
    			constraint = cplex.linearNumExpr();
    			constraint.addTerm(price_variables.get(assignment.get(i)), -1);
    			constraint.addTerm(price_variables.get(assignment.get(j)), 1);
    			cplex.addGe(constraint, values.get(i).get(assignment.get(j)) - values.get(i).get(assignment.get(i)));
    		}
    	}
    	
    	// bound minimim utility
    	for (String i : agent_set) {
			constraint = cplex.linearNumExpr();
			constraint.addTerm(price_variables.get(assignment.get(i)), 1);
			constraint.addTerm(min_utility, 1);
			cplex.addLe(constraint, values.get(i).get(assignment.get(i)));
    	}
    	
    	cplex.setOut(null);
	    if (cplex.solve()) {
	    	Map<String, Double> prices = new HashMap<String, Double>();
	    	for (String i : agent_set) {
	    		String room = assignment.get(i);
	    		prices.put(room, cplex.getValue(price_variables.get(room)));
	    	}
	    	return prices;
	    } 
	    return null;
	}
	
/*	 Run ASU Algorithm 
	public static void fileAuction(String file_name) throws NumberFormatException, IOException {
		Map<String, Room> rooms = new HashMap<String, Room>();
		Map<String, Agent> agents = new HashMap<String, Agent>();
		
		BufferedReader in = new BufferedReader(new FileReader(file_name));
		int n = Integer.parseInt(in.readLine());
		int cost = Integer.parseInt(in.readLine());
		
		for (int i = 0; i < n*n; i++) {
			String[] tokens = in.readLine().split(" ");
			String agent_id = tokens[0];
			String room_id = tokens[1];
			float price = Float.parseFloat(tokens[2]);
			
			if (!rooms.containsKey(room_id)) {
				rooms.put(room_id, new Room(room_id, new Rational(cost,n)));
			}
			if (!agents.containsKey(agent_id)) {
				agents.put(agent_id, new Agent(new HashMap<Room, Rational>(), agent_id));
			}
			agents.get(agent_id).value.put(rooms.get(room_id), new Rational((int)(10000 * price), 10000));
		}
		Auction auc = new Auction(new ArrayList<Agent>(agents.values()), new ArrayList<Room>(rooms.values()), cost);
		auc.runAuction();
	}
	
	
	public static void testMonotonic(int n) {
		Auction base = randAuction(n);
		base.runAuction();
		
		Edge e = base.matching.iterator().next();
		e.agent.value.put(e.room, e.agent.value.get(e.room).plus(new Rational(2,1)));
		//System.out.println("Agent " + e.agent.label + " now values room " + e.room.label + " at " + e.agent.value.get(e.room));
		Room other_room = base.rooms.get(0);
		if (other_room == e.room){
			other_room = base.rooms.get(1);
		}
		e.agent.value.put(other_room, e.agent.value.get(other_room).minus(new Rational(2,1)));
		base.runAuction();
		
		//find new room for agent
		Room newroom = null;
		for (Edge f : base.matching){
			if (e.agent == f.agent) {
				newroom = f.room;
			}
		}
		if (e.room != newroom) {
			System.out.println("Counter Example!");
		}
	}
	
	public static Auction randAuction(int n) {
		List<Agent> agents = new ArrayList<Agent>();
		List<Room> rooms = new ArrayList<Room>();
		Map<Room,Rational> values = new HashMap<Room,Rational>();

		int cost = 1000;
		for (int r = 1; r <= n; r++) {
			rooms.add(new Room(""+r, new Rational(cost,n)));
		}
		for (int a = 1; a <= n; a++) {
			values = new HashMap<Room,Rational>();
			int[] part = partition(cost, n);
			for (int r = 0; r < rooms.size(); r++) {
				values.put(rooms.get(r),new Rational(part[r],1));
			}
			agents.add(new Agent(values,""+a));
		}
		
		for (Room r : rooms) {
			r.price = new Rational(cost,n);
		}
		
		return new Auction(agents, rooms, cost);
		
	}
	
	public static int[] partition(int sum, int parts) {
		Random rand = new Random();
		int[] arr = new int[parts];
		for (int i = 0; i < parts; i++) {
			arr[i] = rand.nextInt(sum);
		}
		Arrays.sort(arr);
		for (int i = parts - 2; i > 0; i--) {
			arr[i] -= arr[i-1];
		}
		arr[parts-1] = sum - arr[parts-2];
		
		boolean contains_zero = false;
		for (int i = 0; i < parts; i++) {
			if (arr[i] == 0) contains_zero = true;
		}
		if (contains_zero) return partition(sum,parts);
		return arr;		
	}
	
	public static void randAuctions(int n_min, int n_max, int trials_per_n) {
		List<Agent> agents;
		List<Room> rooms;
		Map<Room,Rational> values;
		Random rand = new Random();
		double avgIters[] = new double[n_max-n_min+1];
		double maxIters[] = new double[n_max-n_min+1];
		for (int n = n_min; n<=n_max;n++) {
			avgIters[n-n_min] = 0;
			maxIters[n-n_min] = 0;
			for (int i = 0; i < trials_per_n; i++) {
				//System.out.println("Auction " + ((n-n_min)*trials_per_n + i + 1));
				//System.out.println(n);
				
				int cost = 1000;
				rooms = new ArrayList<Room>();
				for (int r = 1; r <= n; r++) {
					rooms.add(new Room(""+r, new Rational(cost,n)));
				}
				agents = new ArrayList<Agent>();
				for (int a = 1; a <= n; a++) {
					values = new HashMap<Room,Rational>();
					for (int r = 0; r < rooms.size(); r++) {
						int rint = (int)(100*rand.nextGaussian()+500);
						//System.out.print(rint+" ");
						values.put(rooms.get(r),new Rational(rint,1));
					}
					//System.out.println();
					agents.add(new Agent(values,""+a));
				}
				
				Rational sum;
				Rational minsum = new Rational(Integer.MAX_VALUE,1);
				//get min total value
				for (Agent a : agents) {
					sum = new Rational(0,1);
					for (Room r : rooms)
						sum = sum.plus(a.value.get(r));
					if (sum.compareTo(minsum)<0) minsum = sum;
				}
				
				for (Room r : rooms) {
					r.price = minsum.divides(new Rational(n,1));
				}
				
				Auction auc = new Auction(agents, rooms, (int)minsum.toDouble());
				int iters = auc.runAuction( ); //(n-n_min)*trials_per_n + i + 1 
				avgIters[n-n_min] += iters;
				maxIters[n-n_min] = Math.max(iters, maxIters[n-n_min]);
			}
			avgIters[n-n_min] /= trials_per_n;
		}
		
		for (int i = n_min; i <= n_max; i++) {
			System.out.println("Average iterations for " + i + " agents: " + avgIters[i-n_min]);
			System.out.println("Maximum iterations for " + i + " agents: " + maxIters[i-n_min]);
		}
	}
*/
}
