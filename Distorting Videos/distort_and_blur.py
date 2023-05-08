import numpy as np
import cv2
import os
from PIL import Image

def set_randomization(n):
    section_indices = np.arange(n ** 2)
    np.random.shuffle(section_indices)
    return section_indices
indices_array = set_randomization(16)

def shuffle_image(image, n):
    # Get the dimensions of the image
    h, w = image.shape[:2]

    # Calculate the dimensions of each section
    section_h = h // n
    section_w = w // n

    #section_indices = np.array([3, 0, 2, 1])
    section_indices = indices_array

    # Reshape the section indices into a grid
    section_indices = section_indices.reshape((n, n))

    # Create an array to hold the shuffled image
    shuffled_image = np.zeros_like(image)

    # Iterate over each section
    for i in range(n):
        for j in range(n):
            # Calculate the coordinates of the current section
            top = i * section_h
            bottom = (i + 1) * section_h
            left = j * section_w
            right = (j + 1) * section_w

            # Get the section of the original image
            section = image[top:bottom, left:right]

            # Calculate the indices of the shuffled section
            new_i, new_j = np.unravel_index(section_indices[i, j], (n, n))

            # Calculate the coordinates of the new section
            new_top = new_i * section_h
            new_bottom = (new_i + 1) * section_h
            new_left = new_j * section_w
            new_right = (new_j + 1) * section_w

            # Put the section in its new location in the shuffled image
            shuffled_image[new_top:new_bottom, new_left:new_right] = section

    return shuffled_image

def image_manipulation(input_folder): 
    os.makedirs(input_folder + "_manipulated")
    output_folder = input_folder + "_manipulated"

    # Loop through all the files in the input folder
    for filename in os.listdir(input_folder):
        # Check if the file is an image (based on file extension)
        if filename.endswith(".jpg") or filename.endswith(".jpeg") or filename.endswith(".png"):

            img = cv2.imread(os.path.join(input_folder, filename))
            #cv2.imshow('original Image', img)
            img = shuffle_image(img,16)
            # Set the Gaussian kernel size and standard deviation
            ksize = (11, 11)
            sigma = 3

            # Apply Gaussian blur using "reflect" border mode
            img = cv2.GaussianBlur(img, ksize, sigma, borderType=cv2.BORDER_REFLECT)
            # cv2.imshow('distorted Image', img)

            # Check if the image is not None and has a valid size
            if img is not None and img.shape[0] > 0 and img.shape[1] > 0:
                # Save the processed image in the output folder
                output_path = os.path.join(output_folder, filename)
                cv2.imwrite(output_path, img)
            else:
                print("Error: Could not load or process image:", filename)
