import 'package:flutter/material.dart';

import '../constant.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  final String? customImagePath;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? loadingText;

  const LoadingWidget({
    Key? key,
    this.size = 120,
    this.customImagePath,
    this.backgroundColor,
    this.iconColor,
    this.loadingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _buildLoadingImage(),
        ),
        if (loadingText != null) ...[
          const SizedBox(height: 16),
          Text(
            loadingText!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingImage() {
    if (customImagePath != null) {
      return Image.asset(
        customImagePath!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackLoading();
        },
      );
    }

    // Default loading image
    return Image.asset(
      'assets/images/loginlogo.png', // Your default loading image
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackLoading();
      },
    );
  }

  Widget _buildFallbackLoading() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryBlue.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.autorenew,
          size: size * 0.5,
          color: iconColor ?? AppColors.primaryBlue,
        ),
      ),
    );
  }
}

// You can also create specific loading variations:

class SmallLoadingWidget extends StatelessWidget {
  const SmallLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(size: 40);
  }
}

class MediumLoadingWidget extends StatelessWidget {
  const MediumLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(size: 80);
  }
}

class LargeLoadingWidget extends StatelessWidget {
  const LargeLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(size: 120);
  }
}

class LoadingWithTextWidget extends StatelessWidget {
  final String text;
  final double size;

  const LoadingWithTextWidget({
    Key? key,
    required this.text,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      size: size,
      loadingText: text,
    );
  }
}

// For full-screen loading
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final bool withScaffold;

  const FullScreenLoading({
    Key? key,
    this.message,
    this.withScaffold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingWidget(size: 100),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );

    return withScaffold
        ? Scaffold(body: loadingWidget)
        : loadingWidget;
  }
}