# Extracting wing, body and flower kinematics
This repo contains code that extracts 3D wing and body kinematic trajectories of a free-flying hawkmoth and 3D trajectory of a robotic flower from the digitized 3D trajectories of a few specific wing, body and flower landmarks. The main file is located at 
```text
extract-kinematics/
├── src/
│   └── main_extractKinematics.m  
```

The code uses two .csv files as input data, generated from DeepLabCut:
1. Digitized 3D trajectories of specific tracked landmarks on the moth's body during free flight
2. Digitized plumbline points in 3D

The code loads these files from:
```text
extract-kinematics/
├── data-in/
|   ├── <trajectory_data>.csv
|   └── Plumbline/
│       └── <plumbline_data>.csv  
```

In the first few lines of the code, the user needs to specify the following:
* sampling rate (frame rate) of the digitized data
* frame range of interest
* total video length of interest (in seconds)
* condition (a short string to describe the flower movement condition e.g. "stationary", "sum-of-sines lateral")

The code runs the script "extractWingKinematicsRL.m" to analyze the data and calculates
* 3D trajectories of the robotic flower
* 3D trajectories of head, thorax, abdomen and wing landmarks
* body roll, pitch and yaw angles using a body-fixed frame (subscript 'b')
* wing kinematic angles w.r.t. stroke-plane frames (subscript 'SP') for left (subscript 'L') and right (subscript 'R') wings
* wing kinematic angles using transverse-plane frames (subscript 'TP') for left (subscript 'L') and right (subscript 'R') wings  

After extracting the wing and body kinematic trajectories, the code saves them as a .mat file in the folder  
```text
extract-kinematics/
├── data-out/
│   └── <kinematic_data>.mat  
```
where 3D trajectories are saved in the Matlab struct 'dataKinematics'.

Then, the code plots these trajectories against time in seconds (in some cases, number of wingstrokes).
