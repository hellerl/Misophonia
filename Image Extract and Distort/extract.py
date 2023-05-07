import os
import cv2


def extract_middle_frames(input_folder, output_folder):
    # Create the output folder if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Loop through all the files in the input folder
    for filename in os.listdir(input_folder):
        # Check if the file is a video file
        if filename.endswith('.mp4') or filename.endswith('.mov'):
       
            video = cv2.VideoCapture(os.path.join(input_folder, filename))

            # Get the total number of frames in the video
            num_frames = int(video.get(cv2.CAP_PROP_FRAME_COUNT))

            middle_frame = int(num_frames / 2)

            # Set the video frame position to the middle frame
            video.set(cv2.CAP_PROP_POS_FRAMES, middle_frame)

            # Read the frame from the video
            ret, frame = video.read()

            # Save the middle frame as an image
            output_file = os.path.join(output_folder, os.path.splitext(filename)[0] + '.jpg')
            cv2.imwrite(output_file, frame)

            video.release()



