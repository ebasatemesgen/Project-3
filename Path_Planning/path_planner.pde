import java.util.LinkedList;
import java.util.HashSet;
public class PRM {
    public Node[] nodes = new Node[200];
    public int num_nodes = 0;
    float SAFE_DISTANCE_MARGIN = 20.2;
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

    public void recalculatePath(AutoVehicle car, AutoComponent goal, int carIndex) {
        // Reset the visited state and parent of each node
        for (int i = 0; i < num_nodes; i++) {
            nodes[i].visited = false;
            nodes[i].parent = -1;
        }

        // Find the closest nodes to the Vehicle and the goal
        int startNodeIndex = findClosestNode(new Vec2(car.vehicleComponent.x, car.vehicleComponent.z));
        int goalNodeIndex = findClosestNode(new Vec2(goal.x, goal.z));

        // Recalculate the path
        ArrayList<Integer> newPath = runBFS(startNodeIndex, goalNodeIndex);

        // Check for potential collisions and adjust path if necessary
        if (isCollisionLikely(carIndex)) {
            newPath = adjustPathToAvoidCollision(newPath, carIndex);
        }
        // Update the car's path
        car.travelPath = newPath;
    }

    // Method to get a node by index
    public Node getNodeAtIndex(int index) {
        if (index >= 0 && index < num_nodes) {
            return nodes[index];
        }
        return null; // or handle this scenario appropriately
    }


private ArrayList<Integer> adjustPathToAvoidCollision(ArrayList<Integer> originalPath, int carIndex) {
    ArrayList<Integer> adjustedPath = new ArrayList<>();

    // You may need a more sophisticated approach to identify alternate routes.
    // This example simply tries to find a new path by excluding the nodes where a collision is likely.
    HashSet<Integer> collisionNodes = new HashSet<>();
    for (int i = 0; i < numCars; i++) {
        if (i != carIndex) {
            collisionNodes.addAll(cars[i].travelPath);
        }
    }

    // Finding the start and end nodes of the path
    int startNodeIndex = originalPath.get(0);
    int goalNodeIndex = originalPath.get(originalPath.size() - 1);

    // Resetting the state of nodes
    for (Node node : nodes) {
        node.visited = false;
        node.parent = -1;
    }

    // Queue for BFS
    LinkedList<Integer> queue = new LinkedList<>();
    queue.add(startNodeIndex);
    nodes[startNodeIndex].visited = true;

    // BFS loop
    while (!queue.isEmpty()) {
        int currentNodeIndex = queue.poll();
        Node currentNode = nodes[currentNodeIndex];

        if (currentNodeIndex == goalNodeIndex) {
            break; // Goal found, exit loop
        }

        for (Node neighbor : currentNode.neighbors) {
            if (neighbor == null || collisionNodes.contains(neighbor.id)) {
                continue; // Skip null neighbors or neighbors in collisionNodes
            }

            int neighborIndex = neighbor.id;
            if (!nodes[neighborIndex].visited) {
                nodes[neighborIndex].visited = true;
                nodes[neighborIndex].parent = currentNodeIndex;
                queue.add(neighborIndex);
            }
        }
    }

    // Reconstructing the path
    int current = goalNodeIndex;
    while (current != -1 && current != startNodeIndex) {
        adjustedPath.add(0, current);
        current = nodes[current].parent;
    }

    if (!adjustedPath.isEmpty()) {
        adjustedPath.add(0, startNodeIndex);
    }

    return adjustedPath;
}

private void generate_nodes(Building[] buildings, int num_buildings) {
    int nodeIndex = 0;

    // Initialize nodes for each car and goal
    for (int i = 0; i < numCars; i++) {
        if (nodeIndex < nodes.length) {
            // Create a node for the car's position
            nodes[nodeIndex] = new Node(cars[i].vehicleComponent.x, cars[i].vehicleComponent.z, nodeIndex);
            nodeIndex++;
        }
        if (nodeIndex < nodes.length) {
            // Create a node for the goal's position
            nodes[nodeIndex] = new Node(goals[i].x, goals[i].z, nodeIndex);
            nodeIndex++;
        }
    }

    // Generate additional nodes
    for (int i = numCars * 2; i < nodes.length; i++) {
        nodes[i] = new Node();
        boolean valid;
        do {
            valid = true;
            int length_x = 700;
            int length_z = 1000;
            float r = car_length; // Assuming car_length is available globally
            nodes[i].x = random(-length_x + r, length_x - r) + width/2;
            nodes[i].z = random(-length_z + r, 0 - r);

            // Check if node is too close to a building or another node
            for (int j = 0; j < i; j++) {
                if (dist(nodes[i].x, nodes[i].z, nodes[j].x, nodes[j].z) < 50) {
                    valid = false;
                    break;
                }
            }
        } while (!valid);

        // Set node ID
        nodes[i].id = i;
        nodeIndex++;
    }

    num_nodes = nodeIndex; // Update the count of nodes
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
                        if (buildings[k].intersectsPath(nodes[i].x, nodes[i].z, nodes[j].x, nodes[j].z)) valid = false;
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
                if (neighbor == null || isNodeInBuilding(neighbor) || visited[neighbor.id]) {
                continue; // Skip invalid or visited nodes
            }
                int neighborIndex = neighbor.id; // Assuming each Node has a unique id
                if (!visited[neighborIndex]) {
                    visited[neighborIndex] = true;
                    parent[neighborIndex] = currentNodeIndex; // Set parent for path reconstruction
                    queue.add(neighborIndex);
                }
            }
        }

        // Path reconstruction from goal to start
        ArrayList<Integer> travelPath = new ArrayList<>();
        int current = goalNodeIndex;
        while (current != -1) {
            travelPath.add(0, current); // Use ArrayList's add method
            current = parent[current];
        }
        return travelPath;
    }

