fiducial_radius = 4; //Size of MAIA fiducials that move with Linear SIFT
default_initial_res = 2; //Starting elastic transform resolution
default_final_res = 4; //Final elastic transform resolution
manual_override = true; //Whether to stop macro before bUnwarpJ for manual registration

//Modified physics LUT
reds = newArray(0, 46, 45, 44, 42, 41, 40, 39, 37, 36, 35, 33, 32, 30, 29, 27, 26, 24, 23, 21, 19, 18, 16, 14, 12, 10, 9, 7, 5, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 4, 5, 6, 7, 8, 8, 9, 10, 11, 12, 13, 14, 15, 16, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 22, 22, 22, 27, 32, 37, 42, 48, 53, 58, 63, 69, 74, 79, 85, 90, 96, 101, 107, 112, 118, 123, 129, 134, 140, 145, 148, 151, 153, 156, 159, 161, 164, 166, 169, 172, 174, 177, 180, 182, 185, 188, 190, 193, 196, 198, 201, 204, 206, 210, 213, 216, 220, 222, 222, 222, 222, 222, 223, 223, 223, 223, 223, 223, 224, 224, 224, 224, 224, 225, 225, 225, 225, 225, 225, 226, 226, 226, 226, 226, 227, 227, 227, 227, 227, 228, 228, 228, 228, 228, 228, 229, 229, 229, 229, 229, 230, 230, 230, 230, 230, 230, 231, 231, 231, 231, 231, 232, 232, 232, 232, 232, 233);
greens = newArray(0, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 3, 5, 7, 9, 11, 13, 15, 18, 20, 23, 26, 28, 31, 33, 36, 39, 41, 44, 47, 49, 52, 55, 58, 60, 63, 66, 69, 71, 74, 77, 80, 82, 85, 88, 91, 94, 96, 99, 102, 105, 108, 111, 114, 116, 119, 122, 125, 128, 131, 134, 137, 140, 143, 146, 149, 152, 155, 158, 161, 164, 167, 170, 173, 176, 179, 182, 185, 188, 191, 194, 198, 198, 198, 198, 198, 199, 199, 199, 199, 199, 200, 200, 200, 200, 200, 201, 201, 201, 201, 202, 202, 202, 203, 203, 203, 204, 204, 204, 205, 205, 205, 206, 206, 206, 207, 207, 207, 208, 208, 208, 209, 209, 209, 210, 210, 210, 211, 211, 211, 212, 212, 212, 213, 213, 213, 214, 214, 214, 215, 215, 215, 216, 216, 216, 217, 217, 217, 217, 217, 218, 218, 218, 218, 218, 218, 219, 219, 219, 219, 219, 219, 219, 220, 220, 220, 220, 220, 220, 221, 221, 221, 221, 221, 221, 220, 217, 214, 212, 209, 206, 203, 200, 197, 194, 191, 188, 185, 182, 178, 175, 172, 169, 166, 163, 160, 157, 154, 151, 148, 145, 141, 138, 135, 132, 129, 126, 122, 119, 116, 113, 110, 106, 103, 100, 97, 94, 90, 87, 84, 80, 77, 74, 71, 67, 64, 61, 57, 54, 51, 47, 44, 41, 37, 34);
blues = newArray(0, 120, 122, 123, 124, 125, 126, 127, 128, 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 141, 142, 143, 144, 145, 146, 147, 148, 149, 151, 152, 153, 154, 155, 156, 157, 158, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 191, 191, 191, 192, 192, 192, 192, 192, 193, 193, 193, 193, 193, 194, 194, 194, 194, 194, 195, 195, 195, 195, 195, 196, 196, 196, 196, 196, 197, 197, 197, 197, 197, 198, 195, 192, 190, 187, 184, 181, 178, 176, 173, 170, 167, 165, 162, 159, 156, 153, 150, 148, 143, 138, 133, 129, 124, 119, 114, 109, 104, 99, 94, 89, 84, 79, 74, 69, 64, 59, 54, 49, 44, 39, 33, 28, 23, 22, 22, 22, 22, 22, 22, 22, 22, 22, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16);

//Increments of bUnwarpJ registration
unwarp_res = newArray("Very Coarse", "Coarse", "Fine", "Very Fine", "Super Fine");

