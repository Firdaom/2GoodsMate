import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:anigoods/core/theme/app_theme.dart';

class ImageUploadPicker extends StatelessWidget {
  // ช่องเสียบสายไฟ
  final List<XFile> imageFiles;
  final VoidCallback onPickImage;
  final Function(int) onRemoveImage;

  const ImageUploadPicker({
    super.key,
    required this.imageFiles,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  // ฟังก์ชันพรีวิวรูปภาพ
  Widget _buildImagePreview(XFile imageFile) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: imageFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.contain, width: double.infinity);
          }
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    } else {
      return Image.file(File(imageFile.path), fit: BoxFit.contain, width: double.infinity);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ imageFiles (ไม่มีขีดล่าง) แทน _imageFiles
    if (imageFiles.isEmpty) {
      return Center(
        child: GestureDetector(
          onTap: onPickImage, // ใช้ onPickImage แทน _pickImage
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.accentLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.accent.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppTheme.accent,
                  size: 32,
                ),
                SizedBox(height: 6),
                Text(
                  'Add Photos',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel with PageView
        Container(
          height: 280,
          color: AppTheme.accentLight,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(),
            pageSnapping: true,
            itemCount: imageFiles.length + 1, // ไม่มีขีดล่าง
            itemBuilder: (context, index) {
              if (index == imageFiles.length) { // ไม่มีขีดล่าง
                // Add More button
                return Center(
                  child: GestureDetector(
                    onTap: onPickImage, // ใช้ onPickImage
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accent.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: AppTheme.accent,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Add More Photos',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Show image
              return Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: _buildImagePreview(imageFiles[index]), // ไม่มีขีดล่าง
                  ),
                  // Delete button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => onRemoveImage(index), // ใช้ onRemoveImage
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.danger,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Thumbnail list
        if (imageFiles.isNotEmpty) ...[ // ไม่มีขีดล่าง
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageFiles.length, // ไม่มีขีดล่าง
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: AppTheme.accentLight,
                      alignment: Alignment.center,
                      child: _buildImagePreview(imageFiles[index]), // ไม่มีขีดล่าง
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}