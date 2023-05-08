#Block-randomize and blur videos

Functionality:

This code is for making videos into a blocked and blurred form as
controls for other misophonic videos. This program loops through an
entire folder of videos, and distorts each video frame by frame. It
pieces the distorted frames together back into a video at the end.

Execution:

To excute this code, drag in a desired folder of videos, change the
input folder name in main.py and then run main.py

Also take note that you would need to be running main.py inside the
large folders. More specifically, if you use VScode for running, you
would need to click on file→ open folder → and open the folder from
whatever you have saved. The processing time might be long. Depending on
the size of the input video, it might take anywhere from 50 seconds to 2
minutes for each video, and 40 minutes to an hour for a folder of \~25
videos.

Notes:

All of the numbers in the code are hard-coded parameters that can be
changed. To change the frames per second for piecing together videos,
change the global variable FPS in main.py. To change the block sizes or
the blurriness, go to the file distort_and_blur.py and change the global
variables at the top.
