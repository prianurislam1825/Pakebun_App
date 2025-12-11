from PIL import Image
import numpy as np

# Load image
img = Image.open('assets/icon/Group 213 (3).png').convert('RGBA')
data = np.array(img)

# Create mask: where color is NOT green (43, 76, 0)
green = np.array([43, 76, 0])
mask = ~np.all(data[:, :, :3] == green, axis=-1)

# Create foreground: white logo with transparency
foreground = np.zeros_like(data)
foreground[:, :, :3] = 255  # White
foreground[:, :, 3] = mask.astype(np.uint8) * 255  # Alpha from mask

# Save
fg_img = Image.fromarray(foreground, 'RGBA')
fg_img.save('assets/icon/foreground.png')
print('Foreground created: assets/icon/foreground.png')
