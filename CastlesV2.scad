$fn=30;

/* [Global] */

// Render
Objects = "Box"; //  [Both, Box, Lid]
// Type of lid pattern
gPattern = "Diamond"; //  [Hex, Diamond, Solid, Fancy]
// Tolerance
gTol = 0.2;
// Wall Thickness
gWT = 1.6;

//  padded mini 8 in x, and 2 in y  to give it a lip
CastleX = 55;
CastleY1 = 26;
CastleY2 = 47;

MiniX = 66;
MiniY =60;

SepBuffer = 13.2;

// Add Cylinder to each bucket for access
StdAccess = 1;
BinRounding = 1;

/* [Spider Web] */
// Amount of space from one ring or webs to the next
WebSpacing = 10;
// How many rings of webs, best of more than needed
WebStrands = 5;
// Thickness of the strands
WedThickness = 1.8;
// How many segments of web
WebWedges = 12;


/* [Hidden] */
/* Private variables */

// Box Height
RailGrip = 2.0;
RailOpeningX = 2.2;
RailWidth = RailGrip+RailOpeningX;
LidH = 2.2;
NubWidth = 1.4;
NubSize = 1.6;
NubPos = 6;
SpringOpening = 2.0;
SpringLength = 13;

function SumList(list, start, end) = (start == end) ? 0 : list[start] + SumList(list, start+1, end);

// Box Length
TotalX = 71;
// Box Width 10 mm pad between skill and level for finger slot
TotalY = 168;
TotalZ = 43;

echo("Size: ",TotalX,TotalY, TotalZ);
   
// Height not counting the lid
AdjBoxHeight = TotalZ - LidH;

 module regular_polygon(order, r=1){
 	angles=[ for (i = [0:order-1]) i*(360/order) ];
 	coords=[ for (th=angles) [r*cos(th), r*sin(th)] ];
 	polygon(coords);
 }

 module trap_pyramid(base, top, h){
    polygon(points=[[-h/2,-base/2],
                    [h/2,-top/2],
                    [h/2,top/2],
                    [-h/2,base/2]]);
 }

module diamond_lattice(ipX, ipY, DSize, WSize)  {

    lOffset = DSize + WSize;

	difference()  {
		square([ipX, ipY]);
		for (x=[0:lOffset:ipX]) {
            for (y=[0:lOffset:ipY]){
  			   translate([x, y])  regular_polygon(4, r=DSize/2);
			   translate([x+lOffset/2, y+lOffset/2]) regular_polygon(4, r=DSize/2);
		    }
        }        
	}
}

module circle_lattice(ipX, ipY, Spacing=10, Walls=1.2)  {


   intersection() {
      square([ipX,ipY]); 
      union() {
	    for (x=[-Spacing:Spacing:ipX+Spacing]) {
           for (y=[-Spacing:Spacing:ipY+Spacing]){
	          difference()  {
			     translate([x+Spacing/2, y+Spacing/2]) circle(r=Spacing*0.75);
			     translate([x+Spacing/2, y+Spacing/2]) circle(r=(Spacing*0.75)-Walls);
		      }
           }   // end for y        
	    }  // end for x
      } // End union
   }
}

module football() {
    scale([0.7,0.7])
    intersection(){
        translate([-4,0]) circle(6);
        translate([4,0]) circle(6);
    }
}

module RCube(x,y,z,ipR=4) {
    translate([-x/2,-y/2,0]) hull(){
      translate([ipR,ipR,ipR]) sphere(ipR);
      translate([x-ipR,ipR,ipR]) sphere(ipR);
      translate([ipR,y-ipR,ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,ipR]) sphere(ipR);
      translate([ipR,ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,ipR,z-ipR]) sphere(ipR);
      translate([ipR,y-ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,z-ipR]) sphere(ipR);
      }  
} 

module lid(ipPattern = "Hex", ipTol = 0.3){
  lAdjX = TotalX;
  lAdjY = TotalY-RailWidth*2-ipTol*2;  
  lAdjZ = LidH;
  CutX = lAdjX - 8;
  CutY = lAdjY - 8;
  lFingerX = 15;
  lFingerY = 16;  

