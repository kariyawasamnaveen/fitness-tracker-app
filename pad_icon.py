from PIL import Image
import os

img_path = 'assets/images/logo.png'
out_path = 'assets/images/padded_icon.png'

print("Opening image...")
img = Image.open(img_path).convert("RGBA")
orig_w, orig_h = img.size
print(f"Original size: {orig_w}x{orig_h}")

# We want the width to fit safely. Reducing the divisor slightly makes the canvas smaller, 
# which makes the logo appear slightly larger when the canvas is scaled down by Android.
canvas_size = int(orig_w / 0.58) # Changed from 0.55 to 0.58 for slight scale up
canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))

x = (canvas_size - orig_w) // 2
y = (canvas_size - orig_h) // 2

# Move the logo down a tiny bit by adding an offset to y
y_offset = 60 
y += y_offset

print(f"Pasting onto canvas of {canvas_size}x{canvas_size} at {x}, {y}")
canvas.paste(img, (x, y), img)

canvas.save(out_path)
print("Done!")
