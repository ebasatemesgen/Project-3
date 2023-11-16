
public class PRM {
    public Node[] nodes = new Node[200];
    public int num_nodes = 0;

    PRM() {
    }

    public void build(Building[] buildings, int num_buildings) {
        resetPRM();
        generate_nodes(buildings, num_buildings);
        connect_nodes(buildings, num_buildings);
        // run BFS
        run_BFS();
    }

    private void resetPRM() {
        nodes = new Node[nodes.length]; // Reinitialize the nodes array
        num_nodes = 0; // Reset the number of nodes
    }

    // Method to find the closest node to a given position
    public int findClosestNode(Vec2 position) {
        int closestIndex = -1;
        float closestDistance = Float.MAX_VALUE;

        for (int i = 0; i < num_nodes; i++) {
            float distance = dist(position.x, position.y, nodes[i].x, nodes[i].z);
            if (distance < closestDistance) {
                closestDistance = distance;
                closestIndex = i;
            }
        }

        return closestIndex;
    }

    public void recalculatePath(Vehicle car, Target goal) {
        // Reset the visited state and parent of each node
        for (int i = 0; i < num_nodes; i++) {
            nodes[i].visited = false;
            nodes[i].parent = -1;
        }

        // Find the closest nodes to the Vehicle and the goal
        int startNodeIndex = findClosestNode(new Vec2(car.car_part.x, car.car_part.z));
        int goalNodeIndex = findClosestNode(new Vec2(goal.x, goal.z));

        // Recalculate the path
        ArrayList<Integer> newPath = runBFS(startNodeIndex, goalNodeIndex);

        // Update the car's path
        car.path = newPath;
    }

    // Method to get a node by index
    public Node getNodeAtIndex(int index) {
        if (index >= 0 && index < num_nodes) {
            return nodes[index];
        }
        return null; // or handle this scenario appropriately
    }

    private void generate_nodes(Building[] buildings, int num_buildings) {
        if (num_nodes < nodes.length) {
            nodes[num_nodes] = new Node(car.car_part.x, car.car_part.z, num_nodes);
            num_nodes++;
        }
        if (num_nodes < nodes.length) {
            nodes[num_nodes] = new Node(goal.x, goal.z, num_nodes);
            num_nodes++;
        }
        for (int i = 2; i < nodes.length; i++) {
            nodes[i] = new Node();
            boolean valid;
            do {
                valid = true;
                // x between -500 and 500
                float r = car.car_part.r;
                nodes[i].x = random(-500 + r, 500 - r) + width/2;
                nodes[i].z = random(-1000 + r, 0 - r);
                // check if node is in a building
                for (int j = 0; j < i; j++) {  // Change to `j < i` to avoid checking uninitialized nodes
                    if (nodes[j] != null && dist(nodes[i].x, nodes[i].z, nodes[j].x, nodes[j].z) < 50) {
                        valid = false;
                        break;  // Exit the inner loop early if too close
                    }
                }
                // check if node is too close to another node
            } while(!valid);
            // set id
            nodes[i].id = i;
            num_nodes++;
        }
    }

    private void connect_nodes(Building[] buildings, int num_buildings) {
        for (int i = 0; i < num_nodes; i++) {
            for (int j = 0; j < num_nodes; j++) {
                if (i != j) {
                    boolean valid = true;
                    // check if the node is close enough to connect
                    if (dist(nodes[i].x, nodes[i].z, nodes[j].x, nodes[j].z) > 200) valid = false;
                    // check if there is a building between the nodes
                    for (int k = 0; k < num_buildings; k++) {
                        if (buildings[k].collision_line(nodes[i].x, nodes[i].z, nodes[j].x, nodes[j].z)) valid = false;
                    }
                    if (valid) {
                        nodes[i].add_neighbor(nodes[j]);
                        nodes[j].add_neighbor(nodes[i]);
                    }
                }
            }
        }
    }

