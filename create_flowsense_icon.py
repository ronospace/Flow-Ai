#!/usr/bin/env python3
"""
FlowSense App Icon Generator
Creates a beautiful, professional app icon for the FlowSense period tracking app.
"""

from PIL import Image, ImageDraw, ImageFont
import math
import numpy as np

def create_flowsense_icon(size=1024):
    """Create a professional FlowSense app icon with circular flow design."""
    
    # Create a new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Define colors - modern feminine health palette
    primary_color = (103, 58, 183)      # Deep purple
    secondary_color = (156, 39, 176)    # Bright magenta
    accent_color = (255, 64, 129)       # Pink accent
    light_color = (255, 183, 197)       # Light pink
    gradient_end = (240, 98, 146)       # Coral pink
    
    center = size // 2
    
    # Create gradient background circle
    for i in range(center):
        # Calculate gradient color
        ratio = i / center
        r = int(primary_color[0] + (gradient_end[0] - primary_color[0]) * ratio)
        g = int(primary_color[1] + (gradient_end[1] - primary_color[1]) * ratio)
        b = int(primary_color[2] + (gradient_end[2] - primary_color[2]) * ratio)
        
        color = (r, g, b, 255)
        
        # Draw concentric circles for gradient effect
        draw.ellipse(
            [(center - i, center - i), (center + i, center + i)],
            fill=color
        )
    
    # Create the flow pattern - representing menstrual cycle phases
    num_rings = 3
    for ring in range(num_rings):
        ring_radius = center * 0.3 + ring * (center * 0.15)
        ring_thickness = size // 40
        
        # Calculate ring color based on distance from center
        ring_ratio = ring / (num_rings - 1)
        ring_r = int(255 + (light_color[0] - 255) * ring_ratio)
        ring_g = int(255 + (light_color[1] - 255) * ring_ratio)
        ring_b = int(255 + (light_color[2] - 255) * ring_ratio)
        ring_color = (ring_r, ring_g, ring_b, 200 - ring * 50)
        
        # Draw flow ring with gaps to represent cycle phases
        for angle in range(0, 360, 15):
            if angle % 45 < 30:  # Create gaps in the rings
                start_angle = angle - 7
                end_angle = angle + 7
                
                # Convert to radians
                start_rad = math.radians(start_angle)
                end_rad = math.radians(end_angle)
                
                # Calculate arc points
                inner_radius = ring_radius - ring_thickness // 2
                outer_radius = ring_radius + ring_thickness // 2
                
                # Create arc path
                arc_points = []
                for a in np.linspace(start_rad, end_rad, 20):
                    x1 = center + inner_radius * math.cos(a)
                    y1 = center + inner_radius * math.sin(a)
                    arc_points.append((x1, y1))
                
                for a in np.linspace(end_rad, start_rad, 20):
                    x2 = center + outer_radius * math.cos(a)
                    y2 = center + outer_radius * math.sin(a)
                    arc_points.append((x2, y2))
                
                if len(arc_points) > 2:
                    draw.polygon(arc_points, fill=ring_color)
    
    # Add central symbol - stylized "F" for FlowSense
    symbol_size = size // 6
    symbol_thickness = size // 40
    symbol_x = center - symbol_size // 3
    symbol_y = center - symbol_size // 2
    
    # Draw "F" symbol
    # Vertical line
    draw.rectangle([
        (symbol_x, symbol_y),
        (symbol_x + symbol_thickness, symbol_y + symbol_size)
    ], fill=(255, 255, 255, 255))
    
    # Top horizontal line
    draw.rectangle([
        (symbol_x, symbol_y),
        (symbol_x + symbol_size // 2, symbol_y + symbol_thickness)
    ], fill=(255, 255, 255, 255))
    
    # Middle horizontal line (shorter)
    middle_y = symbol_y + symbol_size // 3
    draw.rectangle([
        (symbol_x, middle_y),
        (symbol_x + symbol_size // 3, middle_y + symbol_thickness)
    ], fill=(255, 255, 255, 255))
    
    # Add subtle glow effect around the symbol
    glow_size = symbol_size + size // 20
    glow_x = center - glow_size // 3
    glow_y = center - glow_size // 2
    
    for glow_layer in range(5):
        glow_alpha = 30 - glow_layer * 5
        if glow_alpha > 0:
            glow_expand = glow_layer * 2
            # Glow for vertical line
            draw.rectangle([
                (symbol_x - glow_expand, symbol_y - glow_expand),
                (symbol_x + symbol_thickness + glow_expand, symbol_y + symbol_size + glow_expand)
            ], fill=(255, 255, 255, glow_alpha))
    
    return img

def main():
    """Generate FlowSense app icon in multiple sizes."""
    print("🎨 Creating professional FlowSense app icon...")
    
    # Generate the main icon
    icon_1024 = create_flowsense_icon(1024)
    
    # Save the main icon
    icon_1024.save('flowsense_icon_1024.png', 'PNG')
    print("✅ Created flowsense_icon_1024.png")
    
    # Create smaller versions for different uses
    sizes = [512, 256, 128, 64, 32]
    for size in sizes:
        resized_icon = icon_1024.resize((size, size), Image.Resampling.LANCZOS)
        resized_icon.save(f'flowsense_icon_{size}.png', 'PNG')
        print(f"✅ Created flowsense_icon_{size}.png")
    
    # Replace the current icon file
    icon_1024.save('flowsense_current.png', 'PNG')
    print("✅ Updated flowsense_current.png")
    
    print("\n🌟 FlowSense app icon generation complete!")
    print("📱 The new icon features:")
    print("   • Modern gradient background in feminine health colors")
    print("   • Circular flow pattern representing menstrual cycles")
    print("   • Stylized 'F' symbol for FlowSense branding")
    print("   • Professional design suitable for app stores")

if __name__ == "__main__":
    main()
