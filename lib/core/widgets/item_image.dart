import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:anigoods/core/theme/app_theme.dart'; 



// ─── Item Image ───────────────────────────────────────────
class ItemImage extends StatelessWidget {
  final List<String> imageUrls;
  final double size;
  final double radius;

  const ItemImage({
    super.key,
    required this.imageUrls,
    this.size = 72,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: AppTheme.accentLight,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImageFallback(),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.accent,
                        ),
                      ),
              )
            : const _ImageFallback(),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('🎁', style: TextStyle(fontSize: 28)));
}



// ─── Image Carousel ───────────────────────────────────────
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double borderRadius;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 280,
    this.borderRadius = 0,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // เรียกใช้ widget.imageUrls
  void _openFullScreen(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          imageUrls: widget.imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. ถ้าไม่มีรูปเลย แสดง fallback
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppTheme.accentLight,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Center(child: Text('🎁', style: TextStyle(fontSize: 64))),
      );
    }

    // 2. ถ้ามีรูปเดียว แสดงรูปแบบธรรมดา ไม่มี carousel
    if (widget.imageUrls.length == 1) {
      return GestureDetector(
        onTap: () => _openFullScreen(context, 0), // เปิดหน้าเต็มจอ
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            height: widget.height,
            color: AppTheme.accentLight,
            alignment: Alignment.center,
            child: Image.network(
              widget.imageUrls[0],
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child: Text('🎁', style: TextStyle(fontSize: 64)),
              ),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accent,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    // 3. ถ้ามีหลายรูป แสดง carousel พร้อม indicator
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(), // เลื่อนหนึบขึ้น
              pageSnapping: true,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openFullScreen(context, index), // กดซูมรูป
                  child: Container(
                    color: AppTheme.accentLight,
                    alignment: Alignment.center,
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('🎁', style: TextStyle(fontSize: 64)),
                      ),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accent,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Dot Indicator ด้านล่าง
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.imageUrls.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// ─── Full Screen Image Viewer ─────────────────────────────
class FullScreenImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        physics: const BouncingScrollPhysics(), 
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            // ซูมรูปได้
            panEnabled: true,
            minScale: 1.0, 
            maxScale: 4.0, 
            child: Center(
              child: Image.network(imageUrls[index], fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}