#!/usr/bin/env python3
"""
Simple script to create CycleAI logo PNG using PIL
"""

try:
    from PIL import Image, ImageDraw
    import math
    
    # Create a 1024x1024 image with transparent background
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Center point
    cx, cy = size // 2, size // 2
    
    # Background circle with gradient effect (simplified)
    radius = 460
    
    # Create gradient effect by drawing multiple circles
    for i in range(20):
        r = radius - i * 15
        alpha = 255 - i * 8
        # Gradient from pink to purple to blue
        if i < 7:
            color = (255, 107 + i * 10, 157 + i * 5, alpha)  # Pink to purple
        elif i < 14:
            color = (193 - (i-7) * 15, 71 + (i-7) * 10, 233, alpha)  # Purple to blue
        else:
            color = (79, 70, 229, alpha)  # Deep blue
        
        draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=color)
    
    # Main cycle symbol - infinity loop style
    # Create thick white lines for the cycle pattern
    line_width = 25
    
    # Draw infinity symbol using arcs
    # Left loop
    draw.arc([cx-200, cy-100, cx, cy+100], 0, 180, fill=(255, 255, 255, 230), width=line_width)
    draw.arc([cx-200, cy-100, cx, cy+100], 180, 360, fill=(255, 255, 255, 230), width=line_width)
    
    # Right loop  
    draw.arc([cx, cy-100, cx+200, cy+100], 0, 180, fill=(255, 255, 255, 230), width=line_width)
    draw.arc([cx, cy-100, cx+200, cy+100], 180, 360, fill=(255, 255, 255, 230), width=line_width)
    
    # Central AI node
    draw.ellipse([cx-40, cy-40, cx+40, cy+40], fill=(255, 255, 255, 230))
    draw.ellipse([cx-30, cy-30, cx+30, cy+30], fill=(193, 71, 233, 255))  # Purple center
    
    # Neural connection lines
    conn_color = (255, 255, 255, 180)
    conn_width = 6
    
    # Top connections
    draw.line([cx, cy-30, cx, cy-120], fill=conn_color, width=conn_width)
    draw.ellipse([cx-15, cy-135, cx+15, cy-105], fill=conn_color)
    draw.line([cx, cy-120, cx-60, cy-180], fill=conn_color, width=conn_width)
    draw.line([cx, cy-120, cx+60, cy-180], fill=conn_color, width=conn_width)
    draw.ellipse([cx-75, cy-195, cx-45, cy-165], fill=conn_color)
    draw.ellipse([cx+45, cy-195, cx+75, cy-165], fill=conn_color)
    
    # Side connections
    draw.line([cx+30, cy, cx+120, cy], fill=conn_color, width=conn_width)
    draw.line([cx-30, cy, cx-120, cy], fill=conn_color, width=conn_width)
    draw.ellipse([cx+105, cy-15, cx+135, cy+15], fill=conn_color)
    draw.ellipse([cx-135, cy-15, cx-105, cy+15], fill=conn_color)
    
    # Bottom connections
    draw.line([cx, cy+30, cx, cy+120], fill=conn_color, width=conn_width)
    draw.ellipse([cx-15, cy+105, cx+15, cy+135], fill=conn_color)
    draw.line([cx, cy+120, cx-60, cy+180], fill=conn_color, width=conn_width)
    draw.line([cx, cy+120, cx+60, cy+180], fill=conn_color, width=conn_width)
    draw.ellipse([cx-75, cy+165, cx-45, cy+195], fill=conn_color)
    draw.ellipse([cx+45, cy+165, cx+75, cy+195], fill=conn_color)
    
    # Add some tech/data points
    tech_color = (0, 255, 255, 150)  # Cyan
    for angle in [0, 90, 180, 270]:
        x = cx + 350 * math.cos(math.radians(angle))
        y = cy + 350 * math.sin(math.radians(angle))
        draw.ellipse([x-8, y-8, x+8, y+8], fill=tech_color)
    
    # Save the image
    img.save('/Users/ronos/development/FlowSense/cycleai_icon.png')
    print("CycleAI logo created successfully as cycleai_icon.png")
    
except ImportError:
    print("PIL (Pillow) not available. Creating a simple placeholder icon...")
    # Create a simple colored square as fallback
    import os
    
    # Create a simple SVG that can be converted later
    simple_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF6B9D;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#C147E9;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#4F46E5;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <circle cx="512" cy="512" r="480" fill="url(#grad)"/>
  
  <!-- Infinity symbol for cycles -->
  <path d="M 320 512 Q 400 400, 512 512 Q 624 624, 704 512 Q 624 400, 512 512 Q 400 624, 320 512 Z" 
        fill="none" 
        stroke="white" 
        stroke-width="32" 
        stroke-linecap="round" 
        opacity="0.9"/>
  
  <!-- AI node -->
  <circle cx="512" cy="512" r="48" fill="white" opacity="0.9"/>
  <circle cx="512" cy="512" r="32" fill="#C147E9"/>
  
  <!-- Tech connections -->
  <g stroke="white" stroke-width="8" fill="white" opacity="0.7">
    <line x1="512" y1="464" x2="512" y2="360"/>
    <circle cx="512" cy="340" r="16"/>
    <line x1="560" y1="512" x2="664" y2="512"/>
    <circle cx="684" cy="512" r="16"/>
    <line x1="512" y1="560" x2="512" y2="664"/>
    <circle cx="512" cy="684" r="16"/>
    <line x1="464" y1="512" x2="360" y2="512"/>
    <circle cx="340" cy="512" r="16"/>
  </g>
  
  <!-- Data pulse points -->
  <circle cx="512" cy="240" r="8" fill="#00FFFF"/>
  <circle cx="784" cy="512" r="8" fill="#00FFFF"/>
  <circle cx="512" cy="784" r="8" fill="#00FFFF"/>
  <circle cx="240" cy="512" r="8" fill="#00FFFF"/>
</svg>'''
    
    with open('/Users/ronos/development/FlowSense/cycleai_icon.svg', 'w') as f:
        f.write(simple_svg)
    print("Created SVG fallback icon as cycleai_icon.svg")