  // main square with center removed for a pattern. 0.01 addition is a kludge to avoid a 2d surface remainging when substracting the lid from the box.
         difference() {
      translate([0,0,lAdjZ/2]) cube([lAdjX+0.01, lAdjY+0.01 , lAdjZ], center=true);

      translate([0,0,lAdjZ/2]) cube([CutX, CutY, lAdjZ], center = true);
      translate([TotalX/2-gWT/2,0,LidH/2])cube([gWT+0.01,TotalY-RailWidth,LidH],center=true);

     // make a slot for the latch can flex         
     translate([TotalX/2-SpringLength/2,TotalY/2-RailWidth-SpringOpening/2-1,-1]) RCube(SpringLength,SpringOpening,4,0.4);
     translate([TotalX/2-SpringLength/2,-TotalY/2+RailWidth+SpringOpening/2+1,-1]) RCube(SpringLength,SpringOpening,4,0.4);
             
 //            SpringOpening = 2.2;
//SpringLength = 20;
             
  }
  
  // The Side triangles
  difference() {
    intersection () {
      union () {
            translate([-TotalX/2,TotalY/2-RailWidth-gTol,0]) rotate([0,90,0]) 
                  linear_extrude(TotalX-1-gTol) polygon(points=[
                            [0,0],
                            [0,LidH],
                            [-RailOpeningX,0]]);
            translate([-TotalX/2,-TotalY/2+RailWidth+gTol,0]) 
                rotate([0,90,0]) 
                linear_extrude(TotalX-1-gTol) 
                polygon(points=[
                            [0,0],
                            [0,-LidH],
                            [-RailOpeningX,0]]);
              }
    }
       
        // cut notches into the railings
    translate([TotalX/2-(NubWidth+2*NubSize/2)-NubPos,TotalY/2-RailWidth+NubSize+gTol,0])
        hull(){
            translate([0,0]) cylinder(h=LidH, r = 0.2);
            translate([NubWidth+2*NubSize,0]) cylinder(h=LidH, r = 0.2);
            translate([NubWidth+NubSize,-NubSize]) cylinder(h=LidH, r = 0.2);
            translate([NubSize,-NubSize]) cylinder(h=LidH, r = 0.2);
        }


    translate([TotalX/2-(NubWidth+2*NubSize/2)-NubPos,-TotalY/2+RailWidth-NubSize-gTol,0])
         hull(){
            translate([0,0]) cylinder(h=LidH, r = 0.2);
            translate([NubWidth+2*NubSize,0]) cylinder(h=LidH, r = 0.2);
            translate([NubWidth+NubSize,NubSize]) cylinder(h=LidH, r = 0.2);
            translate([NubSize,NubSize]) cylinder(h=LidH, r = 0.2);
        }       
        
       // trim a little off the railing past the nub  TODO fix to new vars
        translate([TotalX/2,TotalY/2-LidH/2-ipTol,0]) cube([12,LidH,LidH*2],center=true); 
        translate([TotalX/2,-TotalY/2+LidH/2+ipTol,0]) cube([12,LidH,LidH*2],center=true); 
    
  }
 
  // Finger slot
  difference () {
      translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      translate([-CutX/2+lFingerX/2,0,20+LidH/2])sphere(20);     
  }


  // Solid top
  if (ipPattern == "Solid") 
      {   
       difference (){ 
         translate([-CutX/2,-CutY/2,0]) cube([CutX, CutY,   lAdjZ]);
         translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      }
    }
    

  // Spiderweb top
  if (ipPattern == "Web") 
    {
       difference (){ 
         intersection () 
        {    
             linear_extrude(height = lAdjZ) spider_web(WebSpacing, WebStrands, WedThickness, WebWedges);  
              translate([-CutX/2,-CutY/2,0]) cube([CutX, CutY, LidH*2]); 
        }
         translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      }
    }

  // Hex top
  if (ipPattern == "Hex") 
    {   
       difference (){ 
         translate([-CutX/2,-CutY/2,0]) linear_extrude(height = lAdjZ) hex_lattice(CutX,CutY,6,2);
         translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      }
    }

