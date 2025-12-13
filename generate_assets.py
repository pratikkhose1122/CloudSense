from PIL import Image, ImageDraw, ImageFilter
import os
import math

def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

def draw_sun(size=512):
    # Create RGBA image
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Core Sun
    center = size // 2
    radius = size // 3
    
    # Glow (multiple translucent layers)
    for i in range(20):
        r = radius + (20 - i) * 2
        alpha = int(10 + i * 5)
        draw.ellipse([center - r, center - r, center + r, center + r], fill=(255, 200, 50, alpha))
        
    # Main body
    draw.ellipse([center - radius, center - radius, center + radius, center + radius], fill=(255, 215, 0, 255))
    
    return img

def draw_moon(size=512):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    radius = size // 3
    
    # Draw large white circle
    draw.ellipse([center - radius, center - radius, center + radius, center + radius], fill=(240, 240, 240, 255))
    
    # Subtract to make crescent (using a slightly offset darker/transparent circle?? No, simpler to just draw another one)
    # Actually PIL draw doesn't support 'subtract' easily in one go without masks.
    # Let's use a mask.
    
    mask = Image.new('L', (size, size), 0)
    d_mask = ImageDraw.Draw(mask)
    d_mask.ellipse([center - radius, center - radius, center + radius, center + radius], fill=255)
    
    # Shadow circle to cut out
    offset = radius // 2
    d_mask.ellipse([center - radius + offset, center - radius - 20, center + radius + offset, center + radius - 20], fill=0)
    
    # Composite
    moon_color = Image.new('RGBA', (size, size), (255, 252, 230, 255))
    img = Image.composite(moon_color, Image.new('RGBA', (size, size), (0,0,0,0)), mask)
    
    # Add soft glow
    glow = img.filter(ImageFilter.GaussianBlur(10))
    img = Image.alpha_composite(glow, img)
    
    return img

def draw_cloud(size=512, complexity='mid'):
    img = Image.new('RGBA', (size, size // 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Base color
    color = (255, 255, 255, 240)
    
    # Helpers
    def draw_puff(x, y, r):
        draw.ellipse([x-r, y-r, x+r, y+r], fill=color)
    
    w, h = size, size // 2
    cx, cy = w // 2, h // 2
    
    # Draw blobs based on complexity
    if complexity == 'far':
        # Simple pill shape
        draw_puff(cx, cy, 60)
        draw_puff(cx - 50, cy + 10, 40)
        draw_puff(cx + 50, cy + 10, 40)
        
    elif complexity == 'mid':
        draw_puff(cx, cy - 20, 70)
        draw_puff(cx - 60, cy + 10, 50)
        draw_puff(cx + 60, cy + 10, 50)
        draw_puff(cx - 30, cy + 30, 50)
        draw_puff(cx + 30, cy + 30, 50)

    elif complexity == 'near':
        draw_puff(cx, cy - 30, 90)
        draw_puff(cx - 80, cy + 10, 70)
        draw_puff(cx + 80, cy + 10, 70)
        draw_puff(cx - 40, cy + 40, 60)
        draw_puff(cx + 40, cy + 40, 60)
    
    # Blur to soften edges
    img = img.filter(ImageFilter.GaussianBlur(3))
    return img

def main():
    assets_dir = 'c:/Users/prati/AndroidStudioProjects/weatherwise/assets/images/'
    ensure_dir(assets_dir)
    
    print("Generating sun...")
    draw_sun().save(os.path.join(assets_dir, 'sun.png'))
    
    print("Generating moon...")
    draw_moon().save(os.path.join(assets_dir, 'moon.png'))
    
    print("Generating cloud_far...")
    draw_cloud(512, 'far').save(os.path.join(assets_dir, 'cloud_far.png'))
    
    print("Generating cloud_mid...")
    draw_cloud(600, 'mid').save(os.path.join(assets_dir, 'cloud_mid.png'))
    
    print("Generating cloud_near...")
    draw_cloud(800, 'near').save(os.path.join(assets_dir, 'cloud_near.png'))
    
    print("Done!")

if __name__ == '__main__':
    main()
