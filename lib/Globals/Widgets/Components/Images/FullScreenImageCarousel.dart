import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';

class FullscreenSliderDemo extends StatefulWidget {

  int initialImage;
  List<ImageObject>? images;

  FullscreenSliderDemo({Key? key, required this.images, required this.initialImage}) : super(key: key);

  @override
  _FullscreenSliderDemoState createState() => _FullscreenSliderDemoState();
}

class _FullscreenSliderDemoState extends State<FullscreenSliderDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Builder(
            builder: (context) {
              final double height = MediaQuery.of(context).size.height;
              return CarouselSlider(
                options: CarouselOptions(
                  initialPage: widget.initialImage,
                  height: height,
                  autoPlay: false,
                  enableInfiniteScroll: false,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  // autoPlay: false,
                ),
                items: widget.images?.map((item) =>
                  Container(
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 333),
                          curve: Curves.fastOutSlowIn,
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(
                              item.url!,
                              fit: BoxFit.cover,
                              height: height,
                            ),
                          ),
                        ),
                      ]
                    ),
                  )
                ).toList(),
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: MaterialButton(
                padding: const EdgeInsets.all(15),
                elevation: 0,
                child: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryColor,
                  size: 25,
                ),
                color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                highlightElevation: 0,
                minWidth: double.minPositive,
                height: double.minPositive,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
    
    return Scaffold(
      appBar: null,
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return CarouselSlider(
            options: CarouselOptions(
              height: height,
              autoPlay: false,
              enableInfiniteScroll: false,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              // autoPlay: false,
            ),
            items: widget.images
              ?.map((item) => Container(
                child: Center(
                  child: Image.network(
                    item.url!,
                    fit: BoxFit.cover,
                    height: height,
                  )
                ),
              )
            )
            .toList(),
          );
        },
      ),
    );
  }
}
