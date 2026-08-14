// -----------------------------------------------------------------------------
//
//  Gmsh GEO TEAM 3 Coil mesh file
//  Author: Karthik Chockalingam
//
// -----------------------------------------------------------------------------
SetFactory("OpenCASCADE");
//Mesh parameters
Mesh.Algorithm = 6;
Mesh.CharacteristicLengthMin = 1;
Mesh.CharacteristicLengthMax = 20;
Mesh.PartitionOldStyleMsh2 = 1;
Mesh.PreserveNumberingMsh2 = 1;

// Parametric sizes of Geometry
h = 2;

// plate parameters
Offset = 10.0;
Hollow = 40.0;

// -----------------------------------------------------------------------------
// Plate Geometry
// -----------------------------------------------------------------------------

// Outer Points on coil
Point(1) = {0.0, 0.0,  0.0,  h};
Point(2) = {60.0, 0.0, 0.0, h};
Point(3) = {10.0, 10.0, 0.0, h};
Point(4) = {50.0, 10.0, 0.0, h};
Point(5) = {10.0, 50.0, 0.0, h};
Point(6) = {50.0, 50.0, 0.0, h};
Point(7) = {10.0, 60.0, 0.0, h};
Point(8) = {50.0, 60.0, 0.0, h};
Point(9) = {10.0, 100.0, 0.0, h};
Point(10) = {50.0, 100.0, 0.0, h};
Point(11) = {0.0, 110.0, 0.0, h};
Point(12) = {60.0, 110.0, 0.0, h};

// Connect lines
Line(1) = {1, 2};  
Line(2) = {2, 12};  
Line(3) = {12, 11};  
Line(4) = {11, 1};  
Line(5) = {3, 4};  
Line(6) = {4, 6};  
Line(7) = {6, 5};  
Line(8) = {5, 3}; 
Line(9) = {7, 8};  
Line(10) = {8, 10};  
Line(11) = {10, 9};  
Line(12) = {9, 7}; 

//Line Loops
Curve Loop(13) = {1, 2, 3, 4};
Curve Loop(14) = {5, 6, 7, 8};
Curve Loop(15) = {9, 10, 11, 12};

Plane Surface(16) = {13};
Plane Surface(17) = {14};
Plane Surface(18) = {15};

// -----------------------------------------------------------------------------
// Coil Geometry
// (Defined before the BooleanDifference so the explicit tags 13-21 are claimed
//  first; otherwise the OpenCASCADE boolean grabs tags 13-20 for its generated
//  boundary entities and collides with these on newer gmsh versions.)
// -----------------------------------------------------------------------------


// Center
Point(13) = {30, 55, 21.35, h};

// Points on the circle
Point(14) = {-10, 55, 21.35, h};
Point(15) = {30, 15, 21.35, h};
Point(16) = {70, 55, 21.35, h};
Point(17) = {30, 95, 21.35, h};

// Outer Circle arcs
Circle(13) = {14, 13, 15};
Circle(14) = {15, 13, 16};
Circle(15) = {16, 13, 17};
Circle(16) = {17, 13, 14};

// Points on the circle
Point(18) = {10, 55, 21.35, h};
Point(19) = {30, 35, 21.35, h};
Point(20) = {50, 55, 21.35, h};
Point(21) = {30, 75, 21.35, h};

// inner Circle arcs
Circle(17) = {18, 13, 19};
Circle(18) = {19, 13, 20};
Circle(19) = {20, 13, 21};
Circle(20) = {21, 13, 18};


Line(101) = {17, 21};
Line(102) = {19, 15};

Curve Loop(16) = {101, -19, -18, 102, 14, 15};
Curve Loop(17) = {101, 20, 17, 102, -13, -16};

Plane Surface(19) = {16};
Plane Surface(20) = {17};

BooleanDifference{ Surface{16}; Delete; }{ Surface{17,18}; Delete; }

// Extrude first-half

Extrude {0, 0, 20} {
  Surface{19};
}

// Extrude second-half

Extrude {0, 0, 20} {
  Surface{20};
}

// Extrude plate

Extrude {0, 0, 6.35} {
  Surface{16};
}

Coherence;

Box(4) = {-30.0, -10.0, -20.0, 115.0, 130.0, 81.35};
BooleanFragments{ Volume{4}; Delete; }{ Volume{1}; Volume{2}; Volume{3}; Delete; }

Physical Volume("First_half")  = {1}; //first half
Physical Volume("Second_half")  = {2}; //second half
Physical Volume("Plate")  = {3}; //plate
Physical Volume("Free_space")  = {4}; //free space

Physical Surface("Cut") = {48};
Physical Surface(1) = {62, 63, 64, 65, 66, 67}; //free space boundary

Mesh.MshFileVersion = 2.2;