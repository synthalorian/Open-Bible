import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Share verse page - create beautiful verse images for sharing
class ShareVersePage extends StatefulWidget {
  final String verseId;
  final String text;
  final String reference;

  const ShareVersePage({
    super.key,
    required this.verseId,
    required this.text,
    required this.reference,
  });

  @override
  State<ShareVersePage> createState() => _ShareVersePageState();
}

class _ShareVersePageState extends State<ShareVersePage> {
  final GlobalKey _repaintKey = GlobalKey();
  int _selectedStyle = 0;
  int _selectedBackground = 0;

  final List<VerseStyle> _styles = [
    VerseStyle(
      name: 'Classic',
      textStyle: const TextStyle(
        fontFamily: 'CrimsonText',
        fontSize: 24,
        height: 1.6,
        color: Colors.white,
      ),
      referenceStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    ),
    VerseStyle(
      name: 'Modern',
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 22,
        height: 1.7,
        fontWeight: FontWeight.w300,
        color: Colors.white,
      ),
      referenceStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    ),
    VerseStyle(
      name: 'Bold',
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 26,
        height: 1.5,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      referenceStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  ];

  final List<Gradient> _backgrounds = [
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFfa709a), Color(0xFFfee140)],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
    ),
    const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF232526), Color(0xFF414345)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Verse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareImage(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _repaintKey,
                child: _buildVerseCard(),
              ),
            ),
          ),
          
          // Style selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _styles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_styles[index].name),
                    selected: _selectedStyle == index,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedStyle = index);
                    },
                  ),
                );
              },
            ),
          ),
          
          // Background selector
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _backgrounds.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedBackground = index),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: _backgrounds[index],
                      borderRadius: BorderRadius.circular(12),
                      border: _selectedBackground == index
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyText(),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Text'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareImage(),
                    icon: const Icon(Icons.share),
                    label: const Text('Share Image'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard() {
    final style = _styles[_selectedStyle];
    
    return Container(
      width: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: _backgrounds[_selectedBackground],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quote mark
          Text(
            '"',
            style: TextStyle(
              fontSize: 64,
              fontFamily: 'CrimsonText',
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          
          // Verse text
          Text(
            widget.text,
            style: style.textStyle,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Reference
          Text(
            widget.reference,
            style: style.referenceStyle,
          ),
          
          const SizedBox(height: 24),
          
          // App branding
          Text(
            'Open Bible',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyText() async {
    final verseText = '"${widget.text}" - ${widget.reference}';
    await Clipboard.setData(ClipboardData(text: verseText));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verse copied to clipboard!')),
      );
    }
  }

  Future<void> _shareImage() async {
    // In real app: capture the RepaintBoundary and share
    // final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    // final image = await boundary.toImage(pixelRatio: 3.0);
    // final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // ... share via share_plus
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share feature coming soon!')),
      );
    }
  }
}

class VerseStyle {
  final String name;
  final TextStyle textStyle;
  final TextStyle referenceStyle;

  const VerseStyle({
    required this.name,
    required this.textStyle,
    required this.referenceStyle,
  });
}
