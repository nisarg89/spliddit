import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import ilog.concert.*;
import ilog.cplex.*;

public class App {
	public static void main(String[] args) throws NumberFormatException, IOException {
		Map<Integer, Map<Integer, Integer>> values = new HashMap<Integer, Map<Integer, Integer>>();
		Map<Integer, Boolean> divisible = new HashMap<Integer, Boolean>();
		
		BufferedReader in = new BufferedReader(new FileReader(args[0]));
	    String type = args[1];
	    
	    int agents = Integer.parseInt(in.readLine());
	    int items = Integer.parseInt(in.readLine());
	    for (int i = 0; i < items; i++) {
	    	String[] tokens = in.readLine().split(" ");
	    	if (tokens[1].equals("divisible")) {
	    		divisible.put(Integer.valueOf(tokens[0]), true);
	    	} else {
	    		divisible.put(Integer.valueOf(tokens[0]), false);
	    	}
	    }
	    for (int i = 0; i < agents * items; i++) {
	    	String[] tokens = in.readLine().split(" ");
	    	int agent_id = Integer.valueOf(tokens[0]);
	    	int item_id = Integer.valueOf(tokens[1]);
	    	int value = Integer.valueOf(tokens[2]);
	    	if (!values.containsKey(agent_id)) {
	    		values.put(agent_id, new HashMap<Integer, Integer>());
	    	}
	    	values.get(agent_id).put(item_id, value);
	    }
	    
	    switch (type) {
	    case "ef":
	    	computeEnvyFree(agents, items, values, divisible);
	    	break;
	    case "p":
	    	computeProportional(agents, items, values, divisible);
	    	break;
	    case "ccg":
	    default:
	    	computeCCG(agents, items, values, divisible);
	    	break;
	    }
	}
	
	public static void computeEnvyFree(int agents, int items, Map<Integer, Map<Integer, Integer>> values, Map<Integer, Boolean> divisible) {
		try {
			IloCplex cplex = new IloCplex();
			Map<Integer, Map<Integer, IloNumVar>> variables = new HashMap<Integer, Map<Integer, IloNumVar>>();
			Set<Integer> agent_set = values.keySet();
			Set<Integer> item_set = divisible.keySet();
			
			// variables: x_i,j is 1 if agent i is assigned item j, and 0 otherwise
			// for divisible items, allow x_i,j to be between 0 and 1
			for (Integer i : agent_set) {
				for (Integer j : item_set) {
					if (!variables.containsKey(i)) {
						variables.put(i, new HashMap<Integer, IloNumVar>());
					}
					if (divisible.get(j)) {
						variables.get(i).put(j, cplex.numVar(0, 1, "x_"+i+","+j));
					} else {
						variables.get(i).put(j, cplex.boolVar("x_"+i+","+j));
					}
				
				}
			}
			
			// objective function: sum of utilities
			IloLinearNumExpr objective = cplex.linearNumExpr();
			for (Integer i : agent_set) {
				for (Integer j : item_set) {
					objective.addTerm(values.get(i).get(j), variables.get(i).get(j));
				}
			}
			cplex.addMaximize(objective);
			
			// constraints to ensure each item is assigned once
			for (Integer j : item_set) {
				IloLinearNumExpr constraint = cplex.linearNumExpr();
				for (Integer i : agent_set) {
					constraint.addTerm(1, variables.get(i).get(j));
				}
				cplex.addEq(constraint, 1);
			}
			
			// envy freeness constraints
			for (Integer i1 : agent_set) {
				for (Integer i2 : agent_set) {
					if (i1==i2) continue;
					IloLinearNumExpr constraint = cplex.linearNumExpr();
					for (Integer j : item_set) {
						constraint.addTerm(values.get(i1).get(j), variables.get(i1).get(j));
						constraint.addTerm(-1*values.get(i1).get(j), variables.get(i2).get(j));
					}
					cplex.addGe(constraint, 0);
				}
			}
			
			// solve and print
			cplex.setOut(null);
			if (cplex.solve()) {
				for (Integer i : agent_set) {
					for (Integer j : item_set) {
						if (cplex.getValue(variables.get(i).get(j)) > 0) {
							System.out.println(i + " " + j + " " + cplex.getValue(variables.get(i).get(j)));
						}
					}
				}
			} else {
				System.out.println("failure");
			}
		} catch (IloException e) {
			System.out.println("failure");
		}
	}
	
