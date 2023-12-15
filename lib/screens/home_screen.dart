import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_editor/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_editor/services/sticker_model.dart';
import 'package:uuid/uuid.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image;
  Set<StickerModel> stickers = {};
  String? selectedId;
  GlobalKey imgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          renderBody(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MainAppBar(
              onPickImage: onPickImage,
              onDeleteItem: onDeleteItem,
              onSaveImage: onSaveImage,
            ),
          ),
          if (image != null)
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Footer(
                  onEmotionTap: onEmotionTap,
                ))
        ],
      ),
    );
  }

  Widget renderBody() {
    if (image != null) {
      return RepaintBoundary(
        key: imgKey,
        child: Positioned.fill(
          child: InteractiveViewer(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(image!.path),
                  fit: BoxFit.cover,
                ),
                ...stickers.map(
                  (sticker) => Center(
                    child: EmoticonPicker(
                      key: ObjectKey(sticker.id),
                      onTransform: () {
                        onTransform(sticker.id);
                      },
                      imgPath: sticker.imgPath,
                      isSelected: selectedId == sticker.id,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          onPressed: onPickImage,
          child: const Text('이미지 선택하기'),
        ),
      );
    }
  }

  void onPickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      this.image = image;
    });
  }

  void onDeleteItem() async {
    setState(() {
      stickers = stickers.where((sticker) => sticker.id != selectedId).toSet();
    });
  }

  void onSaveImage() async {
    RenderRepaintBoundary boundary =
        imgKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    await ImageGallerySaver.saveImage(pngBytes, quality: 100);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('이미지가 저장되었습니다.'),
      ),
    );
  }

  void onEmotionTap(int index) {
    setState(() {
      stickers = {
        ...stickers,
        StickerModel(
          id: const Uuid().v4(),
          imgPath: 'assets/img/emoticon_$index.png',
        )
      };
    });
  }

  void onTransform(String id) {
    setState(() {
      selectedId = id;
    });
  }
}