  // Diamond top
  if (ipPattern == "Diamond") 
    {
      difference (){ 
        translate([-CutX/2,-CutY/2,0]) linear_extrude(height = lAdjZ) diamond_lattice(CutX,CutY,7,2);
        translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      }
    }

  // fancy top
  if (ipPattern == "Fancy") 
    {
        echo(CutX,CutY);
      difference (){ 
        translate([-CutX/2,-CutY/2,0]) linear_extrude(height = lAdjZ) circle_lattice(CutX,CutY);
        translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      }
    }

  // Leaf top
  if (ipPattern == "Leaf") 
    {   
       difference (){ 
         translate([-CutX/2,-CutY/2,0]) linear_extrude(height = lAdjZ) leaf_lattice(CutX,CutY,4,2);
         translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      }
    }
}



module box () {
//  Main Box
    
  difference() {   
     union(){
        // main box 
        translate ([0,0,AdjBoxHeight/2]) cube([TotalX,TotalY,AdjBoxHeight], center = true);
        // add backstop
        translate([TotalX/2-1/2,0,TotalZ-LidH/2])cube([1,TotalY-RailWidth,LidH],center=true);
     }

    // limit backdrop
//     translate([TotalX/2,0,AdjBoxHeight+5])cube([4,TotalY-16,10],center=true);

    // Scope out castle areas
    CastleSpacing = CastleY2/2 + SepBuffer;
     
    translate([TotalX/2-CastleX/2-gWT,TotalY/2+7-CastleSpacing,gWT])  linear_extrude(TotalZ) rotate([0,0,180]) trap_pyramid(CastleY2, CastleY1, CastleX);
         
    translate([-TotalX/2+CastleX/2+gWT,TotalY/2+7-CastleSpacing*2,gWT])  linear_extrude(TotalZ) trap_pyramid(CastleY2, CastleY1, CastleX);   
    
    translate([TotalX/2-CastleX/2-gWT,TotalY/2+7-CastleSpacing*3,gWT]) linear_extrude(100) rotate([0,0,180]) trap_pyramid(CastleY2, CastleY1, CastleX); 
     
    translate([-TotalX/2+CastleX/2+gWT,TotalY/2+7-CastleSpacing*4,gWT]) linear_extrude(100)  trap_pyramid(CastleY2, CastleY1, CastleX);
     
 //   translate([+TotalX/2-MiniX/2-gWT,-TotalY/2+MiniY/2+RailWidth,gWT]) RCube(MiniX,MiniY,TotalZ);
     

  }




  // top rails
  difference() {
      union() {
          translate([0,-TotalY/2+RailWidth/2,AdjBoxHeight+LidH/2]) cube([TotalX,RailWidth,LidH],center = true);  
          translate([0,TotalY/2-RailWidth/2,AdjBoxHeight+LidH/2]) cube([TotalX,RailWidth,LidH],center = true);
           }
       
      // Trim each rail top to a 45 degree angle     
      translate([0,-TotalY/2,AdjBoxHeight+RailWidth]) rotate([45,0,0]) cube([TotalX,RailWidth+0.7,RailWidth+0.7], center=true); 
      translate([0,TotalY/2,AdjBoxHeight+RailWidth])  rotate([45,0,0]) cube([TotalX,RailWidth+0.7,RailWidth+0.7], center=true);  

      // Substract the lid from the rails
      translate([0,0,AdjBoxHeight]) lid(ipPattern = "Solid",ipTol =0);      
  }  
  

  
  // create the latches 
    translate([TotalX/2-7,TotalY/2-0.1-RailWidth/2,TotalZ-LidH/2]) scale([1.5,1,1]) difference(){
      rotate([0,0,45]) cube ([2,2,LidH+1],center=true);
      translate([0,2,0]) cube ([4,4,LidH+2],center=true);
      translate([0,-2,0])cube([2,2,LidH+2], center=true);
      }  
    translate([TotalX/2-7,-TotalY/2+0.1+RailWidth/2,TotalZ-LidH/2]) scale([1.5,1,1]) difference(){
      rotate([0,0,45]) cube ([2,2,LidH+1],center=true);
      translate([0,-2,0]) cube ([4,4,LidH+2],center=true);
      translate([0,2,0])cube([2,2,LidH+2], center=true);
      }

  
} 

