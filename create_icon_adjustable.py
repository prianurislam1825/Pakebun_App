from PIL import Image, ImageDraw

# SESUAIKAN NILAI INI SAMPAI PAS:
LOGO_SIZE = 350  # Ukuran logo dalam pixels (coba dari 400-600)

print(f"Creating icon with logo size: {LOGO_SIZE}px")

# Load original logo
original = Image.open('assets/icon/Group 213 (2).png').convert('RGBA')

# Resize logo
small_logo = original.resize((LOGO_SIZE, LOGO_SIZE), Image.Resampling.LANCZOS)

# Create 1024x1024 with green background
canvas = Image.new('RGB', (1024, 1024), (43, 76, 0))

# Paste logo in center
x = (1024 - LOGO_SIZE) // 2
y = (1024 - LOGO_SIZE) // 2
canvas.paste(small_logo, (x, y), small_logo)

# Save
canvas.save('assets/icon/icon_custom.png')

# Also create foreground (white logo only)
foreground = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
pixels_fg = foreground.load()
pixels_logo = small_logo.load()

for py in range(LOGO_SIZE):
    for px in range(LOGO_SIZE):
        r, g, b, a = pixels_logo[px, py]
        if r > 200 and g > 200 and b > 200:  # White parts
            pixels_fg[x + px, y + py] = (255, 255, 255, 255)

foreground.save('assets/icon/foreground_custom.png')

print(f"Created: icon_custom.png and foreground_custom.png")
print(f"Jika masih kepotong, EDIT script ini dan PERKECIL nilai LOGO_SIZE")
print(f"Jika terlalu kecil, PERBESAR nilai LOGO_SIZE")
