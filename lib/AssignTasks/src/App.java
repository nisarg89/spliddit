import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import ilog.concert.*;
import ilog.cplex.*;

public class App {

	public static void main(String[] args) throws NumberFormatException, IOException {
		Map<Integer, Map<Integer, Double>> values = new HashMap<Integer, Map<Integer, Double>>();
		Map<Integer, Integer> quantities = new HashMap<Integer, Integer>();
		
		// IO
		BufferedReader in = new BufferedReader(new FileReader(args[0]));
		int agents = Integer.parseInt(in.readLine());
	    int tasks = Integer.parseInt(in.readLine());
	    for (int i = 0; i < tasks; i++) {
	    	String[] tokens = in.readLine().split(" ");
	    	quantities.put(Integer.valueOf(tokens[0]), Integer.valueOf(tokens[1]));	    	
	    }
	    for (int i = 0; i < agents * tasks; i++) {
	    	String[] tokens = in.readLine().split(" ");
	    	int agent_id = Integer.valueOf(tokens[0]);
	    	int task_id = Integer.valueOf(tokens[1]);
	    	double value = Double.valueOf(tokens[2]);
	    	value /= quantities.get(task_id);
	    	if (!values.containsKey(agent_id)) {
	    		values.put(agent_id, new HashMap<Integer, Double>());
	    	}
	    	values.get(agent_id).put(task_id, value);
	    }
	    
	    // LP
	    
	    try {
	    	IloCplex cplex = new IloCplex();
	    	Map<Integer, Map<Integer, IloNumVar>> variables = new HashMap<Integer, Map<Integer, IloNumVar>>();
	    	Set<Integer> agent_set = values.keySet();
	    	Set<Integer> task_set = quantities.keySet();
	    	
	    	//variables: x_i,j is amount of task j assigned to agent i
	    	for (Integer i : agent_set) {
	    		variables.put(i, new HashMap<Integer, IloNumVar>());	
	    		for (Integer j : task_set) {
	    			variables.get(i).put(j, cplex.numVar(0, quantities.get(j), "x_"+i+","+j));
	    		}
	    	}
	    	
	    	// objective function: any player's utility
	    	int agent = agent_set.iterator().next();
			IloLinearNumExpr objective = cplex.linearNumExpr();
			for (Integer j : task_set) {
				objective.addTerm(values.get(agent).get(j), variables.get(agent).get(j));
			}
	    	cplex.addMinimize(objective);
	    	
	    	// constraints to ensure each item fully assigned
	    	for (Integer j : task_set) {
	    		IloLinearNumExpr constraint = cplex.linearNumExpr();
	    		for (Integer i : agent_set) {
	    			constraint.addTerm(1, variables.get(i).get(j));
	    		}
	    		cplex.addEq(constraint, quantities.get(j));
	    	}
	    	
	    	// equitability constraints
			for (Integer i1 : agent_set) {
				for (Integer i2 : agent_set) {
					if (i1==i2) continue;
					IloLinearNumExpr constraint = cplex.linearNumExpr();
					for (Integer j : task_set) {
						constraint.addTerm(values.get(i1).get(j), variables.get(i1).get(j));
						constraint.addTerm(-1*values.get(i2).get(j), variables.get(i2).get(j));
					}
					cplex.addEq(constraint, 0);
				}
			}
	    	
	    	// solve and print
			cplex.setOut(null);
			
			// assignment of tasks to people before randomizing
			Map<Integer, Map<Integer, Double>> ex_ante = new HashMap<Integer, Map<Integer, Double>>();
			
			// the amount of each task left over after subtracting out the integer part of each agent's allocation
			Map<Integer, Double> remainder = new HashMap<Integer, Double>();
			for (Integer j : task_set) {
				remainder.put(j, 0d);
			}
			
	    	double value, fractional;
	    	if (cplex.solve()) {
	    		// print objective
	    		System.out.println("utility " + cplex.getObjValue());
	    		for (Integer i : agent_set) {
	    			ex_ante.put(i, new HashMap<Integer, Double>());
	    			for (Integer j : task_set) {
	    				value = cplex.getValue(variables.get(i).get(j));
	    				ex_ante.get(i).put(j, value);
	    				
	    				fractional = value - (int)value;
	    				if (fractional > 0) {
	    					remainder.put(j, remainder.get(j) + fractional);
	    				}
	    			}
	    		}
	    		
	    		for (Integer j : task_set) {
	    			remainder.put(j, (double)Math.round(remainder.get(j)));
	    			if (remainder.get(j) > 0) {
	    				Map<Integer, Integer> rounded_allocation = roundAllocation(ex_ante, j, remainder.get(j).intValue());
	    				for (Integer i : agent_set) {
	    					System.out.println(i + " " + j + " " + ex_ante.get(i).get(j) + " " + rounded_allocation.get(i));
	    				}
	    			} else {
	    				for (Integer i : agent_set) {
	    					System.out.println(i + " " + j + " " + ex_ante.get(i).get(j) + " " + ex_ante.get(i).get(j).intValue());
	    				}
	    			}
	    		}
	    	} else {
	    		System.out.println("failure");
	    		return;
	    	}
	    } catch (Exception e) {
			System.out.println("failure");
		}
	}

