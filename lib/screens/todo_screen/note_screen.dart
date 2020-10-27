import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gottask/utils/text_editor_utils.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';
import 'package:get/get.dart';

enum NoteMode { ADD, EDIT }

class NoteScreen extends StatefulWidget {
  final List<dynamic> note;
  final Color themeColor;
  final Function(String newNode) onNoteSaved;
  final NoteMode noteMode;
  NoteScreen(
      {Key key, this.themeColor, this.onNoteSaved, this.note, this.noteMode})
      : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  FocusNode _textEditorNode = FocusNode();
  ZefyrController _textEditorController;
  ZefyrMode zefyrMode = ZefyrMode.select;

  bool isEdit = false;

  ZefyrController _setTextEditorController() {
    if (widget.note.length != 0) {
      NotusDocument document = NotusDocument.fromJson(widget.note);
      ZefyrController _result = ZefyrController(document);
      return _result;
    } else {
      Delta delta = Delta()
        ..insert("\n")
        ..toJson();
      NotusDocument document = NotusDocument.fromDelta(delta);
      ZefyrController _result = ZefyrController(document);
      return _result;
    }
  }

  @override
  void initState() {
    super.initState();
    _textEditorController = _setTextEditorController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail note".tr),
        backgroundColor: widget.themeColor,
        actions: [
          if (widget.noteMode == NoteMode.EDIT)
            IconButton(
                icon: Icon(isEdit == false ? Icons.edit : Icons.cancel),
                onPressed: () {
                  setState(() {
                    if (zefyrMode == ZefyrMode.select) {
                      isEdit = true;
                      zefyrMode = ZefyrMode.edit;
                    } else {
                      isEdit = false;
                      zefyrMode = ZefyrMode.select;
                    }
                  });
                }),
          if (isEdit == true)
            IconButton(
              icon: Icon(Icons.save_sharp),
              onPressed: () {
                var data = jsonEncode(_textEditorController.document
                    .toDelta()
                    .toJson()
                    .map((e) => e.toJson())
                    .toList());

                widget.onNoteSaved(data);
              },
            ),
        ],
      ),
      body: ZefyrScaffold(
        child: ZefyrEditor(
          controller: _textEditorController,
          focusNode: _textEditorNode,
          mode: zefyrMode,
          toolbarDelegate: NotemonToolBarDelegate(),
        ),
      ),
    );
  }
}
