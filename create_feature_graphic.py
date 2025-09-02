#!/usr/bin/env python3
"""
Create a feature graphic for Google Play Store
1024x500 pixels with app icon and text
"""

import os
from PIL import Image, ImageDraw, ImageFont

def create_feature_graphic():
    # Create a new image with gradient background
    width, height = 1024, 500
    
    # Create base image with gradient
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create a gradient background (dark blue to light blue)
    for y in range(height):
        # Gradient from dark blue to lighter blue
        r = int(20 + (y / height) * 40)  # 20 to 60
        g = int(50 + (y / height) * 80)  # 50 to 130
        b = int(100 + (y / height) * 100)  # 100 to 200
        draw.rectangle([(0, y), (width, y+1)], fill=(r, g, b))
    
    # Load and resize the app icon
    try:
        icon = Image.open('flow_ai_icon_512.png')
        # Resize icon to fit nicely (about 300px)
        icon_size = 300
        icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        
        # Position icon on the left side
        icon_x = 80
        icon_y = (height - icon_size) // 2
        
        # Paste icon with alpha channel
        img.paste(icon, (icon_x, icon_y), icon)
    except Exception as e:
        print(f"Could not load icon: {e}")
    
    # Try to add text
    try:
        # Try to use a system font
        font_size = 60
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 32)
    except:
        # Fallback to default font
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    # Add text
    text_x = 420  # Start text after icon
    title_text = "Flow AI"
    subtitle_text = "AI-Powered Health Insights"
    description_text = "Personalized wellness tracking\nwith intelligent recommendations"
    
    # Draw title
    draw.text((text_x, 120), title_text, fill=(255, 255, 255), font=title_font)
    
    # Draw subtitle
    draw.text((text_x, 200), subtitle_text, fill=(200, 220, 255), font=subtitle_font)
    
    # Draw description
    draw.text((text_x, 280), description_text, fill=(180, 200, 255), font=subtitle_font)
    
    # Save as PNG
    img.save('flow_ai_feature_graphic.png', 'PNG')
    print("Feature graphic created: flow_ai_feature_graphic.png")
    print(f"Size: {width}x{height} pixels")

if __name__ == "__main__":
    create_feature_graphic()