    private ArrayList<Integer> runBFS(int startNodeIndex, int goalNodeIndex) {
        // Initialize an array to keep track of visited nodes
        boolean[] visited = new boolean[num_nodes];

        // Initialize the parent array manually
        int[] parent = new int[num_nodes];
        for (int i = 0; i < parent.length; i++) {
            parent[i] = -1;
        }

        // Create a queue for BFS
        ArrayList<Integer> queue = new ArrayList<>();

        // Start BFS from the start node
        visited[startNodeIndex] = true;
        queue.add(startNodeIndex);

        // BFS loop
        while (!queue.isEmpty()) {
            int currentNodeIndex = queue.remove(0); // Use remove(0) for ArrayList

            // Goal check
            if (currentNodeIndex == goalNodeIndex) {
                break; // Goal found, exit loop
            }

            // Explore neighbors
            Node currentNode = nodes[currentNodeIndex];
            for (Node neighbor : currentNode.neighbors) {
                if (neighbor == null) continue; // Skip null neighbors

                int neighborIndex = neighbor.id; // Assuming each Node has a unique id
                if (!visited[neighborIndex]) {
                    visited[neighborIndex] = true;
                    parent[neighborIndex] = currentNodeIndex; // Set parent for path reconstruction
                    queue.add(neighborIndex);
                }
            }
        }

        // Path reconstruction from goal to start
        ArrayList<Integer> path = new ArrayList<>();
        int current = goalNodeIndex;
        while (current != -1) {
            path.add(0, current); // Use ArrayList's add method
            current = parent[current];
        }
        return path;
    }

    // BFS
    void run_BFS() {
        int start = 0;
        int goal = 1;
        ArrayList<Integer> fringe = new ArrayList();  // Make a new, empty fringe
        car.path = new ArrayList(); // Reset path
        nodes[start].visited = true;
        fringe.add(start);

        while (fringe.size() > 0) {
            int currentNode = fringe.get(0);
            fringe.remove(0);
            if (currentNode == goal) {
                println("Goal found!");
                break;
            }
            for (int i = 0; i < nodes[currentNode].num_neighbors; i++) {
                int j = nodes[currentNode].neighbors[i].id;
                if (!nodes[j].visited) {
                    nodes[j].visited = true;
                    nodes[j].parent = currentNode;
                    fringe.add(j);
                }
            }
        }

        int prevNode = nodes[goal].parent;
        car.path.add(0, goal);
        while (prevNode >= 0) {
            print(prevNode, " ");
            car.path.add(0, prevNode);
            prevNode = nodes[prevNode].parent;
        }

        // if the path only has 1 node, then there is no path
        if (car.path.size() == 1) {
            car.path = new ArrayList();
        }
    }

    public void draw() {
        for (int i = 0; i < num_nodes; i++) {
            nodes[i].draw();
        }
        // draw path
        if (car.path.size() == 0) return;
        stroke(color(255, 0, 0));
        strokeWeight(3);
        // draw from car to the first node
        line(car.car_part.x, height-101, car.car_part.z, nodes[car.path.get(0)].x, height-101, nodes[car.path.get(0)].z);
        for (int i = 0; i < car.path.size()-1; i++) {
            int a = car.path.get(i);
            int b = car.path.get(i+1);
            line(nodes[a].x, height-101, nodes[a].z, nodes[b].x, height-101, nodes[b].z);
        }
        noStroke();
    }
}


public class Node {
    public int id;
    public float x, z;
    public int num_neighbors;
    public int max_neighbors = 20;
    public Node[] neighbors = new Node[max_neighbors];
    public boolean visited = false;
    public int parent = -1;

    // Existing default constructor
    Node() {
        x = 0;
        z = 0;
        num_neighbors = 0;
    }

    // New constructor with parameters
    Node(float x, float z, int id) {
        this.x = x;
        this.z = z;
        this.id = id;
        num_neighbors = 0;
    }

    public void add_neighbor(Node n) {
        if (num_neighbors == max_neighbors) return;
        neighbors[num_neighbors] = n;
        num_neighbors++;
    }

    public void draw() {
        int h_offset = 101;
        fill(color(123, 123, 123, 10));
        noStroke();
        // draw circle
        pushMatrix();
        translate(x, height-h_offset, z);
        rotateX(PI/2);
        circle(0, 0, 10);
        popMatrix();
        // draw lines to neighbors
        for (int i = 0; i < num_neighbors; i++) {
            stroke(color(123, 123, 123, 20));
            strokeWeight(1);
            line(x, height-h_offset, z, neighbors[i].x, height-h_offset, neighbors[i].z);
        }
    }
}
