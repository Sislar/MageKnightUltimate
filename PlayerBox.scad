$fn=30;

/* [Global] */

// Render
Objects = "Box"; //  [Both, Box, Lid]
// Type of lid pattern
gPattern = "Diamond"; //  [Hex, Diamond, Solid, Fancy]
// Tolerance
gTol = 0.3;
// Wall Thickness
gWT = 1.6;

//  padded mini 8 in x, and 2 in y  to give it a lip
MiniX = 50+8;
MiniY = 60+2;
MiniZ = 28;

SkillsX = 26;
SkillsY = 39;
SkillsZ = 25;   // no padding

LevelX = 33;
LevelY = 13;
LevelZ = 30.5; 

TokensX = 25;
TokensY = 60;
TokensZ = 25;

// sleeved  size from sleeves + 2mm
CardsMinX = 93;
CardsMinY = 68;
CardsZ = 18;

/* [Hidden] */
/* Private variables */

// Box Height

LidH = 2.2;
RailThick = 1.4;
RailWidth = LidH + RailThick;

function SumList(list, start, end) = (start == end) ? 0 : list[start] + SumList(list, start+1, end);
// Box Length
TotalX = max(CardsMinX, MiniX+LevelX+gWT, MiniX+SkillsX+gWT) + TokensX + 3*gWT ;
// Box Width 10 mm pad between skill and level for finger slot
TotalY = max(max(SkillsY + LevelY + 10+ gWT, MiniY), CardsMinY) + 2*RailWidth;
TotalZ = gWT + max(MiniZ, LevelZ, SkillsZ) + CardsZ + LidH;

// Make cards as wide as opening
CardsX = max(MiniX+max(LevelX,SkillsX)+gWT, CardsMinX);
CardsY = TotalY - 2*RailWidth;  // just as wide as neccessary

echo("Size: ",TotalX,TotalY, TotalZ);
   
// Height not counting the lid
AdjBoxHeight = TotalZ - LidH;

 module regular_polygon(order, r=1){
 	angles=[ for (i = [0:order-1]) i*(360/order) ];
 	coords=[ for (th=angles) [r*cos(th), r*sin(th)] ];
 	polygon(coords);
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
     translate([TotalX/2,TotalY/2-RailWidth-1.4,-1]) RCube(18,0.8,4,0.4);
     translate([TotalX/2,-TotalY/2+RailWidth+1.4,-1]) RCube(18,0.8,4,0.4);
  }
  
  // The Side triangles
  difference() {
    intersection () {
      union () {
          translate([-lAdjX/2,-lAdjY/2-LidH,LidH]) rotate([0,90,0]) linear_extrude(TotalX-2) polygon([[LidH,0],[LidH,LidH],[0,LidH]], paths=[[0,1,2]]);
          translate([-lAdjX/2,lAdjY/2,LidH]) rotate([0,90,0]) linear_extrude(TotalX-2) polygon([[0,0],[LidH,0],[LidH,LidH]], paths=[[0,1,2]]);
      }
      
      // check if this is real lid (ipTol>0) or negative lid (iptol = 0)
      // if real lid remove center for pattern and remove latches
      if (ipTol>0) 
         {cube([lAdjX, lAdjY + 2*LidH-0.2, lAdjZ*2], center=true);}
    }
       
    if (ipTol>0)
    {
        // cut out slots for the latch 
        translate([TotalX/2-7,lAdjY/2+RailWidth/2+ipTol,LidH/2]) scale([1.5,1,1]) rotate([0,0,45]) cube ([2+ipTol,2+ipTol,LidH+1],center=true);
          
        translate([TotalX/2-7,-lAdjY/2-RailWidth/2-ipTol,LidH/2]) scale([1.5,1,1]) rotate([0,0,45]) cube ([2+ipTol,2+ipTol,LidH+1],center=true);
  
        // trip the rail to ease going past the nub
        translate([TotalX/2,TotalY/2-LidH/2-ipTol,0]) cube([12,LidH,LidH*2],center=true); 
        translate([TotalX/2,-TotalY/2+LidH/2+ipTol,0]) cube([12,LidH,LidH*2],center=true); 
    }
    
  }
 
  // Finger slot
  difference () {
      translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      translate([-CutX/2+lFingerX/2,0,20+LidH/2])sphere(20);     
  }

  // Diamond top
  if (ipPattern == "Diamond") 
    {
      difference (){ 
        translate([-CutX/2,-CutY/2,0]) linear_extrude(height = lAdjZ) diamond_lattice(CutX,CutY,7,2);
        translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
          
        // Name Window
        translate([TotalX/2-8,TotalY/2-20,0]) cube([10, 30, 20],center=true); 
      }
    }

    translate([TotalX/2-13.8,TotalY/2-20,lAdjZ/2]) cube([1.6, 30, lAdjZ],center=true); 

    translate([TotalX/2-8.6,TotalY/2-35,lAdjZ/2]) cube([12, 1.6, lAdjZ],center=true); 


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

    // Scope out compartment areas
      
    translate ([TotalX/2-MiniX/2-gWT,
                0,
                AdjBoxHeight-CardsZ-MiniZ])       
          RCube(MiniX-8,MiniY-2,MiniZ+10, 5);
      
    // Card Area 
    translate ([TotalX/2-CardsX/2-gWT,
                0,
                AdjBoxHeight-CardsZ/2])  
           cube([CardsX,CardsY,CardsZ], center=true);
    translate ([TotalX/2,0, AdjBoxHeight-CardsZ-2])        
            RCube(20,25,50);    
      
      
    translate ([-TotalX/2+LevelX/2+2*gWT+TokensX,
                -TotalY/2+SkillsY/2+RailWidth+2,
                AdjBoxHeight-CardsZ-SkillsZ/2]) 
                       cube([SkillsX,SkillsY,SkillsZ], center=true);

    translate ([-TotalX/2+LevelX/2+2*gWT+TokensX,
                TotalY/2-LevelY/2-RailWidth-2,
                AdjBoxHeight-CardsZ-LevelZ/2])     
                        cube([LevelX,LevelY,LevelZ], center=true);       
     // finger access
    translate ([-TotalX/2+LevelX/2+2*gWT+TokensX,
                0,
                AdjBoxHeight-CardsZ-SkillsZ/2])        
            RCube(20,TotalY-2*RailWidth,24);
            
    translate ([-TotalX/2+gWT+TokensX/2,
                0,
                AdjBoxHeight-TokensZ+5])        
            RCube(TokensX,TokensY,TokensZ+5);
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

