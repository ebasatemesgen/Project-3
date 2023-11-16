PVector rayOriginGlobal;
PVector rayDirectionGlobal;
boolean drawRay = false;
boolean followCar = false;
// PRM Pathfinding
PRM prm = new PRM();
float car_length = 15;
Target goal = new Target();
float CarSize = 15;
Vehicle car = new Vehicle();
boolean canUpdate = false;



// Terrain 
int cols, rows;
int scl = 20; 
int w = 20000;
int h = 10000; 
float[][] terrainLeft;

// Environment 
int number_building = 15;
Building[] buildings = new Building[number_building];
Camera camera;

void setup() {
    size(1280, 720, P3D);
    camera = new Camera();
    frameRate(60);
    cols = w / scl;
    rows = h / scl;
    terrainLeft = new float[cols][rows];


    // Initialize goal, car, and PRM
    initEnvironment();  
    // Initialize buildings
    initBuildings();

   
}

void initBuildings() {
    // Initialize parameters
    int maxAttempts = 100; // Maximum number of attempts to find a collision-free position
    float goalRadius = goal.r;
    float CarSize = car_length;
    float minX = -500;
    float maxX = 500;
    float minZ = -1000;
    float maxZ = 0;
    float halfWidth = width / 2;

    // Initialize goal
    PVector goalPosition = findRandomPosition(minX, maxX, minZ, maxZ, goalRadius, halfWidth, maxAttempts);
    if (goalPosition != null) {
        goal.x = goalPosition.x;
        goal.z = goalPosition.y; // Assuming y here represents the z-axis in your 3D world
    }

    // Initialize car
    car.car_part.r = CarSize;
    car.car_part.c = color(255, 123, 345);
    PVector carPosition = findRandomPosition(minX, maxX, minZ, maxZ, CarSize, halfWidth, maxAttempts);
    if (carPosition != null) {
        car.car_part.x = carPosition.x;
        car.car_part.z = carPosition.y; // Assuming y here represents the z-axis in your 3D world
    }

    // Initialize the PRM
    prm.build(buildings, number_building);
}

PVector findRandomPosition(float minX, float maxX, float minZ, float maxZ, float radius, float halfWidth, int maxAttempts) {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
        float x = random(minX + radius, maxX - radius) + halfWidth;
        float z = random(minZ + radius, maxZ - radius);

        if (!collision(x, z, radius)) {
            return new PVector(x, z); // No collision, return this position
        }
    }
    return null; // Return null if a position couldn't be found
}



void initEnvironment() {
    int maxBuildingSideLength = 250; // Maximum side length for buildings
    int minBuildingSideLength = 50;  // Minimum side length for buildings
    int minPosX = -500;              // Minimum x-position for buildings
    int maxPosX = 500;               // Maximum x-position for buildings
    int minPosZ = -1000;             // Minimum z-position for buildings
    int maxPosZ = 0;                 // Maximum z-position for buildings
    float halfScreenWidth = width / 2; // Half the width of the screen
    float buildingPlacementBuffer = car_length * 4; // Buffer to prevent overlap with car

    for (int buildingIndex = 0; buildingIndex < number_building; buildingIndex++) {
        boolean buildingPlaced = false;
        while (!buildingPlaced) {
            float buildingSize = random(minBuildingSideLength, maxBuildingSideLength);
            float posX = random(minPosX + buildingSize / 2 + buildingPlacementBuffer, 
                                maxPosX - buildingSize / 2 - buildingPlacementBuffer) + halfScreenWidth;
            float posZ = random(minPosZ + buildingSize / 2 + buildingPlacementBuffer, 
                                maxPosZ - buildingSize / 2 - buildingPlacementBuffer);
            boolean isCircularBuilding = random(1) < 0.3; // 30% chance of being circular

            if (!collides(posX, posZ, buildingSize, buildings)) {
                buildings[buildingIndex] = new Building(buildingSize, posX, posZ, isCircularBuilding);
                buildingPlaced = true;
            }
        }
    }
}





void draw() {

            float dt= 1.0 / frameRate;
            background(255, 178,123);           
      
            //
             camera.update(dt);
            // Update car and draw environment
            updateAndDrawEnvironment(dt);
            if (followCar) {
                updateCameraToFollowCar(dt);
            }
            
            // Mouse Clicking on Node not working for me
            
            //if (drawRay && rayOriginGlobal != null && rayDirectionGlobal != null) {
            //    stroke(255, 0, 0); // Set ray color to red
            //    strokeWeight(2); // Set ray thickness
        
            //    // Calculate a point along the direction of the ray
            //    PVector rayEndPoint = PVector.add(rayOriginGlobal, PVector.mult(rayDirectionGlobal, 500));
        
            //    // Draw the ray
            //    line(rayOriginGlobal.x, rayOriginGlobal.y, rayOriginGlobal.z, rayEndPoint.x, rayEndPoint.y, rayEndPoint.z);
        
            //    drawRay = false; // Optionally, reset the flag after drawing
            //}
          
}


