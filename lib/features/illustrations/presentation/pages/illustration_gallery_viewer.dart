import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../pages/illustrations_gallery_page.dart' show BibleIllustration;

/// Swipeable gallery viewer for Bible illustrations.
/// Opens from the gallery list and lets the user swipe between images.
class IllustrationGalleryViewer extends StatefulWidget {
  final List<BibleIllustration> illustrations;
  final int initialIndex;

  const IllustrationGalleryViewer({
    super.key,
    required this.illustrations,
    this.initialIndex = 0,
  });

  @override
  State<IllustrationGalleryViewer> createState() =>
      _IllustrationGalleryViewerState();
}

class _IllustrationGalleryViewerState extends State<IllustrationGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final illustration = widget.illustrations[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        title: Text(
          '${illustration.title} (${_currentIndex + 1}/${widget.illustrations.length})',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          if (_currentIndex > 0)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          if (_currentIndex < widget.illustrations.length - 1)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.illustrations.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final illus = widget.illustrations[index];
          return _IllustrationPage(illustration: illus, index: index);
        },
      ),
    );
  }
}

class _IllustrationPage extends StatelessWidget {
  final BibleIllustration illustration;
  final int index;

  const _IllustrationPage({
    required this.illustration,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: _IllustrationImage(imagePath: illustration.imagePath),
            ),
          ),
        ),
        // Info bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                illustration.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                illustration.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${illustration.book} ${illustration.chapter}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Artwork by Gustave Doré',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IllustrationImage extends StatefulWidget {
  final String imagePath;
  const _IllustrationImage({required this.imagePath});

  @override
  State<_IllustrationImage> createState() => _IllustrationImageState();
}

class _IllustrationImageState extends State<_IllustrationImage> {
  ImageProvider? _image;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_IllustrationImage old) {
    super.didUpdateWidget(old);
    if (old.imagePath != widget.imagePath) {
      _image = null;
      _error = null;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final data = await rootBundle.load(widget.imagePath);
      if (!mounted) return;
      setState(() {
        _image = MemoryImage(data.buffer.asUint8List());
        _error = null;
      });
    } catch (e) {
      debugPrint('Illustration FAILED: ${widget.imagePath}: $e');
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return Hero(
        tag: widget.imagePath,
        child: Image(image: _image!, fit: BoxFit.contain),
      );
    }
    return Center(
      child: _error != null
          ? const Icon(Icons.broken_image, color: Colors.white54, size: 64)
          : const CircularProgressIndicator(color: Colors.white54),
    );
  }
}
