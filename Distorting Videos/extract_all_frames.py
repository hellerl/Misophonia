import cv2
import os

def extract_frames(video_path, output_path):
    # Create output folder if it doesn't exist
    if not os.path.exists(output_path):
        os.makedirs(output_path)

    # Read video
    vidcap = cv2.VideoCapture(video_path)
    success, image = vidcap.read()
    print(success)
    count = 0

    # Extract frames
    while success:
        # Save frame as JPEG file
        cv2.imwrite(os.path.join(output_path, "frame%d.jpg" % count), image)

        success, image = vidcap.read()
        count += 1

    print("%d frames extracted from %s" % (count, video_path))