	public static void computeProportional(int agents, int items, Map<Integer, Map<Integer, Integer>> values, Map<Integer, Boolean> divisible) {
		try {
			IloCplex cplex = new IloCplex();
			Map<Integer, Map<Integer, IloNumVar>> variables = new HashMap<Integer, Map<Integer, IloNumVar>>();
			Set<Integer> agent_set = values.keySet();
			Set<Integer> item_set = divisible.keySet();
			
			// variables: x_i,j is 1 if agent i is assigned item j, and 0 otherwise
			// for divisible items, allow x_i,j to be between 0 and 1
			for (Integer i : agent_set) {
				for (Integer j : item_set) {
					if (!variables.containsKey(i)) {
						variables.put(i, new HashMap<Integer, IloNumVar>());
					}
					if (divisible.get(j)) {
						variables.get(i).put(j, cplex.numVar(0, 1, "x_"+i+","+j));
					} else {
						variables.get(i).put(j, cplex.boolVar("x_"+i+","+j));
					}
				
				}
			}
			
			// objective function: sum of utilities
			IloLinearNumExpr objective = cplex.linearNumExpr();
			for (Integer i : agent_set) {
				for (Integer j : item_set) {
					objective.addTerm(values.get(i).get(j), variables.get(i).get(j));
				}
			}
			cplex.addMaximize(objective);
			
			// constraints to ensure each item is assigned once
			for (Integer j : item_set) {
				IloLinearNumExpr constraint = cplex.linearNumExpr();
				for (Integer i : agent_set) {
					constraint.addTerm(1, variables.get(i).get(j));
				}
				cplex.addEq(constraint, 1);
			}
			
			// proportionality constraints
			for (Integer i : agent_set) {
				IloLinearNumExpr constraint = cplex.linearNumExpr();
				for (Integer j : item_set) {
					constraint.addTerm(values.get(i).get(j), variables.get(i).get(j));
				}
				cplex.addGe(constraint, 1000.0/agents);
			}
			
			// solve and print
			cplex.setOut(null);
			if (cplex.solve()) {
				for (Integer i : agent_set) {
					for (Integer j : item_set) {
						if (cplex.getValue(variables.get(i).get(j)) > 0) {
							System.out.println(i + " " + j + " " + cplex.getValue(variables.get(i).get(j)));
						}
					}
				}
			} else {
				System.out.println("failure");
			}
		} catch (IloException e) {
			System.out.println("failure");
		}
	}
	