void run_BFS() {
    // Loop through each car
    for (int carIndex = 0; carIndex < numCars; carIndex++) {
        // For each car, reset the visited and parent properties of the nodes
        for (Node node : nodes) {
            node.visited = false;
            node.parent = -1;
        }

        // Set the start and goal indices for the current car
        int startNodeIndex = carIndex * 2; // Assuming first node for each car
        int goalNodeIndex = startNodeIndex + 1; // Assuming next node is the goal

        // Initialize fringe and path for the current car
        ArrayList<Integer> fringe = new ArrayList<Integer>();
        cars[carIndex].travelPath = new ArrayList<Integer>();
        nodes[startNodeIndex].visited = true;
        fringe.add(startNodeIndex);

        // BFS loop
        while (!fringe.isEmpty()) {
            int currentNode = fringe.remove(0);
            if (currentNode == goalNodeIndex) {
                break; // Goal found for this car
            }
            for (Node neighbor : nodes[currentNode].neighbors) {
                if (neighbor != null && !nodes[neighbor.id].visited) {
                    nodes[neighbor.id].visited = true;
                    nodes[neighbor.id].parent = currentNode;
                    fringe.add(neighbor.id);
                }
            }
        }

        // Reconstruct path from goal to start
        int prevNode = nodes[goalNodeIndex].parent;
        cars[carIndex].travelPath.add(0, goalNodeIndex);
        while (prevNode != -1) {
            cars[carIndex].travelPath.add(0, prevNode);
            prevNode = nodes[prevNode].parent;
        }

        // Check if the travelPath is valid
        if (cars[carIndex].travelPath.size() == 1) {
            cars[carIndex].travelPath.clear();
        }
    }
}


public void draw() {
    // Draw all nodes
    for (int i = 0; i < num_nodes; i++) {
        nodes[i].draw();
    }

    // Loop through each car to draw its travel path
    for (int carIndex = 0; carIndex < numCars; carIndex++) {
        ArrayList<Integer> travelPath = cars[carIndex].travelPath;

        // Check if the car has a travel path
        if (travelPath.size() == 0) continue;

        // Set color and stroke weight for the path
        stroke(color(255, 0, 0)); // Red color for the path
        strokeWeight(3);

        // Draw the path from the car to the first node
        line(cars[carIndex].vehicleComponent.x, height-101, cars[carIndex].vehicleComponent.z, nodes[travelPath.get(0)].x, height-101, nodes[travelPath.get(0)].z);

        // Draw the rest of the path
        for (int i = 0; i < travelPath.size() - 1; i++) {
            int a = travelPath.get(i);
            int b = travelPath.get(i + 1);
            line(nodes[a].x, height-101, nodes[a].z, nodes[b].x, height-101, nodes[b].z);
        }
    }

    // Reset stroke settings
    noStroke();
}


private boolean isNodeInBuilding(Node node) {
    for (Building building : buildings) {
        // Calculate the distance from the node to the center of the building
        float distance = dist(node.x, node.z, building.x, building.z);

        // Check if the node is within or too close to the building
        // You might need to adjust the threshold depending on your building sizes
        float threshold = building.size_of_buildin / 2 + SAFE_DISTANCE_MARGIN; // SAFE_DISTANCE_MARGIN is a constant you define

        if (distance < threshold) {
            return true; // Node is inside or too close to the building
        }
    }
    return false; // Node is not within or too close to any building
}

}


public boolean isCollisionLikely(int carIndex) {
    AutoVehicle currentCar = cars[carIndex];
    ArrayList<Integer> currentPath = currentCar.travelPath;

    for (int otherCarIndex = 0; otherCarIndex < numCars; otherCarIndex++) {
        if (otherCarIndex == carIndex) continue; // Skip the same car

        AutoVehicle otherCar = cars[otherCarIndex];
        ArrayList<Integer> otherPath = otherCar.travelPath;

        // Check if paths intersect
        for (Integer currentNodeIndex : currentPath) {
            if (otherPath.contains(currentNodeIndex)) {
               System.out.println("Path intersect");
                return true; // Paths intersect, potential collision
                
               
            }
        }
    }
    return false; // No likely collision detected
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
