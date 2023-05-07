import numpy as np
import cv2
import os
from PIL import Image

def distort_lines(image_array):
    num_rows, num_cols, num_channels = image_array.shape

    # Compute the block size based on the image height
    block_size = int(num_rows /3)

    # Compute the number of blocks
    num_blocks = int(num_rows / block_size)

    # Create an array to store the distorted image
    distorted_image_array = np.zeros((num_rows, num_cols, num_channels), dtype=np.uint8)

    # Shuffle each block of lines
    for i in range(num_blocks):
        # Get the i-th block of lines
        block_start = i * block_size
        block_end = block_start + block_size
        block = image_array[block_start:block_end, :, :]

        # Shuffle the lines in the block
        np.random.shuffle(block)

        # Copy the shuffled block to the distorted image array
        distorted_image_array[block_start:block_end, :, :] = block

    return distorted_image_array

def loop_thru(input_folder):

    # Define the name of the new folder
    new_folder_name = "distorted_images"

    # Create a new folder
    if not os.path.exists(new_folder_name):
        os.makedirs(new_folder_name)

    # Loop through all the files in the input folder
    for filename in os.listdir(input_folder):
        # Check if the file is an image (based on file extension)
        if filename.endswith(".jpg") or filename.endswith(".jpeg") or filename.endswith(".png"):
            
            
            img = cv2.imread(os.path.join(input_folder, filename))
            img = distort_lines(img)

            if img is not None and img.shape[0] > 0 and img.shape[1] > 0:
                output_path = os.path.join(new_folder_name, filename)
                cv2.imwrite(output_path, img)
            else:
                print("Error: Could not load or process image:", filename)

