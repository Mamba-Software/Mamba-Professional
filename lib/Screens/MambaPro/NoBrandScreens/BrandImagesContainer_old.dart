import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';

class BrandImagesContainer extends StatefulWidget {
  double? height;
  Brand brand;
  List<ImageObject> images = [];
  BrandImagesContainer({super.key, this.height, required this.brand, required this.images});

  @override
  _BrandImagesContainerState createState() => _BrandImagesContainerState();
}

class _BrandImagesContainerState extends State<BrandImagesContainer> {

  int currentPicture = 0;

  @override
  Widget build(BuildContext context) {
    return widget.images.isNotEmpty ? Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: widget.height ?? MediaQuery.of(context).size.height * 0.35,
          child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              onPageChanged: (int page) {
                setState(() {
                  currentPicture = page;
                });
              },
              itemBuilder: (context, int index) {
                ImageObject image = widget.images[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: widget.height ?? MediaQuery.of(context).size.height * 0.35,
                  child: RectangularImage(
                    image: image.url,
                    height: widget.height ?? MediaQuery.of(context).size.height * 0.35,
                    width: MediaQuery.of(context).size.width,
                  ),
                );
              }
          ),
        ),
        widget.images.length > 1 ? SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.images.asMap().entries.map((entry) {
              return Container(
                width: MediaQuery.of(context).size.width*0.015,
                height: MediaQuery.of(context).size.width*0.015,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(currentPicture == entry.key ? 0.9 : 0.4)),
              );
            }).toList(),
          ),
        ) : Container(),
      ],
    ) : SizedBox(
      width: MediaQuery.of(context).size.width,
      height: widget.height ?? MediaQuery.of(context).size.height * 0.35,
      child: RectangularImage(
        image: widget.brand.logoUrl!,
        height: widget.height ?? MediaQuery.of(context).size.height * 0.35,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}
