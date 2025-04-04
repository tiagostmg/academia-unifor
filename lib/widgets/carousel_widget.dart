import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';

const List<String> imagePaths = [
  'assets/001.jpg',
  'assets/002.jpg',
  'assets/003.jpg',
  'assets/004.jpg',
  'assets/005.jpg',
  'assets/006.jpg',
];

class CarouselWidget extends StatefulWidget {
  final List<String> images;
  final double height;
  final Color indicatorColor;

  const CarouselWidget({
    super.key,
    this.images = imagePaths,
    this.height = 160,
    this.indicatorColor = Colors.blue,
  });

  @override
  CarouselWidgetState createState() => CarouselWidgetState();
}

class CarouselWidgetState extends State<CarouselWidget> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Swiper(
            loop: true,
            viewportFraction: 0.8,
            scale: 0.9,
            autoplay: true,
            onIndexChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder:
                (context, index) =>
                    CarouselSlide(imagePath: widget.images[index]),
          ),
        ),
        const SizedBox(height: 10),
        _buildIndicators(),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.images.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex ? widget.indicatorColor : Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class CarouselSlide extends StatelessWidget {
  final String imagePath;

  const CarouselSlide({required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 5)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () {
              // Ação ao clicar na imagem, se necessário
            },
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
