import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:moor/moor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewer extends StatefulWidget {
  final int imageLinkIndex;
  final List<Uint8List> imageLinkList;
  final Color color;

  const ImageViewer({this.imageLinkIndex, this.imageLinkList, this.color});

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  PageController pageController;
  @override
  void initState() {
    pageController = PageController(
      initialPage: widget.imageLinkIndex,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context)
            .copyWith(accentColor: widget.color.withOpacity(0.5)),
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              PhotoViewGallery.builder(
                scrollPhysics: AlwaysScrollableScrollPhysics(),
                pageController: pageController,
                itemCount: widget.imageLinkList.length,
                builder: (context, index) => PhotoViewGalleryPageOptions(
                  imageProvider: MemoryImage(widget.imageLinkList[index]),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                ),
              ),
              Align(
                alignment: FractionalOffset.bottomLeft,
                child: SafeArea(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                      ),
                      color: widget.color,
                    ),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          Ionicons.ios_arrow_back,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