close("*");
print("\\Clear");
dir = getDirectory("Choose a Directory ");
out_dir = dir + "/registration preview";
File.makeDirectory(out_dir);
setBatchMode(true);
oct_count = 0;
maia_count = 0;
maia_threshold_count = 0;
master_error_count = 0; //Number of errors encountered during macro
master_failed_count = 0; //Number of files that failed to register
countFiles(dir);
if(oct_count == maia_count && oct_count == maia_threshold_count){
	print("---------------------------------------------------------------------------------");
	print("" + oct_count + " file sets found.");
}
else{
	master_error_count++;
	print("Error: Missing data. " + oct_count + " OCT images found, " + maia_count + " MAIA images found, " + maia_threshold_count + " MAIA threshold files found.");
}

n = 0;

processFiles(dir);
setBatchMode("exit and display");
exit();
//print(count+" files processed");

function countFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) { //Search for oct image, maia image, and maia threshold in the sample parent folder
		if (endsWith(list[i], "/")){
			countFiles(""+dir+list[i]);
		}
		else{
			if(matches(list[i], "OCT.tif")) oct_count++;
			else if(matches(list[i], "MAIA_exam_[0-9]+_[0-9]+.png")) maia_count++;
			else if(matches(list[i], "maia-[0-9]+_[0-9]+_[0-9]+_threshold.txt")) maia_threshold_count++;
		}
	}
}

function processFiles(dir) {
  list = getFileList(dir);
  for (i=0; i<list.length; i++) {
      if (endsWith(list[i], "/"))
          processFiles(""+dir+list[i]);
      else {
      	if(matches(list[i], "OCT.tif")){ //If OCT file is found, look for matching MAIA image and threshold files
	      	parent = File.getParent(dir);
	      	sample = File.getName(parent);
	     	maia_dir = parent + "/MAIA/";
	     	maia_file_list = getFileList(maia_dir);
	     	oct_image_path = dir+list[i];
	     	maia_image_path = "";
	     	maia_threshold_path = "";
	     	for(f=0; f<maia_file_list.length; f++){
	     		if(matches(maia_file_list[f], "MAIA_exam_[0-9]+_[0-9]+.png")){
	     			maia_image_path = maia_dir+maia_file_list[f];
	     			break;
	     		}
	     	}
	     	if(f >= maia_file_list.length){
	     		master_error_count++;
	     		print("ERROR: MAIA image missing from \"" + sample + "\"");
	     		return;
	     	}
	     	else{
		     	for(f=0; f<maia_file_list.length; f++){
		     		if(matches(maia_file_list[f], "maia-[0-9]+_[0-9]+_[0-9]+_threshold.txt")){
		     			maia_threshold_path = maia_dir+maia_file_list[f];
		     			
		     			//If the fileset is complete, register the images
		     			n++;
		     			print("---------------------------------------------------------------------------------");
     			        print("Processing " + sample + ". File set " + n + " of " + oct_count + ".");
     			        print("" + master_error_count + " total errors so far.");
     			        print("" + master_failed_count + " failed registrations so far.");
     			        n_thresholds = parseMaiaThresholds(maia_threshold_path, maia_image_path);
		     			reg_error = true;
		     			
		     			//Keep attempting incrementally lower resolution registrations until successful
		     			unwarp_initial_res = default_initial_res; 
						unwarp_final_res = default_final_res; 
		     			while(reg_error){
		     				print("Attempting registration using \"" + unwarp_res[unwarp_initial_res] + "\" to \""  + unwarp_res[unwarp_final_res] + "\" resolutions.");
		   					if(!isOpen("Unregistered MAIA thresholds.tif")){
		     					parent = File.getParent(maia_image_path);
								parent = File.getParent(parent);
			     				open(parent + "/Unregistered MAIA thresholds.tif");
		   					}
		     				reg_error = registerImages(maia_image_path, oct_image_path);
		     				
		     				//If the registration failed, decrement the resolution and try again
		     				if(reg_error){
		     					unwarp_final_res--; //decrement resolution
		     					if(unwarp_initial_res > unwarp_final_res) unwarp_initial_res = unwarp_final_res; //final cannot be lower than initial
		     					if(unwarp_initial_res < 0){
		     						master_failed_count++;
		     						reg_error = false;
		     						print("ERROR: Unable to register image.");
		     					}
		     				}
		     			}
	     				selectWindow("Log");
						run("Close");
		     			break;
		     		}
		     	}
		     	if(f >= maia_file_list.length){
		     		master_error_count++;
		     		print("ERROR: MAIA threshold missing from \"" + sample + "\"");
		     		return;
		     	}
	     	}
      	}
     }
  }
}

