import cv2
import os

def create_video(frames_folder, output_path, fps):
    frames = []
    height, width, layers = 0, 0, 0
    # Loop through all the files in the input folder
    filenames = sorted(os.listdir(frames_folder), key=lambda x: int(x.split("frame")[1].split(".")[0]))
    for filename in filenames:
        # Check if the file is an image (based on file extension)
        if filename.endswith(".jpg") or filename.endswith(".jpeg") or filename.endswith(".png"):
            # Load the image
            img = cv2.imread(os.path.join(frames_folder, filename))
            frames.append(img)
            if not height:
                height, width, layers = img.shape
    # Create video writer object
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    video = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
    # Add frames to video
    for frame in frames:
        video.write(frame)
    # Release video writer and print success message
    video.release()
    print("Video created successfully!")


