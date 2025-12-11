from PIL import Image

# Load the original logo (1024x1024 with full logo)
original = Image.open('assets/icon/Group 213 (2).png').convert('RGBA')

# Resize logo to 50% (512x512)
small_logo = original.resize((512, 512), Image.Resampling.LANCZOS)

# Create 1024x1024 canvas with transparent background
foreground = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))

# Paste small logo in center
foreground.paste(small_logo, ((1024-512)//2, (1024-512)//2), small_logo)

# Now make only WHITE parts visible, everything else transparent
pixels = foreground.load()
for y in range(1024):
    for x in range(1024):
        r, g, b, a = pixels[x, y]
        # If it's green (background), make fully transparent
        if r < 100 and g > 50 and b < 50:  # Greenish color
            pixels[x, y] = (0, 0, 0, 0)
        # If it's white/light (logo), keep it white
        elif r > 200 and g > 200 and b > 200:
            pixels[x, y] = (255, 255, 255, 255)

foreground.save('assets/icon/foreground_final.png')
print('Proper foreground created with small centered logo')
