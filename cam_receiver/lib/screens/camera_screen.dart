import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../utils/img_decoder.dart';
import '../widgets/config_field_widget.dart';
import '../widgets/decoding_dialog_widget.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  double _zoomLevel = 2.0;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late ImgDecoder _imgDecoder;
  bool _isImgStreaming = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize().then((_) async {
      _controller.setZoomLevel(_zoomLevel);
      await _controller.setFocusMode(FocusMode.locked);
    });
    _imgDecoder = ImgDecoder(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Decoder')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Parameters',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Slider(
            value: _zoomLevel,
            min: 2.0,
            max: 10,
            onChanged: (value) {
              setState(() {
                _zoomLevel = value;
                _controller.setZoomLevel(value);
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const Divider(thickness: 1, color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Wrap(
                      spacing: 15.0,
                      runSpacing: 15.0,
                      children: [
                        FieldConfigWidget(
                          label: 'Milliseconds Showing Modified Img',
                          onChanged: (value) {
                            _imgDecoder.timeDisplayingModImgMs =
                                int.tryParse(value) ??
                                    _imgDecoder.timeDisplayingModImgMs;
                          },
                          hintText: _imgDecoder.timeDisplayingModImgMs.toString(),
                        ),
                        FieldConfigWidget(
                          label: 'Frequency in milliseconds',
                          onChanged: (value) {
                            _imgDecoder.frequencyMs =
                                int.tryParse(value) ?? _imgDecoder.frequencyMs;
                          },
                          hintText: _imgDecoder.frequencyMs.toString(),
                        ),
                        FieldConfigWidget(
                          label: 'Percentage Difference Threshold',
                          onChanged: (value) {
                            _imgDecoder.porcentajeDefine = int.tryParse(value) ??
                                _imgDecoder.porcentajeDefine;
                          },
                          hintText: _imgDecoder.porcentajeDefine.toString(),
                        ),
                        FieldConfigWidget(
                          label: 'Number of Cycles',
                          onChanged: (value) {
                            _imgDecoder.nCycles =
                                int.tryParse(value) ?? _imgDecoder.nCycles;
                          },
                          hintText: _imgDecoder.nCycles.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_controller.value.isInitialized) {
            return;
          }
        if (!_isImgStreaming) {
            _imgDecoder.startImageStream();
            _isImgStreaming = true;
          }
          _showDecodingDialog(context);
        },
        child: const Icon(Icons.camera_alt_rounded),
      ),
    );
  }

  void _showDecodingDialog(BuildContext context) {
    showDialog(
  context: context,
  barrierDismissible: false,
  builder: (BuildContext context) {
    return PopScope(
      canPop: false,
      child:  DecodingDialog(imgDecoder: _imgDecoder));
      },
    );
  }
}
