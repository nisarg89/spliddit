import java.util.*;


public class SDgraph {
	private Set<Room> rooms;
	private Set<Agent> agents;
	private List<Edge> links;
	private int n;
	private Node nil;
	
	public SDgraph(List<Room> rooms, List<Agent> agents) {
		this.rooms = new HashSet<Room>(rooms);
		this.agents = new HashSet<Agent>(agents);
		createEdges();
		this.n = rooms.size();
		this.nil = new Agent(new HashMap<Room,Rational>(), "-1");
	}
	
	public void createEdges() {
		links = new ArrayList<Edge>();
		for (Agent a : agents) {
			for (Room r : a.getDemand()) {
				links.add(new Edge(r,a));
			}
		}
		for (Agent a : agents) {
			a.neighbors = new HashSet<Node>();
		}
		for (Room r : rooms) {
			r.neighbors = new HashSet<Node>();
		}
		for (Edge e : links) {
			e.agent.neighbors.add(e.room);
			e.room.neighbors.add(e.agent);
		}
	}
	
    private boolean hBFS() {
        Queue<Node> Q = new LinkedList<Node>();
        for(Node v : agents) {
          if (v.pair_g1 == nil) {
            v.dist = 0;
            Q.offer(v);
          } else {
            v.dist = Integer.MAX_VALUE;
          }
        }
        nil.dist = Integer.MAX_VALUE;
        while (Q.peek()!=null) {
          Node v = Q.remove();
          if (v.dist < nil.dist){
            for (Node u : v.neighbors) {
              if (u.pair_g2 != null && u.pair_g2.dist == Integer.MAX_VALUE) {
                u.pair_g2.dist = v.dist + 1;
                Q.offer(u.pair_g2);
              }
            }
          }
        }
        return nil.dist != Integer.MAX_VALUE;
      }
      
      private boolean hDFS(Node v) {
        if (v != nil) {
          for (Node u : v.neighbors) {
            if (u.pair_g2.dist == v.dist + 1) {
              if (hDFS(u.pair_g2)== true) {
                u.pair_g2 = v;
                v.pair_g1 = u;
                return true;
              }
            }
          }
          v.dist = Integer.MAX_VALUE;
          return false;
        }
        return true;
      }	
	
	
	public Set<Edge> maximalMatching() {
		for (Node v : agents) {
			v.pair_g1 = nil;
			v.pair_g2 = nil;
		}
		for (Node v : rooms) {
			v.pair_g1 = nil;
			v.pair_g2 = nil;
		}
		
		int matching = 0;
		while (hBFS())
			for (Node v : agents)
				if (v.pair_g1 == nil && hDFS(v)) matching ++;
		
		//System.out.println("Maximal Matching is size: "+matching);
		Set<Edge> M = new HashSet<Edge>();
		for (Node v : agents) {
			if (v.pair_g1 != nil) {
				M.add(new Edge((Room)v.pair_g1, (Agent)v));
				//System.out.println("   Room "+v.pair_g1.label + ", Agent "+v.label);
			} else {
				//System.out.println("  Agent " + v.label + " was left unmatched :(");
			}
		}

		return M;
	}
	
	public void UDdfs(Node n) {
		if (n.UDvisited) return;
		n.UDvisited = true;
		for (Node m : n.UDneighbors)
			UDdfs(m);
	}

	public void USdfs(Node n) {
		if (n.USvisited) return;
		n.USvisited = true;
		for (Node m : n.USneighbors)
			USdfs(m);
	}

	
	public Set<Room> UDrooms() {
		Set<Edge> M = maximalMatching();
		Set<Edge> notM = new HashSet<Edge>(links);
		notM.removeAll(M);
		
		for (Room r : rooms) {
			r.UDvisited = false;
			r.UDneighbors = new HashSet<Node>();
		}
		
		for (Agent a : agents) {
			a.UDvisited = false;
			a.UDneighbors = new HashSet<Node>();
		}
		
		for (Edge e : M) {
			e.agent.UDneighbors.add(e.room);
		}
		
		for (Edge e : notM) {
			e.room.UDneighbors.add(e.agent);
		}
		
		
		Set<Room> matched = new HashSet<Room>();
		Set<Room> unmatched = new HashSet<Room>(rooms);
		for (Edge e : M) {
			matched.add(e.room);
		}
		unmatched.removeAll(matched);
		
		for (Room r : unmatched)
			UDdfs(r);
		
		Set<Room> UD = new HashSet<Room>();
		for (Room r : rooms) {
			if (r.UDvisited)
				UD.add(r);
		}
		
		//System.out.print("UD rooms: ");
		for (Room r : UD) {
			//System.out.print(r.label+ " ");
		}
		//System.out.println();
		
		return UD;
	}
	
	public Set<Agent> USagents() {
		Set<Edge> M = maximalMatching();
		Set<Edge> notM = new HashSet<Edge>(links);
		notM.removeAll(M);
		
		for (Room r : rooms) {
			r.USvisited = false;
			r.USneighbors = new HashSet<Node>();
		}
		
		for (Agent a : agents) {
			a.USvisited = false;
			a.USneighbors = new HashSet<Node>();
		}
		
		for (Edge e : M) {
			e.room.USneighbors.add(e.agent);
		}
		
		for (Edge e : notM) {
			e.agent.USneighbors.add(e.room);
		}
		
		
		Set<Agent> matched = new HashSet<Agent>();
		Set<Agent> unmatched = new HashSet<Agent>(agents);
		for (Edge e : M) {
			matched.add(e.agent);
		}
		unmatched.removeAll(matched);
		
		for (Agent a : unmatched)
			USdfs(a);
		
		Set<Agent> US = new HashSet<Agent>();
		for (Agent a : agents) {
			if (a.USvisited)
				US.add(a);
		}
		
		//System.out.print("US Agents: ");
		for (Agent a : US) {
			//System.out.print(a.label+ " ");
		}
		//System.out.println();
		
		return US;
	}
	
	public Set<Room> ODrooms() {
		Set<Room> UDrooms = UDrooms();
		Set<Agent> USagents = USagents();
		
		Set<Room> ODrooms = new HashSet<Room>();
		boolean isOD;
		for (Room r : rooms) {
			isOD = false;
			if (UDrooms.contains(r)) continue;
			for (Node a : r.neighbors) {
				if (USagents.contains(a)) {
					//System.out.println("Adding " + r.label + " because it neighbors " + a.label);
					isOD = true;
					break;
				}
			}
			if (isOD) ODrooms.add(r);
		}
		//System.out.print("ODSet: ");
		for (Room r : ODrooms) {
			//System.out.print(r.label+ " ");
		}
		//System.out.println();
		return ODrooms;
	}
	

}
