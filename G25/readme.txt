Computer Vision Challenge 2019
Group Number: G25
Group Number: Zeen Song, Xiajun Zhou, Shengzhi Wang, Yikai Xu, Lei Wang

Instruction for Code Challenge.m
First, tpye in your favourite scene_path from different subfolders. Each subfolder contains two pictures, which both shoot for one scene. One Picture stands for left camera frame and another one for right camera frame. 
Second, Choose one disparity_map function to run. Here we have offered different methods for getting the disparity map. One way is Block Match and another is Global Match. In the function we have defined, that all data in the subfolder ,e.g. 2 frame pictures, calibration matrix for both cameras, will be loaded in the matlab Workspace. After this disparity map function you can get Disparity map matrix, Rotation Matrix and Translation Matrix. Disparity Matrix will be automaticlly polt out with color bar. In the Disparity map plot, Red means close location and blue for far location.
Third，This function calculates the PSNR of a given disparity map. You kann put the variable Disparity map (D) and Groundtruth (G) direct in the function:verify_dmap(D, G). You kann run this function in the command line.  The Results will show in the command window.


Instruction for the function test.m
this function test the D,T,R, if the variables bigger than 0, and the toolbox and tolerenz.
before  run the function test.m, the users should run the function check_psnr and the function disparitymap_GM, disparitymap_census, verify_damp. than users kann run the function test.m . all the Test-results will show in the command window.


Instruction for GUI
You can click "Start GUI". Then you will see a UI interface which you can choose bottons to click. First you click the button "Import path" and it will automaticlly upload the stero pictures in the path. 
Second you need to press the button "plot image" and then you can choose algorithms you like. Here we offer the option for different algorithms like we introduce in Report e.g. BM+cenus Transforma or GM. 
Then you Click the button "Start Mapping", after some calculation time you will see the disparity map of this scene in the right side. 
And if you have Computer Vision toolbox, you can generate the 3D reconstruction of this picture by press the button "3D-Reconstruction".