import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final double buttonWidth;
  final VoidCallback function;

  GradientButton({
    Key? key,
    required this.text,
    required this.function,
    this.buttonWidth = double.infinity, // Default width to match parent width
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      width: buttonWidth, // Set width based on buttonWidth property
      child: ElevatedButton(
        onPressed: function,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10.0),
        // ),
        // padding: const EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff54C0BC),
                Color(0xff1fc585),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: buttonWidth,
              minHeight: 50.0,
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class GradientButton extends StatefulWidget {
//   String? text;
//   double? buttonWidth;
//   final VoidCallback? function;

//   GradientButton({
//     Key? key,
//     this.text,
//     this.function,
//     this.buttonWidth,
//   }) : super(key: key);

//   @override
//   State<GradientButton> createState() => _GradientButtonState();
// }

// class _GradientButtonState extends State<GradientButton> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 50.0,
//       child: RaisedButton(
//         onPressed: widget.function,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//         padding: const EdgeInsets.all(0.0),
//         child: Ink(
//           decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [
//                   Color(0xff54C0BC),
//                   Color(0xff1fc585),
//                 ],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.circular(10.0)),
//           child: Container(
//             constraints: BoxConstraints(
//                 maxWidth: widget.buttonWidth as double, minHeight: 50.0),
//             alignment: Alignment.center,
//             child: Text(
//               widget.text as String,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }