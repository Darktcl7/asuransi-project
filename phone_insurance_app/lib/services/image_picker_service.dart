// lib/services/image_picker_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickFromGallery({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickFromCamera({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Show bottom sheet to choose image source
  Future<File?> pickImageWithDialog(BuildContext context) async {
    // First, show dialog to choose source
    final String? source = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Camera option
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, 'camera'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ambil Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600, // Smile Orange
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Gallery option
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(ctx, 'gallery'),
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih dari Galeri'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade600, // Smile Orange
                side: BorderSide(color: Colors.orange.shade600),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Cancel
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
    
    // Then pick image based on source
    if (source == 'camera') {
      return await pickFromCamera();
    } else if (source == 'gallery') {
      return await pickFromGallery();
    }
    
    return null;
  }

  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImages({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Get file size in MB
  Future<double> getFileSizeInMB(File file) async {
    try {
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }

  // Check if file size is within limit
  Future<bool> isFileSizeValid(File file, {double maxSizeMB = 5.0}) async {
    final sizeMB = await getFileSizeInMB(file);
    return sizeMB <= maxSizeMB;
  }
}
