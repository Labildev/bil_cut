import os
from PIL import Image, ImageDraw

source_path = r"C:\Users\inaya\.gemini\antigravity\brain\41d172f7-73ce-40c7-95a5-2df99aaec1e4\bil_cut_app_icon_1794159426678.jpg"
workspace_dir = r"d:\LABIL\MY_PROJECT\bil_cut"

# 1. Ensure assets/icons directory exists
assets_dir = os.path.join(workspace_dir, "assets", "icons")
os.makedirs(assets_dir, exist_ok=True)
master_asset_png = os.path.join(assets_dir, "app_icon.png")

# Open master image
img = Image.open(source_path).convert("RGBA")
img.save(master_asset_png, "PNG")
print(f"Master asset saved to {master_asset_png} (size: {img.size})")

# 2. Android mipmap densities and dimensions
mipmap_sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

res_dir = os.path.join(workspace_dir, "android", "app", "src", "main", "res")

def create_round_image(source_img):
    mask = Image.new('L', source_img.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, source_img.size[0], source_img.size[1]), fill=255)
    
    round_img = Image.new('RGBA', source_img.size, (0, 0, 0, 0))
    round_img.paste(source_img, (0, 0), mask=mask)
    return round_img

for folder, size in mipmap_sizes.items():
    target_dir = os.path.join(res_dir, folder)
    os.makedirs(target_dir, exist_ok=True)
    
    # Standard square/squircle icon
    target_path = os.path.join(target_dir, "ic_launcher.png")
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(target_path, "PNG", optimize=True)

    # Circular icon for Pixel/Samsung launchers
    round_path = os.path.join(target_dir, "ic_launcher_round.png")
    round_img = create_round_image(resized)
    round_img.save(round_path, "PNG", optimize=True)
    
    print(f"Generated {folder}: ic_launcher.png & ic_launcher_round.png ({size}x{size})")

print("All Android launcher icons successfully generated and applied!")