function parseMaiaThresholds(maia_threshold_path, maia_image_path){
	//Open the MAIA image, and make identical scaled images with the thresholds and IDs mapped
	maia_file = File.getName(maia_image_path);
	parent = File.getParent(maia_image_path);
	parent = File.getParent(parent);
	open(maia_image_path);
	selectWindow(maia_file);
	getDimensions(maia_width, maia_height, dummy, dummy, dummy);
	close(maia_file);
	newImage("MAIA thresholds", "8-bit black", maia_width, maia_height, 2);
	selectWindow("MAIA thresholds");
	setSlice(1);
	setMetadata("Label", "ID");
	setSlice(2);
	setMetadata("Label", "Threshold");
	
	//Open and parse threshold file
	threshold_string = File.openAsString(maia_threshold_path); //https://imagej.nih.gov/ij/macros/Find.txt
	threshold_lines = split(threshold_string, "\n");
	
	//Search for metadata in file
	n_thresholds = -1; //Track the number of thresholds found - start at -1 so that optic nerve (ID 0) is not counted
	for (line=0; line<threshold_lines.length; line++) {
		if(matches(threshold_lines[line], ".*Pix2deg ratio:.*")){ //Get the calibration ratio
			pix_to_degree_ratio = parseFloat(threshold_lines[line+1]);
			print(pix_to_degree_ratio);
		}
		//Get the threshold values
		if(matches(threshold_lines[line], "^-?[0-9]+(\\.[0-9]+)?\t-?[0-9]+(\\.[0-9]+)?\t-?[0-9]+(\\.[0-9]+)?\t-?[0-9]+(\\.[0-9]+)?")){
			threshold_list = split(threshold_lines[line], "\t");
			for(i=0; i<threshold_list.length; i++) threshold_list[i] = parseFloat(threshold_list[i]);
			for(i=1; i<3; i++)threshold_list[i] = round(threshold_list[i]/pix_to_degree_ratio)+maia_width/2; //Scale coordinates
			selectWindow("MAIA thresholds");
			makeOval(threshold_list[1]-fiducial_radius, threshold_list[2]-fiducial_radius, 2*fiducial_radius, 2*fiducial_radius);
			setSlice(1);
			run("Set...", "value=" + threshold_list[0] + " slice");
			setSlice(2);
			run("Set...", "value=" + threshold_list[3] + " slice");
			run("Select None");
			n_thresholds++;
		}
	}
	//Save MAIA thresholds image
	print("" + n_thresholds + " MAIA thresholds were found (excluding the optic nerve)."); 
	saveAs("Tiff", parent + "/Unregistered MAIA thresholds.tif");
	return n_thresholds;
}


