import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/bin_decoder.dart';
import '../utils/img_decoder.dart';

class DecodingDialog extends StatefulWidget {
  final ImgDecoder imgDecoder;

  const DecodingDialog({super.key, required this.imgDecoder});

  @override
  DecodingDialogState createState() => DecodingDialogState();
}

class DecodingDialogState extends State<DecodingDialog> {
  final ScrollController _binScrollController = ScrollController();

  bool _isCycleSync = false;
  bool isProcessing = false;
  bool _isMedianCalculated = false;
  bool _isImgSync = false;
  bool _isBadParameters = false;
  List<int> _binValues = [];
  String _msgDecoded = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      Duration(milliseconds: widget.imgDecoder.frequencyMs),
      (timer) {
        setState(() {
          _updateDecodingState();
          if (!isProcessing) {
            _startDecodingImg();
            isProcessing = true;
          }
          if (_isBadParameters || _msgDecoded.isNotEmpty) {
            isProcessing = false;
            _timer?.cancel();
          }
          _binScrollController.jumpTo(_binScrollController.position.maxScrollExtent);
        });
      },
    );
  }

  void _updateDecodingState() {
    _isCycleSync = widget.imgDecoder.isCycleSync;
    _isMedianCalculated = widget.imgDecoder.isMedianCalculated;
    _isImgSync = widget.imgDecoder.isImgSync;
    _binValues = widget.imgDecoder.binValues;
    _isBadParameters = widget.imgDecoder.isBadParameters;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decoding process'),
      content: _buildDialogContent(),
      actions: <Widget>[
        TextButton(
          onPressed: _onDialogActionPressed,
          child: Text(_msgDecoded.isNotEmpty || _isBadParameters ? 'Ok' : 'Cancel'),
        ),
      ],
    );
  }

  Widget _buildDialogContent() {
    if (_isBadParameters) {
      return const Text('Unable to Sync, bad parameters detected');
    } else if (_msgDecoded.isNotEmpty) {
      return _buildDecodedMessageContent();
    } else {
      return _buildDecodingProgressContent();
    }
  }

  Widget _buildDecodedMessageContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Decoded message',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: _msgDecoded),
        ),
      ],
    );
  }

  Widget _buildDecodingProgressContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children:[
        if (_isMedianCalculated)
          Text('Median calculated: $_isMedianCalculated'),
        if (_isImgSync)
          Text('Synced with the image: $_isImgSync'),
        if (_isImgSync && _isCycleSync)
          Text('Synced with the cycle: $_isCycleSync'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 300,
            height: 100,
            child: TextField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Bin values',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: _binValues.isNotEmpty ? _binValues.join() : '',
              ),
              scrollController: _binScrollController,
              maxLines: 8,
            ),
          ),
        ),
      ],
    );
  }

  void _onDialogActionPressed() {
    widget.imgDecoder.resetDecode();
    Navigator.of(context).pop();
  }

  void _startDecodingImg() async {
    _binValues = await widget.imgDecoder.startDecodingImages();
    if (_binValues.isNotEmpty) {
      _msgDecoded = BinDecoder.processBinValues(_binValues);
    }
  }
}
