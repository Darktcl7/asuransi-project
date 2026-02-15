from PIL import Image
import os

# Source image
src = r"C:\Users\chlui\.gemini\antigravity\brain\65b7c98d-8dd0-4322-98b9-9d9a15d728d5\smile_app_icon_1768648693166.png"

# Target directories and sizes for Android
targets = {
    r"D:\Django Project\Asuransi Project\phone_insurance_app\android\app\src\main\res\mipmap-mdpi": 48,
    r"D:\Django Project\Asuransi Project\phone_insurance_app\android\app\src\main\res\mipmap-hdpi": 72,
    r"D:\Django Project\Asuransi Project\phone_insurance_app\android\app\src\main\res\mipmap-xhdpi": 96,
    r"D:\Django Project\Asuransi Project\phone_insurance_app\android\app\src\main\res\mipmap-xxhdpi": 144,
    r"D:\Django Project\Asuransi Project\phone_insurance_app\android\app\src\main\res\mipmap-xxxhdpi": 192,
}

# Open source image
img = Image.open(src)

for target_dir, size in targets.items():
    # Resize image
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Save as ic_launcher.png
    output_path = os.path.join(target_dir, "ic_launcher.png")
    resized.save(output_path, "PNG")
    print(f"Saved {size}x{size} to {output_path}")

print("Done!")
