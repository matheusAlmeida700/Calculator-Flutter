import 'package:calculator/color.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String rawInput = "";
  String output = "";
  bool hideInput = false;
  double outputSize = 34;
  Color themeColor = const Color.fromARGB(255, 31, 31, 31);

  String formatNumber(num number) {
    final formatter =
        NumberFormat.decimalPattern('pt_BR')
          ..minimumFractionDigits = 0
          ..maximumFractionDigits = 8;
    return formatter.format(number);
  }

  String formatExpression(String expr) {
    return expr.replaceAllMapped(RegExp(r'\d+(?:\.\d*)?'), (match) {
      String token = match.group(0)!;
      if (token.endsWith('.')) {
        String numPart = token.substring(0, token.length - 1);
        double? number = double.tryParse(numPart);
        return number != null ? '${formatNumber(number)},' : token;
      } else {
        double? number = double.tryParse(token);
        return number != null ? formatNumber(number) : token;
      }
    });
  }

  String get formattedInput => formatExpression(rawInput);

  void onButtonClick(String value) {
    setState(() {
      switch (value) {
        case "AC":
        case "CE":
          rawInput = "";
          output = "";
          break;
        case "C":
          if (rawInput.isNotEmpty) {
            final lastOp = rawInput.lastIndexOf(RegExp(r'[-+x÷]'));
            rawInput = lastOp != -1 ? rawInput.substring(0, lastOp + 1) : "";
          }
          break;
        case "⌫":
          if (rawInput.isNotEmpty) {
            rawInput = rawInput.substring(0, rawInput.length - 1);
          }
          break;
        case "√x":
          if (rawInput.isNotEmpty) {
            rawInput = "sqrt($rawInput)";
            _calculateResult();
          }
          break;
        case "x²":
          if (rawInput.isNotEmpty) {
            rawInput = "($rawInput)^2";
            _calculateResult();
          }
          break;
        case "1/x":
          if (rawInput.isNotEmpty) {
            rawInput = "1/($rawInput)";
            _calculateResult();
          }
          break;
        case "%":
          if (rawInput.isNotEmpty) {
            rawInput = "($rawInput)/100";
            _calculateResult();
          }
          break;
        case "+/-":
          if (rawInput.isNotEmpty) {
            rawInput =
                rawInput.startsWith("-") ? rawInput.substring(1) : "-$rawInput";
          }
          break;
        case "=":
          _calculateResult();
          break;
        case ",":
          rawInput += ".";
          break;
        default:
          if (hideInput) {
            if (!(value == "+" ||
                value == "-" ||
                value == "x" ||
                value == "÷")) {
              rawInput = "";
            }
            hideInput = false;
          }
          rawInput += value;
          outputSize = 34;
      }
    });
  }

  void _calculateResult() {
    if (rawInput.isEmpty) return;
    try {
      String parsed = rawInput
          .replaceAll("x", "*")
          .replaceAll("÷", "/")
          .replaceAll("√x", "sqrt")
          .replaceAll("x²", "^2")
          .replaceAll("1/x", "1/")
          .replaceAll("%", "/100");
      final expression = Parser().parse(parsed);
      final evaluation = expression.evaluate(
        EvaluationType.REAL,
        ContextModel(),
      );
      output = formatNumber(evaluation);
      rawInput = evaluation.toString();
      hideInput = true;
      outputSize = 52;
    } catch (_) {
      output = "Error";
    }
  }

  void _changeTheme(Color color) {
    setState(() {
      themeColor = color;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o estilo do tema atual com base no valor da cor
    final currentStyle =
        themeStyles[themeColor.value] ??
        {"operator": Colors.orange, "button": Colors.grey};

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed:
              () => showModalBottomSheet(
                context: context,
                builder: (_) => _buildThemeSelector(),
              ),
        ),
      ),
      body: Column(children: [_buildDisplay(), _buildButtons(currentStyle)]),
    );
  }

  Widget _buildDisplay() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomRight,
              child: Text(
                hideInput ? "" : formattedInput,
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomRight,
              child: Text(
                output,
                style: TextStyle(
                  fontSize: outputSize,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(Map<String, Color> currentStyle) {
    final buttons = [
      ["%", "CE", "C", "⌫"],
      ["1/x", "x²", "√x", "÷"],
      ["7", "8", "9", "x"],
      ["4", "5", "6", "-"],
      ["1", "2", "3", "+"],
      ["+/-", "0", ",", "="],
    ];

    return Column(
      children:
          buttons
              .map(
                (row) => Row(
                  children:
                      row
                          .map((text) => _buildButton(text, currentStyle))
                          .toList(),
                ),
              )
              .toList(),
    );
  }

  Widget _buildButton(String text, Map<String, Color> currentStyle) {
    final isOperator = [
      "÷",
      "x",
      "-",
      "+",
      "^",
      "√x",
      "%",
      "CE",
      "C",
      "⌫",
      "1/x",
      "x²",
      "=",
    ].contains(text);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.all(22),
            backgroundColor:
                isOperator ? currentStyle["operator"] : currentStyle["button"],
          ),
          onPressed: () => onButtonClick(text),
          child:
              text == "⌫"
                  ? const Icon(Icons.backspace, color: Colors.white, size: 30)
                  : Text(
                    text,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 4,
        children:
            availableThemes.map((color) => _buildThemeButton(color)).toList(),
      ),
    );
  }

  Widget _buildThemeButton(Color color) {
    return GestureDetector(
      onTap: () => _changeTheme(color),
      child: CircleAvatar(backgroundColor: color, radius: 20),
    );
  }
}
