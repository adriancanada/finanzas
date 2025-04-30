import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerContainer extends StatefulWidget {
  /// El contenido principal de tu pantalla
  final Widget child;
  const BannerContainer({required this.child, super.key});

  @override
  State<BannerContainer> createState() => _BannerContainerState();
}

class _BannerContainerState extends State<BannerContainer> {
  static const _adUnitId = 'ca-app-pub-3940256099942544/6300978111';  
  late BannerAd _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_)   => setState(() => _loaded = true),
        onAdFailedToLoad: (_, __) => setState(() => _loaded = false),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _loaded
        ? SizedBox(
            width: _ad.size.width.toDouble(),
            height: _ad.size.height.toDouble(),
            child: AdWidget(ad: _ad),
          )
        : null,
    
    );
  }
}
