import os
import extract_all_frames
import cv2
import distort_and_blur
import shutil
import piece_together

def loop_thru(input_folder):

    video_count = 0
    # Define the name of the new folder
    new_folder_name = "distorted_images"

    # Create a new folder
    if not os.path.exists(new_folder_name):
        os.makedirs(new_folder_name)

    # Loop through all the files in the input folder
    for filename in os.listdir(input_folder):
        
        # Check if the file is a video file
        if filename.endswith('.mp4') or filename.endswith('.mov'):
            # Open the video file
            video = cv2.VideoCapture(os.path.join(input_folder, filename))

            video_count +=1
            # Extract all frames and put them in a folder
            extract_output = filename + "%d" % video_count
            print(extract_output)
            extract_all_frames.extract_frames(os.path.join(input_folder, filename),extract_output)
            distort_and_blur.image_manipulation(extract_output)

            #remove the original extracted frames folder
            shutil.rmtree(extract_output)

            #piece together the frames
            distorted_images = extract_output + "_manipulated"
            piece_together.create_video(distorted_images,filename,30)
            shutil.rmtree(distorted_images)


def main():
    input_folder = "test_vids"
    print("execute start")
    loop_thru(input_folder)
    
if __name__ == "__main__":
    main()