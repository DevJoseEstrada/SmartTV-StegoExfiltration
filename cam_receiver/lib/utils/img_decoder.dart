import 'dart:async';

import 'package:camera/camera.dart';

import '../enum/control_value.dart';

class ImgDecoder {
  List<int> binValues;
  int nCycles;
  int frequencyMs;
  int timeDisplayingModImgMs;
  int porcentajeDefine;
  int timeControlWaitValue;
  int msToCalculateMedian;
  bool isDecoding;
  bool isCycleSync;
  bool isMedianCalculated;
  bool isImgSync;
  bool isBadParameters;
  final CameraController _controller;
  final StreamController<CameraImage> _imageStreamController =
      StreamController<CameraImage>.broadcast();

  ImgDecoder({
    List<int>? binValues,
    this.nCycles = 3,
    this.frequencyMs = 1000,
    this.timeDisplayingModImgMs = 150,
    this.porcentajeDefine = 10,
    required CameraController controller,
    this.isDecoding = false,
    this.isCycleSync = false,
    this.isMedianCalculated = false,
    this.isImgSync = false,
    this.isBadParameters = false,
  })  : binValues = binValues ?? [],
        _controller = controller,
        msToCalculateMedian = frequencyMs * 3,
        timeControlWaitValue = frequencyMs * 2;

  void startImageStream() {
    _controller.startImageStream(_imageStreamController.add);
  }

  void _stopImageStream() {
    if (_controller.value.isStreamingImages) {
      _controller.stopImageStream();
    }
  }

  Future<CameraImage> _getLatestImage() async {
    return await _imageStreamController.stream.first;
  }

  void dispose() {
    _stopImageStream();
    _imageStreamController.close();
    _controller.dispose();
  }

  void resetDecode() {
    binValues.clear();
    isCycleSync =
        isMedianCalculated = isImgSync = isBadParameters = isDecoding = false;
  }

  int _getTotalImageColor(CameraImage image) {
    int sumPixelsColor = 0;
    final bytes = image.planes[0].bytes;
    for (int pixelColor in bytes) {
      sumPixelsColor += pixelColor;
    }
    return sumPixelsColor;
  }

  Future<int> _getMedianExpectedColor(
      Duration millisecondsToCalculateMedian) async {
    List<int> values = [];
    Stopwatch stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < millisecondsToCalculateMedian) {
      CameraImage image = await _getLatestImage();
      values.add(_getTotalImageColor(image));
    }

    stopwatch.stop();
    return _calculateMedian(values);
  }

  int _calculateMedian(List<int> list) {
    list.sort();
    int middle = list.length ~/ 2;
    return list.length.isOdd
        ? list[middle]
        : (list[middle - 1] + list[middle]) ~/ 2;
  }

  Future<int> _decodeInformation(int avgExpected) async {
    bool detectedNeutralValue = false;
    Stopwatch stopwatch = Stopwatch()..start();

    while (true) {
      double percentageDiff =
          _calculatePercentageDiff(await _getLatestImage(), avgExpected);
      if (percentageDiff.abs() > porcentajeDefine) {
        return percentageDiff > 0
            ? BinaryControl.binary0.value
            : BinaryControl.binary1.value;
      } else if (stopwatch.elapsedMilliseconds > timeControlWaitValue) {
        return BinaryControl.controlValue.value;
      } else if (!detectedNeutralValue) {
        detectedNeutralValue = true;
      } else {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  double _calculatePercentageDiff(CameraImage image, int avgExpected) {
    int diff = _getTotalImageColor(image) - avgExpected;
    return (diff / avgExpected) * 100;
  }

  Future<bool> _synchronizeWithSender(int avgExpected) async {
    bool detectedNeutralValue = false;
    Stopwatch stopwatch = Stopwatch()..start();

    while (true) {
      double percentageDiff =
          _calculatePercentageDiff(await _getLatestImage(), avgExpected);
      if (percentageDiff.abs() > porcentajeDefine) {
        return true;
      } else if (stopwatch.elapsedMilliseconds > timeControlWaitValue * 2) {
        return false;
      } else if (!detectedNeutralValue) {
        detectedNeutralValue = true;
      } else {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  Future<List<int>> startDecodingImages() async {
    int nCyclesDoneCount = 0;
    int timeToWaitBetweenCycles = frequencyMs ~/ 2;
    int medianColorExpected = await _getMedianExpectedColor(
        Duration(milliseconds: msToCalculateMedian));
    isMedianCalculated = true;
    isImgSync = await _synchronizeWithSender(medianColorExpected);
    if (isImgSync) {
      isDecoding = true;
      await _initDecoding(
          nCyclesDoneCount, medianColorExpected, timeToWaitBetweenCycles);
      isDecoding = false;
    } else {
      isBadParameters = true;
    }
    return binValues;
  }

  Future<void> _initDecoding(int nCyclesDoneCount, int medianColorExpected,
      int timeToWaitBetweenCycles) async {
    while (nCyclesDoneCount < nCycles && isDecoding) {
      int bitValue = await _decodeInformation(medianColorExpected);
      if (bitValue == BinaryControl.controlValue.value) {
        if (!isCycleSync) {
          isCycleSync = true;
          binValues.clear();
        } else {
          nCyclesDoneCount++;
        }
      }
      if (nCyclesDoneCount < nCycles) {
        binValues.add(bitValue);
        if (isDecoding) {
          await Future.delayed(Duration(milliseconds: timeToWaitBetweenCycles));
        }
      }
    }
  }
}
