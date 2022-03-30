//This macro is used for preprocessing of in situ data sets to be used for in situ modeling on Imaris
//Data files should be saved as .tif z-stacks prior to use with this script
//The macro is designed to be used on z-stacks of in situ hubridization samples or samples from immunostaining
//Samples should include propidium iodine or other types of nuclear staining
//Designed for 1024x1024 images. Should work fine for smaller images. For larger images sizes, make adjustments to addBorder() to increase border size
//

//Hard coded prarmeters
midlinePixel = 1124
borderSize = 200
bufferSlices = 20

//Main script
//All functions are shown and annotated bellow
mirrorImage();
addBorder(borderSize, bufferSlices);
getMidlinePoints(bufferSlices);
rotate();
translateMidline();



//Left-right mirroring
//Asks user to if image orientation is correct
function mirrorImage (){
items = newArray("Yes", "No");
setSlice(nSlices/2);
Dialog.create("Mirroring");
Dialog.addMessage("Is the OE on the left and OB on the right?");
Dialog.addChoice(" ", items);
Dialog.show();
choice = Dialog.getChoice();

if (choice == "No") {
	run("Flip Horizontally");
}

}

//Add border (200pixels on each side) 

function addBorder(size, slice){

file = getTitle();
fileName = File.nameWithoutExtension;	
width = getWidth();
height = getHeight();

run("Canvas Size...", "width="+(width+(size*2))+" height="+(height+(size*2))+" position=Center zero");

setBatchMode(true);
for (i = 0; i < slice; i++) {

run("Add Slice", "add=slice prepend");

}

for (i = 0; i < slice; i++) {
setSlice(nSlices);
run("Add Slice", "add=slice");

}
setBatchMode(false);


}

//Get points for midline
//Create dialog to ask user to select 3 points on the midline
function getMidlinePoints(slice){
do {
setSlice(3*slice+30);
run("Clear Results");
run("Select None");
Dialog.createNonBlocking("Define midline");
setTool("multipoint");
Dialog.addMessage("Use multipoint tool to select 3 points on the midline.\nEach point on a different slice at differnt heights. Preferably more than 5 slices apart.\n \nAlt-click or command-click to delete a selection\nClick \"OK\" after selecting 3 points");
Dialog.show();

run("Measure");
if (nResults == 3){

}
else{
	Dialog.create("Error");
	Dialog.addMessage("Incorrect number of points selected.\nPlease try again.");
	Dialog.show();
}

} while (nResults != 3);


}


//Calculate rotation
function rotate() {
x1 = getResult("X", 0);
x2 = getResult("X", 1);
x3 = getResult("X", 2);
y1 = getResult("Y", 0);
y2 = getResult("Y", 1);
y3 = getResult("Y", 2);
z1 = getResult("Slice", 0);
z2 = getResult("Slice", 1);
z3 = getResult("Slice", 2);



	//define vectors
vectorABi = x2-x1;
vectorABj = y2-y1;
vectorABk = z2-z1;

vectorACi = x3-x1;
vectorACj = y3-y1;
vectorACk = z3-z1;

	//ABxAC
A = (vectorABj*vectorACk)-(vectorABk*vectorACj);
B = (vectorABk*vectorACi)-(vectorABi*vectorACk);
C = (vectorABi*vectorACj)-(vectorABj*vectorACi);
D = -(A*x1+B*y1+C*z1);


	//rotation
yAxis = 180/PI*atan(C/A);
zAxis = -180/PI*atan(B/A);

run("TransformJ Rotate", "z-angle="+zAxis+" y-angle="+yAxis+" x-angle=0.0 interpolation=[Cubic B-Spline] background=0.0");

}

//Calculate traslation
function translateMidline() {
do {
run("Select None");
setSlice(nSlices/2);
Dialog.createNonBlocking("Define midline");
setTool("line");
Dialog.addMessage("Hold shift and draw line on midline\nClick \"ok\" when ready")
Dialog.show();
getLine(a1, b1, a2, b2, lineWidth);

if (a1 == -1) {
Dialog.create("Error");
Dialog.addMessage("No line selected");
Dialog.show();
}

if (a1 != a2) {
Dialog.create("Error");
Dialog.addMessage("Line not vertical.\n \nMake sure to hold shift when drawing line");
Dialog.show();

a1 = -1;
}

} while (a1 == -1);
translate = midlinePixel-a1;

run("TransformJ Translate", "x-distance="+translate+" y-distance=0.0 z-distance=0.0 voxel interpolation=Linear background=0.0");
}