	/* Randomly allocate the fractional part of the allocation for a given task 
	 * Algorithm can be improved from exponential to polynomial. */
	private static Map<Integer, Integer> roundAllocation(Map<Integer, Map<Integer, Double>> ex_ante, Integer task, int remainder) throws IloException {
		ArrayList<Set<Integer>> allocations = subsets(ex_ante.keySet(), remainder);
		ArrayList<IloNumVar> variables = new ArrayList<IloNumVar>();
		
		/* One variable per possible allocation */
		IloCplex cplex = new IloCplex();
		for (int i = 0; i < allocations.size(); i++) {
			variables.add(cplex.numVar(0, 1, "x_"+i));
		}
		
		/* Objective not important */
		IloLinearNumExpr objective = cplex.linearNumExpr();
		objective.addTerm(0, variables.get(0));
		cplex.addMaximize(objective);
		
		/* Probabilities must sum to 1 */
		IloLinearNumExpr constraint = cplex.linearNumExpr();
		for (IloNumVar v : variables) {
			constraint.addTerm(1, v);
		}
		cplex.addEq(1, constraint);
		
		/* For each agent, probabilities must sum to their ex_ante */
		for (Integer i : ex_ante.keySet()) {
			constraint = cplex.linearNumExpr();
			for (int j = 0; j < allocations.size(); j++) {
				if (allocations.get(j).contains(i)) {
					constraint.addTerm(1, variables.get(j));
				}
			}
			cplex.addEq(ex_ante.get(i).get(task) - ex_ante.get(i).get(task).intValue(), constraint);
		}
		cplex.setOut(null);
		if (cplex.solve()) {
			Map<Integer, Integer> roundedAllocation = new HashMap<Integer, Integer>();
			Random rand = new Random();
			double n = rand.nextDouble();
			for (int p = 0; p < allocations.size(); p++) {
				n -= cplex.getValue(variables.get(p));
				if (n < 0) {
					for (Integer agent : ex_ante.keySet()) {
						if (allocations.get(p).contains(agent)) {
							roundedAllocation.put(agent, (int)Math.ceil(ex_ante.get(agent).get(task)));
						} else {
							roundedAllocation.put(agent, (int)Math.floor(ex_ante.get(agent).get(task)));
						}
					}
					return roundedAllocation;
				}
			}
		}
		System.out.println("failed");
		return null;
		
	}
	
	
	private static <T> ArrayList<Set<T>> subsets(Set<T> s, int k) {
		ArrayList<Set<T>> sets = new ArrayList<Set<T>>();
		for (Set<T> subset : powerset(s)) {
			if (subset.size() == k) {
				sets.add(subset);
			}
		}
		return sets;
	}
	
	private static <T> Set<Set<T>> powerset(Set<T> originalSet) {
	    Set<Set<T>> sets = new HashSet<Set<T>>();
	    if (originalSet.isEmpty()) {
	    	sets.add(new HashSet<T>());
	    	return sets;
	    }
	    List<T> list = new ArrayList<T>(originalSet);
	    T head = list.get(0);
	    Set<T> rest = new HashSet<T>(list.subList(1, list.size())); 
	    for (Set<T> set : powerset(rest)) {
	    	Set<T> newSet = new HashSet<T>();
	    	newSet.add(head);
	    	newSet.addAll(set);
	    	sets.add(newSet);
	    	sets.add(set);
	    }		
	    return sets;
	}

}
