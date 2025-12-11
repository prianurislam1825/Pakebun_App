from PIL import Image
import numpy as np

# Load smaller logo
img = Image.open('assets/icon/Group 213 (4).png').convert('RGBA')
data = np.array(img)

# Create mask: where color is NOT green (43, 76, 0)
is_not_green = (data[:, :, 0] != 43) | (data[:, :, 1] != 76) | (data[:, :, 2] != 0)

# Create foreground: white logo with transparency
foreground = np.zeros((1024, 1024, 4), dtype=np.uint8)
foreground[:, :, :3] = 255  # White
foreground[:, :, 3] = is_not_green.astype(np.uint8) * 255  # Alpha

# Save
fg_img = Image.fromarray(foreground, 'RGBA')
fg_img.save('assets/icon/foreground2.png')
print('Smaller foreground created')
