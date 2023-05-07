import extract
import line_distort
import os

def main():
    # Path to the folder containing the videos
    # name can be changed!!!
    input_folder = "BW videos"

    # Define the name of the new folder
    output_folder = "extracted_images"

    # Create a new folder
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    extract.extract_middle_frames(input_folder,output_folder)

    line_distort.loop_thru(output_folder)



if __name__ == "__main__":
    main()
