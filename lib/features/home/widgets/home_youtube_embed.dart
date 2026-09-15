import 'package:autobus/barrel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Home banner — Figma `3404:6116` (361×179, radius 20) as a YouTube embed.
class HomeYoutubeEmbed extends StatefulWidget {
  final double scale;

  const HomeYoutubeEmbed({super.key, required this.scale});

  static String? videoIdFrom(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (RegExp(r'^[\w-]{11}$').hasMatch(value)) return value;

    final uri = Uri.tryParse(value);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      return id.length == 11 ? id : null;
    }

    final queryId = uri.queryParameters['v'];
    if (queryId != null && queryId.length == 11) return queryId;

    for (final marker in ['embed', 'shorts', 'live']) {
      final index = uri.pathSegments.indexOf(marker);
      if (index >= 0 && index + 1 < uri.pathSegments.length) {
        final id = uri.pathSegments[index + 1];
        if (id.length == 11) return id;
      }
    }
    return null;
  }

  @override
  State<HomeYoutubeEmbed> createState() => _HomeYoutubeEmbedState();
}

class _HomeYoutubeEmbedState extends State<HomeYoutubeEmbed> {
  WebViewController? _controller;
  String? _videoId;
  var _loading = true;

  static bool get _canEmbed {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return !kIsWeb;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _videoId = HomeYoutubeEmbed.videoIdFrom(AppConfig.homeYoutubeUrl);
    if (_videoId != null && _canEmbed) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            onWebResourceError: (_) {
              if (mounted) setState(() => _loading = false);
            },
          ),
        )
        ..loadRequest(
          Uri.parse(
            'https://www.youtube-nocookie.com/embed/$_videoId'
            '?playsinline=1&rel=0&modestbranding=1',
          ),
        );
    } else {
      _loading = false;
    }
  }

  Future<void> _openExternal() async {
    final raw = AppConfig.homeYoutubeUrl.trim();
    final uri = Uri.tryParse(
      raw.startsWith('http')
          ? raw
          : 'https://www.youtube.com/watch?v=$_videoId',
    );
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final height = 179 * scale;
    final radius = BorderRadius.circular(20 * scale);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ColoredBox(
          color: const Color(0xFFF8FAFC),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_controller != null)
                WebViewWidget(
                  controller: _controller!,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      EagerGestureRecognizer.new,
                    ),
                  },
                )
              else
                _YoutubePoster(videoId: _videoId, onPlay: _openExternal),
              if (_loading)
                const ColoredBox(
                  color: Color(0xFF0F0F0F),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YoutubePoster extends StatelessWidget {
  final String? videoId;
  final VoidCallback onPlay;

  const _YoutubePoster({required this.videoId, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F0F0F),
      child: InkWell(
        onTap: videoId == null ? null : onPlay,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (videoId != null)
              Image.network(
                'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            Center(
              child: Container(
                width: 56,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
