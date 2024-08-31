import cv2
import numpy as np
import sys

def change_saturation(image_path, percentage):
    image = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    if image.shape[2] == 4:
        b, g, r, a = cv2.split(image)
        rgb_image = cv2.merge([b, g, r])
        hsv_image = cv2.cvtColor(rgb_image, cv2.COLOR_BGR2HSV)
    else:
        hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    
    h, s, v = cv2.split(hsv_image)
    
    base_factor = 1 - (percentage / 100.0)
    reduced_factor = 1 - (percentage * 2 / 100.0)
    increased_factor = 1 

    s_base = np.clip(s.astype(np.float32) * base_factor, 0, 255).astype(np.uint8)
    hsv_base = cv2.merge([h, s_base, v])
    base_saturation_image = cv2.cvtColor(hsv_base, cv2.COLOR_HSV2BGR)
    if image.shape[2] == 4:
        base_saturation_image = cv2.merge([base_saturation_image, a])
    base_saturation_image_path = 'base.png'
    cv2.imwrite(base_saturation_image_path, base_saturation_image)
    
    s_reduced = np.clip(s.astype(np.float32) * reduced_factor, 0, 255).astype(np.uint8)
    hsv_reduced = cv2.merge([h, s_reduced, v])
    reduced_saturation_image = cv2.cvtColor(hsv_reduced, cv2.COLOR_HSV2BGR)
    if image.shape[2] == 4:
        reduced_saturation_image = cv2.merge([reduced_saturation_image, a])
    reduced_saturation_image_path = 'base0.png'
    cv2.imwrite(reduced_saturation_image_path, reduced_saturation_image)

    s_increased = np.clip(s.astype(np.float32) * increased_factor, 0, 255).astype(np.uint8)
    hsv_increased = cv2.merge([h, s_increased, v])
    increased_saturation_image = cv2.cvtColor(hsv_increased, cv2.COLOR_HSV2BGR)
    if image.shape[2] == 4:
        increased_saturation_image = cv2.merge([increased_saturation_image, a])
    increased_saturation_image_path = 'base1.png'
    cv2.imwrite(increased_saturation_image_path, increased_saturation_image)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <image_path> <percentaje>")
    else:
        image_path = sys.argv[1]
        percentage = float(sys.argv[2])
        change_saturation(image_path, percentage)