	public static void computeCCG(int agents, int items, Map<Integer, Map<Integer, Integer>> values, Map<Integer, Boolean> divisible) {
		
		try {
			Map<Integer, Double> ccg = new HashMap<Integer, Double>();
			Map<Integer, Map<Integer, IloNumVar>> variables = new HashMap<Integer, Map<Integer, IloNumVar>>();
			Set<Integer> agent_set = values.keySet();
			Set<Integer> item_set = divisible.keySet();

			// ----- compute CCG for each player -----
			for (Integer agent : agent_set) {
				IloCplex cplex = new IloCplex();
				cplex.setOut(null);
				
				// variables: x_i,j is 1 if agent i is assigned item j, and 0 otherwise
				// for divisible items, allow x_i,j to be between 0 and 1
				for (Integer i : agent_set) {
					for (Integer j : item_set) {
						if (!variables.containsKey(i)) {
							variables.put(i, new HashMap<Integer, IloNumVar>());
						}
						if (divisible.get(j)) {
							variables.get(i).put(j, cplex.numVar(0, 1, "x_"+i+","+j));
						} else {
							variables.get(i).put(j, cplex.boolVar("x_"+i+","+j));
						}
					
					}
				}
				IloNumVar y = cplex.numVar(0, Double.MAX_VALUE, "y");
				
				// define objective
				IloLinearNumExpr objective = cplex.linearNumExpr();
				objective.addTerm(1, y);
				cplex.addMaximize(objective);

				// constraints to ensure each item is assigned once
				for (Integer j : item_set) {
					IloLinearNumExpr constraint = cplex.linearNumExpr();
					for (Integer i : agent_set) {
						constraint.addTerm(1, variables.get(i).get(j));
					}
					cplex.addEq(constraint, 1);
				}
				
				// constraints to ensure get at least CCG (y)
				for (Integer i : agent_set) {
					IloLinearNumExpr constraint = cplex.linearNumExpr();
					for (Integer j : item_set) {
						constraint.addTerm(values.get(agent).get(j), variables.get(i).get(j));
					}
					constraint.addTerm(-1, y);
					cplex.addGe(constraint, 0);
				}
				
				cplex.solve();
				ccg.put(agent, cplex.getValue(y));
				// print each agent's CCG
				System.out.println("" + agent + " " + cplex.getValue(y));
			}
			
			// ----- Compute the maximum CCG multiplier we can guarantee (2/3 or better) -----
			IloCplex cplex = new IloCplex();
			cplex.setOut(null);
			
			// variables: x_i,j is 1 if agent i is assigned item j, and 0 otherwise
			// for divisible items, allow x_i,j to be between 0 and 1
			for (Integer i : agent_set) {
				for (Integer j : item_set) {
					if (!variables.containsKey(i)) {
						variables.put(i, new HashMap<Integer, IloNumVar>());
					}
					if (divisible.get(j)) {
						variables.get(i).put(j, cplex.numVar(0, 1, "x_"+i+","+j));
					} else {
						variables.get(i).put(j, cplex.boolVar("x_"+i+","+j));
					}
				
				}
			}
			IloNumVar z = cplex.numVar(0, Double.MAX_VALUE, "z");
			
			// define objective
			IloLinearNumExpr objective = cplex.linearNumExpr();
			objective.addTerm(1, z);
			cplex.addMaximize(objective);

			// constraints to ensure each item is assigned once
			for (Integer j : item_set) {
				IloLinearNumExpr constraint = cplex.linearNumExpr();
				for (Integer i : agent_set) {
					constraint.addTerm(1, variables.get(i).get(j));
				}
				cplex.addEq(constraint, 1);
			}
			
			// constraints to ensure each player gets at least z * CCG
			for (Integer i : agent_set) {
				IloLinearNumExpr constraint = cplex.linearNumExpr();
				for (Integer j : item_set) {
					constraint.addTerm(values.get(i).get(j), variables.get(i).get(j));
				}
				constraint.addTerm(-1 * ccg.get(i), z);
				cplex.addGe(constraint, 0);
			}
			
			cplex.solve();
			double ccg_multiplier = cplex.getValue(z);
			if (ccg_multiplier > 1.0 || ccg_multiplier <= 0.0) ccg_multiplier = 1.0;

			// print the multiplier
			System.out.println(ccg_multiplier);
			
			// ----- Finally, maximize total welfare -----
			cplex = new IloCplex();
			cplex.setOut(null);
			
			// variables: x_i,j is 1 if agent i is assigned item j, and 0 otherwise
			// for divisible items, allow x_i,j to be between 0 and 1
			for (Integer i : agent_set) {
				for (Integer j : item_set) {
					if (!variables.containsKey(i)) {
						variables.put(i, new HashMap<Integer, IloNumVar>());
					}
					if (divisible.get(j)) {
						variables.get(i).put(j, cplex.numVar(0, 1, "x_"+i+","+j));
					} else {
						variables.get(i).put(j, cplex.boolVar("x_"+i+","+j));
					}
				
				}
			}
			
			// objective function: sum of utilities
			objective = cplex.linearNumExpr();
			for (Integer i : agent_set) {
				for (Integer j : item_set) {
					objective.addTerm(values.get(i).get(j), variables.get(i).get(j));
				}
			}
			cplex.addMaximize(objective);

			// constraints to ensure each item is assigned once
			for (Integer j : item_set) {
				IloLinearNumExpr constraint = cplex.linearNumExpr();
				for (Integer i : agent_set) {
					constraint.addTerm(1, variables.get(i).get(j));
				}
				cplex.addEq(constraint, 1);
			}
			
			// constraints to ensure each player gets at least CCG_multiplier * CCG
			for (Integer i : agent_set) {
				IloLinearNumExpr constraint = cplex.linearNumExpr();
				for (Integer j : item_set) {
					constraint.addTerm(values.get(i).get(j), variables.get(i).get(j));
				}
				cplex.addGe(constraint, ccg.get(i) * ccg_multiplier);
			}			
			
			// solve and print
			if (cplex.solve()) {
				for (Integer i : agent_set) {
					for (Integer j : item_set) {
						if (cplex.getValue(variables.get(i).get(j)) > 0) {
							System.out.println(i + " " + j + " " + cplex.getValue(variables.get(i).get(j)));
						}
					}
				}
			} else {
				System.out.println("failure");
			}
		} catch (IloException e) {
			System.out.println("failure");
		}
	}
	
	public static void model1() {
		try {
			IloCplex cplex = new IloCplex();
			
			// variables
			IloNumVar x = cplex.numVar(0, Double.MAX_VALUE, "x");
			IloNumVar y = cplex.numVar(0, Double.MAX_VALUE, "y");
			
			// define objective
			IloLinearNumExpr objective = cplex.linearNumExpr();
			objective.addTerm(0.12, x);
			objective.addTerm(0.15, y);
			
			cplex.addMinimize(objective);
			
			// define constraints
			cplex.addGe(cplex.sum(cplex.prod(60, x), cplex.prod(60, y)), 300);
			cplex.addGe(cplex.sum(cplex.prod(12, x), cplex.prod(6, y)), 36);
			cplex.addGe(cplex.sum(cplex.prod(10, x), cplex.prod(30, y)), 90);
			
			
			cplex.setOut(null);
			// solve
			if (cplex.solve()) {
				System.out.println("obj = "+cplex.getObjValue());
				System.out.println("x = "+cplex.getValue(x));
				System.out.println("y = "+cplex.getValue(y));
			} else {
				System.out.println("No solution found");
			}
			
			
		} catch (IloException exc) {
			exc.printStackTrace();
		}
	}
}
