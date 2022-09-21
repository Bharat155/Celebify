import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

TextStyle latoBold = const TextStyle(
    fontSize: 24,
    fontFamily: 'Lato-Bold',
    fontWeight: FontWeight.w700
);

TextStyle latoRegular = const TextStyle(
    fontSize: 20,
    fontFamily: 'Lato-Regular',
    fontWeight: FontWeight.w500
);

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

const SpinKitPouringHourGlass loader1 =  SpinKitPouringHourGlass(
  color: Colors.white,
  size: 50.0,
);

const Color shadeColor = Color(0xff2b343b);
