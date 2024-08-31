import '../enum/control_value.dart';

class BinDecoder {
  static String processBinValues(List<int> binValues) {
    List<int> resultsBin = _prepareDataSet(binValues);
    String result = _decodeBinValuesToASCII(resultsBin);
    if (result.isEmpty) {
      result = 'ERROR: Message not decoded';
    }
    return result;
  }

  static List<int> _prepareDataSet(List<int> binValues) {
    List<List<int>> binMatrix = _splitByControlNumber(binValues);
    binMatrix = _validatePadding(binMatrix);
    binMatrix = _validateLength(binMatrix);
    return _validateIntegrity(binMatrix);
  }

  static List<List<int>> _splitByControlNumber(List<int> list) {
    List<List<int>> result = [];
    List<int> currentSublist = [];
    for (int number in list) {
      if (number == BinaryControl.controlValue.value) {
        result.add(List.from(currentSublist));
        currentSublist.clear();
      } else {
        currentSublist.add(number);
      }
    }
    if (currentSublist.isNotEmpty) {
      result.add(currentSublist);
    }
    return result;
  }

  static List<List<int>> _validatePadding(List<List<int>> originalList) {
    List<List<int>> consistentList = [];
    for (List<int> sublist in originalList) {
      if (sublist.length % 8 == 0) {
        consistentList.add(sublist);
      }
    }
    return consistentList;
  }

  static List<List<int>> _validateLength(List<List<int>> originalList) {
    List<List<int>> consistentList = [];
    int maxLength = 0;
    for (List<int> sublist in originalList) {
      if (sublist.length > maxLength) {
        maxLength = sublist.length;
        consistentList.clear();
      }
      if (sublist.length == maxLength) {
        consistentList.add(sublist);
      }
    }
    return consistentList;
  }

  static List<int> _validateIntegrity(List<List<int>> binMatrix) {
    int rows = binMatrix.length;
    int columns = binMatrix.isEmpty ? 0 : binMatrix[0].length;
    List<int> resultsBin = [];
    for (int column = 0; column < columns; column++) {
      int count1 = 0;
      int count0 = 0;

      for (int row = 0; row < rows; row++) {
        if (binMatrix[row][column] == BinaryControl.binary1.value) {
          count1++;
        } else if (binMatrix[row][column] == BinaryControl.binary0.value) {
          count0++;
        }
      }
      if (count1 >= count0) {
        resultsBin.add(BinaryControl.binary1.value);
      } else if (count1 < count0) {
        resultsBin.add(BinaryControl.binary0.value);
      }
    }
    return resultsBin;
  }

  static String _decodeBinValuesToASCII(List<int> binValues) {
    String result = '';
    for (int i = 0; i < binValues.length; i += 8) {
      int byte = 0;
      for (int j = 0; j < 8; j++) {
        byte += binValues[i + j] << (7 - j);
      }
      result += String.fromCharCode(byte);
    }
    return result;
  }
}