void updateAndDrawEnvironment(float deltaTime) {
    // Offsets for the terrain generation start
    float terrainOffsetXStart = 0.0;
    float terrainOffsetYStart = -1000;

    // Update the car
    car.update(deltaTime);

    // Draw the terrain segments
    drawTerrainSegment(terrainLeft, 500, -2000, terrainOffsetXStart, terrainOffsetYStart); // Left of buildings
    // Draw the Probabilistic Road Map (PRM)
    prm.draw();
    // Draw a base platform in the center
    fill(12); // Dark color for the platform
    pushMatrix();
    translate(width / 2, height - 90, -500); 
    box(1000, 10, 1000); 
    popMatrix();


    // Draw the goal position
    goal.draw();
    // Draw each building
    for (int buildingIndex = 0; buildingIndex < number_building; buildingIndex++) {
        buildings[buildingIndex].draw();
    }
    // Draw the car
    car.draw();
}
      
        
void drawTerrainSegment(float[][] terrainSegment, float xOffset, float zOffset, float xoffStart, float yoffStart) {
    float xoff = xoffStart;
    for (int x = 0; x < cols; x++) {
        float yoff = yoffStart;
        for (int y = 0; y < rows; y++) {
            terrainSegment[x][y] = map(noise(xoff, yoff), 0, 1, -1000, -700);
            yoff += 0.1;
        }
        xoff += 0.1;
    }

    pushMatrix();
    translate(width / 2 + xOffset, height / 2 + 100, zOffset);
    rotateX(PI / 2);
    background(0, 23,123);
    fill(200, 200, 200, 150);
    for (int y = 0; y < rows - 1; y++) {
        beginShape(TRIANGLE_STRIP);
        for (int x = 0; x < cols; x++) {
            vertex(x * scl - w / 2, y * scl - h / 2, terrainSegment[x][y]);
            vertex(x * scl - w / 2, (y + 1) * scl - h / 2, terrainSegment[x][y + 1]);
        }
        endShape();
        
    }

    popMatrix();
}

            

                    

                     
                        

boolean collision(float x, float z, float r) {
    for (int i = 0; i < number_building; i++) {
        if (buildings[i].collision(x, z, r)) {
            return true;
        }
    }
        return false;
    }
        
boolean collides(float newX, float newZ, float newRadius, Building[] buildings) {
    for (Building b : buildings){
        if (b != null) {
            float dx = newX - b.x;
            float dz = newZ - b.z;
            float distance = sqrt(dx * dx + dz * dz);
            
            // Use the larger size to ensureno overlap
            float maxBuildingSize = max(b.s,newRadius);
            
            if (distance < maxBuildingSize) {
                return true; // Collision detected
            }
        }
    }
    return false; // No collision
}
void keyPressed() {
    if (key == 'r') {
        initEnvironment();  // First, reset and initialize the environment
        initBuildings();    // Then, reset and initialize the buildings
        prm = new PRM();    // Reinitialize the PRM to clear previous state
        prm.build(buildings, number_building); // Rebuild the PRM
    }
    
    if (key == ' ') { // Check if the space key is pressed
        canUpdate = true; // Enable update method to run
    }
    if (key == 'p' || key == 'P') {
        followCar = true;
    }
    if (key == 'o' || key == 'O') {
        followCar = false;
    }


    camera.HandleKeyPressed();
}

    
void keyReleased() {
    camera.HandleKeyReleased();
}        


void mousePressed() {
    PVector rayOrigin = new PVector(camera.position.x, camera.position.y, camera.position.z);
    PVector rayDirection = getRayDirection(mouseX, mouseY);

    PVector intersectPoint = intersectRayWithXZPlane(rayOrigin, rayDirection);

    if (intersectPoint != null) {
        // Find the closest node to the intersection point on the xz-plane
        rayOriginGlobal = rayOrigin;
        rayDirectionGlobal = rayDirection;
        drawRay = true;
        
        Vec2 intersectPosition = new Vec2(intersectPoint.x, intersectPoint.z); // Assuming y is up, and we use x and z
        int closestNodeIndex = prm.findClosestNode(intersectPosition);

        if (closestNodeIndex != -1) { // Check if a valid node was found
            // Set the new goal to this node
            Node newGoalNode = prm.getNodeAtIndex(closestNodeIndex);
            goal.x = newGoalNode.x;
            goal.z = newGoalNode.z;

            // Recalculate the path
            prm.recalculatePath(car, goal);
        }
    }
}


void mouseReleased() {
    camera.mouseReleased(); 
}

void mouseDragged() {
    camera.mouseDragged(); 
}

void mouseWheel(MouseEvent event) {
    camera.mouseWheel(event);
}
