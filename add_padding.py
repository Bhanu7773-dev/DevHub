from PIL import Image

def add_padding(image_path, output_path, padding_percent=0.25):
    img = Image.open(image_path).convert("RGBA")
    width, height = img.size
    
    # Calculate new size for the content
    new_width = int(width * (1 - padding_percent))
    new_height = int(height * (1 - padding_percent))
    
    # Resize the content
    resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    # Create a new transparent background
    new_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    
    # Paste the resized content in the center
    x_offset = (width - new_width) // 2
    y_offset = (height - new_height) // 2
    new_img.paste(resized_img, (x_offset, y_offset))
    
    new_img.save(output_path)
    print(f"Added padding to {image_path}")

if __name__ == "__main__":
    add_padding("assets/icon/app_icon.png", "assets/icon/app_icon.png")