module box () {
//  Main Box
  difference() {    
    translate ([0,0,AdjBoxHeight/2]) cube([TotalX,TotalY,AdjBoxHeight], center = true);

    // Scope out castle areas
    CastleSpacing = CastleY2/2 + SepBuffer;
     
    translate([TotalX/2-CastleX/2-gWT,TotalY/2+7-CastleSpacing,gWT])  linear_extrude(TotalZ) rotate([0,0,180]) trap_pyramid(CastleY2, CastleY1, CastleX);
         
    translate([-TotalX/2+CastleX/2+gWT,TotalY/2+7-CastleSpacing*2,gWT])  linear_extrude(TotalZ) trap_pyramid(CastleY2, CastleY1, CastleX);   
    
    translate([TotalX/2-CastleX/2-gWT,TotalY/2+7-CastleSpacing*3,gWT]) linear_extrude(100) rotate([0,0,180]) trap_pyramid(CastleY2, CastleY1, CastleX); 
     
    translate([-TotalX/2+CastleX/2+gWT,TotalY/2+7-CastleSpacing*4,gWT]) linear_extrude(100)  trap_pyramid(CastleY2, CastleY1, CastleX);
  }

// Left rail
    difference(){
    translate([0,TotalY/2-RailWidth/2,TotalZ-LidH/2])cube([TotalX, RailWidth, LidH], center=true);
    translate([-TotalX/2,TotalY/2-RailWidth,TotalZ-LidH]) rotate([0,90,0]) linear_extrude(TotalX) polygon(points=[
                    [0,0],
                    [0,LidH],
                    [-RailOpeningX,0]]);
    }
     
// right Rail      
    difference(){
    translate([0,-TotalY/2+RailWidth/2,TotalZ-LidH/2])cube([TotalX, RailWidth, LidH], center=true);
    translate([-TotalX/2,-TotalY/2+RailWidth,TotalZ-LidH]) 
        rotate([0,90,0]) 
        linear_extrude(TotalX) 
        polygon(points=[
                    [0,0],
                    [0,-LidH],
                    [-RailOpeningX,0]]);
    }      

    
   // add backstop
    difference(){
   translate([TotalX/2-1/2,0,TotalZ-LidH/2])cube([1,TotalY-RailWidth,LidH],center=true);
   translate([TotalX/2-1/2,0,TotalZ-LidH/2])cube([1,TotalY-16,LidH],center=true);

    }
  
    // create the latch nubs
    translate([TotalX/2-(NubWidth+2*NubSize/2)-NubPos,+TotalY/2-RailGrip,TotalZ-LidH])
      linear_extrude(LidH) 
         polygon([
                    [0,0],
                    [NubWidth+2*NubSize,0],
                    [NubWidth+NubSize,-NubSize],
                    [NubSize,-NubSize]], paths=[[0,1,2,3]]);

    translate([TotalX/2-(NubWidth+2*NubSize/2)-NubPos,-TotalY/2+RailGrip,TotalZ-LidH])
      linear_extrude(LidH) 
         polygon([
                    [0,0],
                    [NubWidth+2*NubSize,0],
                    [NubWidth+NubSize,NubSize],
                    [NubSize,NubSize]], paths=[[0,1,2,3]]);
} 




// Production Box
if ((Objects == "Both") || (Objects == "Box")){
 intersection() {
    box();
     RCube(TotalX,TotalY,TotalZ,1);
  }
}

// Production Lid
if (Objects == "Both"){
  translate([-TotalX - 10,0,0]) lid(ipPattern = gPattern, ipTol = gTol);
}

// Production Lid
if (Objects == "Lid"){
  lid(ipPattern = gPattern, ipTol = gTol);
}
