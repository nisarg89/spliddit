import java.util.Set;

public abstract class Node {
	Node pair_g1, pair_g2;
	int dist;
	String label;
	Set<Node> neighbors;
	
	
	//for computing UDset
	Set<Node> UDneighbors;
	boolean UDvisited;
	
	//for computing USset
	Set<Node> USneighbors;
	boolean USvisited;
	
	public String toString() {
		return "" + label;
	}
}