function registerImages(maia_path, oct_path){
	//Get file names
	maia_file = File.getName(maia_path);
	oct_file = File.getName(oct_path);
	parent = File.getParent(oct_path);
	parent = File.getParent(parent);
	
	//Open images and resize to largest image
	open(maia_path);
	selectWindow(maia_file);
	getDimensions(maia_width, maia_height, dummy, dummy, dummy);
	open(oct_path);
	selectWindow(oct_file);
	getDimensions(oct_width, oct_height, dummy, dummy, dummy);

	if(maia_width*maia_height > oct_width*oct_height){
		selectWindow(oct_file);
		run("Size...", "width=" + maia_width + " height=" + maia_height + " depth=1 average interpolation=Bicubic");
	}
	else{
		selectWindow(maia_file);
		run("Size...", "width=" + oct_width + " height=" + oct_height + " depth=1 average interpolation=Bicubic");
	}
	
	//Enhance vessel contrast
	run("Concatenate...", "open image1=[" + maia_file + "] image2=[" + oct_file + "]");
	run("8-bit");
	run("Unsharp Mask...", "radius=10 mask=0.70 stack");
	run("Add...", "value=1 stack");
	run("Stack to Images");
	
	//Add on MAIA thresholds as channels so that they also get transformed
	selectWindow("Untitled-0001");
	run("Concatenate...", "  title=Untitled-0001 open image1=Untitled-0001 image2=[Unregistered MAIA thresholds.tif] image3=[-- None --]");
	run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
	selectWindow("Untitled-0002");
	run("Add Slice");
	run("Add Slice");
	run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
	
	//Linearly align OCT to MAIA
	run("Concatenate...", "open image1=Untitled-0002 image2=Untitled-0001 image3=[-- None --]");
	run("Linear Stack Alignment with SIFT MultiChannel", "registration_channel=1 initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Affine show_transformation_matrix");	close("Untitled");
	selectWindow("Aligned_Untitled");
	run("Duplicate...", "title=[Linear IDs] duplicate channels=2 slices=2"); //Keep a copy of the partially registered IDs, since this is the last version without interpolation
	
	//Save transform matrix
	selectWindow("Log");
	oct_name = File.getNameWithoutExtension(oct_path);
	selectWindow("Aligned_Untitled");
	Stack.setPosition(1, 2, 1);
	
	//Find Largest inscribed rectangle and crop to remove black border
	getDimensions(width, height, channels, slices, frames);
	xm = width/2;
	ym = height/2;
	x=xm;
	y=ym;
	w=1;
	h=1;
	xf=-1;
	yf=-1;
	hf=-1;
	wf=-1;
	for(r=1; r<=xm; r++){ //Search for largest inscribed rectangle
		if(xf<0){ //Look for left 0
			x--;
			w++;
			makeRectangle(x, y, w, h);
			getStatistics(area, mean, min);
			if(min<1) xf=++x;
			
		}
		if(yf<0){ //Look for top 0
			y--;
			h++;
			makeRectangle(x, y, w, h);
			getStatistics(area, mean, min);
			if(min<1) yf=++y;
		}
		if(wf<0){ //Look for right 0
			w++;
			makeRectangle(x, y, w, h);
			getStatistics(area, mean, min);
			if(min<1) wf=--w;
		}
		if(yf<0){ //Look for bottom 0
			h++;
			makeRectangle(x, y, w, h);
			getStatistics(area, mean, min);
			if(min<1) hf=--h;
		}
	}
	run("Crop");
	run("Select None");
	
	//Parse stack for bUnwarpJ
	selectWindow("Aligned_Untitled");
	run("Stack Splitter", "number=2");
	close("Aligned_Untitled");
	selectWindow("stk_0001_Aligned_Untitled");
	while(nSlices>1){
		setSlice(nSlices);
		run("Delete Slice");
	}
	selectWindow("stk_0002_Aligned_Untitled");
	run("Stack to Images");
	
	if(manual_override){
		setBatchMode("exit and display");
		waitForUser("Perform elastic transform and save transform matrix as \"SIFT forward elastic transform matrix.txt\" in parent folder.");
		image_list = getList("image.titles");
		for(index=0; index<image_list.length; index++){
			selectWindow(image_list[index]);
			setBatchMode("hide");
		}
	}
	else run("bUnwarpJ", "source_image=stk_0002_Aligned_Untitled-0001 target_image=stk_0001_Aligned_Untitled registration=Mono image_subsample_factor=0 initial_deformation=[" + unwarp_res[unwarp_initial_res] + "] final_deformation=[" + unwarp_res[unwarp_final_res]  + "] divergence_weight=0 curl_weight=0 landmark_weight=0 image_weight=1 consistency_weight=10 stop_threshold=0.01 save_transformations save_direct_transformation=[" + parent + "/SIFT forward elastic transform matrix.txt] save_inverse_transformation=[" + parent +"/SIFT reverse elastic inverse transform matrix.txt]");
	
	close("Registered Source Image");
	
	//Apply elastic transform to MAIA fiducials
	for(i=1; i<4; i++){
		call("bunwarpj.bUnwarpJ_.loadElasticTransform", parent + "/SIFT forward elastic transform matrix.txt", "stk_0001_Aligned_Untitled", "stk_0002_Aligned_Untitled-000" + i);
		selectWindow("stk_0002_Aligned_Untitled-000" + i);
		setMinAndMax(0, 255);
		run("8-bit");
	}
	
	//Save a preview of the registration
	run("Concatenate...", "open image1=stk_0001_Aligned_Untitled image2=stk_0002_Aligned_Untitled-0001 image3=[-- None --]");
	selectWindow("Untitled");
	Stack.setFrameRate(1);
	run("Grays");
	saveAs("Gif", parent + "/Registration preview.gif");
	sample = File.getName(parent);
	saveAs("Gif", out_dir + "/" + sample + ".gif");
	
	//Save fiducials
	selectWindow("stk_0002_Aligned_Untitled-0002");
	setLut(reds, greens, blues);
	run("Enhance Contrast", "saturated=0.01");
	saveAs("Tiff", parent + "/MAIA registered IDs.tif");
	selectWindow("stk_0002_Aligned_Untitled-0003");
	setLut(reds, greens, blues);
	run("Enhance Contrast", "saturated=0.01");
	saveAs("Tiff", parent + "/MAIA registered thresholds.tif");

	//Get coordinates of fiducials
	newImage("ref", "32-bit black", n_thresholds, 4, 1);
	run("Set Measurements...", "center median redirect=None decimal=3");
	
	//Get IDs of fiducials
	selectWindow("MAIA registered IDs.tif");
	setThreshold(1, 255);
	run("Analyze Particles...", "size=" + fiducial_radius*fiducial_radius + "-Infinity show=[Nothing] display clear");
	if(nResults != n_thresholds){
		master_error_count++;
		print("ERROR: " + nResults + " of " + n_thresholds + " MAIA IDs were found.");
	}
	id_found = newArray(256);
	for(i=0; i<nResults; i++){
		//Get results
		x = getResult("XM", i);
		y = getResult("YM", i);
		selectWindow("MAIA registered IDs.tif");
		id = getPixel(x, y);
		if(id_found[id] == 0) id_found[id] = 1;
		else{
			master_error_count++;
			print("ERROR: ID #" + id + " was found more than once"); 
		}
		selectWindow("ref");
		setPixel(i,0,id);
		setPixel(i,1,x);
		setPixel(i,2,y);
	}
	
	//Get fiducial thresholds
	selectWindow("MAIA registered thresholds.tif");
	setThreshold(1, 255);
	run("Analyze Particles...", "size=" + fiducial_radius*fiducial_radius + "-Infinity show=[Nothing] display clear");
	if(nResults != n_thresholds){
		master_error_count++;
		print("ERROR: " + nResults + " of " + n_thresholds + " MAIA IDs were found.");
	}
	id_found = newArray(256);
	for(i=0; i<nResults; i++){
		//Get results
		selectWindow("ref");
		id = getPixel(i, 0);
		x = getPixel(i, 1);
		y = getPixel(i, 2);
		selectWindow("MAIA registered thresholds.tif");
		thresh = getPixel(x, y);
		if(thresh == 0){
			master_error_count++;
			print("ERROR: ID #" + id + " had a threshold of 0.");
		}
		selectWindow("ref");
		setPixel(i,3,thresh);
	}
	
	//Verify values against the MAIA thresholds table
	threshold_string = File.openAsString(maia_threshold_path); //https://imagej.nih.gov/ij/macros/Find.txt
	threshold_lines = split(threshold_string, "\n");
	
	//Search for metadata in file
	selectWindow("MAIA registered thresholds.tif");
	getDimensions(maia_width, maia_height, dummy, dummy, dummy);
	error = false;
	for (line=0; line<threshold_lines.length; line++) {
		//Get the threshold values
		if(matches(threshold_lines[line], "^-?[0-9]+(\\.[0-9]+)?\t-?[0-9]+(\\.[0-9]+)?\t-?[0-9]+(\\.[0-9]+)?\t-?[0-9]+(\\.[0-9]+)?")){
			threshold_list = split(threshold_lines[line], "\t");
			for(i=0; i<threshold_list.length; i++) threshold_list[i] = parseFloat(threshold_list[i]);
			id_found = false;
			selectWindow("ref");
			for(i=0; i<n_thresholds && !id_found; i++){ //Search across ref table for matching ID
				id = getPixel(i,0);
				if(id == threshold_list[0]){ //If matching ID found on ref table
					id_found = true;
					t = getPixel(i, 3);
					if(t != threshold_list[3]){ //check that threshold matches too
						master_error_count++;
						print("ERROR: ID #" + id + " threshold value has changed from " + threshold_list[3] + " to " + t + " during registration.");
						error = true;
					}
				}
			}
			if(!id_found){
				if(threshold_list[0] == 0) print("Warning: ID #" + threshold_list[0] + " is missing from the registered image."); //If optic nerve, print warning
				else{
					master_error_count++;
					print("ERROR: ID #" + threshold_list[0] + " is missing from the registered image."); //If optic nerve, print warning
					error = true;
				}
			}	
		}
	}
	if(!error) print("Success! All fiducials were correctly recovered.");
	
	//Output results to table
	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
	}
	selectWindow("ref");
	for(i=0; i<255; i++){
		for(col=0; col<n_thresholds; col++){
			id = getPixel(col,0);
			if(id == i){
				x = getPixel(col,1);
				y = getPixel(col,2);
				t = getPixel(col,3);
				setResult("ID", nResults, id);
				setResult("XM", nResults-1, x);
				setResult("YM", nResults-1, y);
				setResult("Threshold", nResults-1, t);
			}
		}
	}
	
	//Save registration log and linear sift matrix
	updateResults();
	selectWindow("Log");
	saveAs("Text", parent + "/SIFT linear transform matrix and registration log.txt");
	selectWindow("Results");
	saveAs("Results", parent + "/Registered MAIA thresholds.csv");
	run("Close");
	close("*");
	return error;	
}