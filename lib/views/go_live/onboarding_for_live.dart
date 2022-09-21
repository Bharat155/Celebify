import 'package:celebify/utils/constants.dart';
import 'package:celebify/views/go_live/go_live.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {

  PageController controller = PageController();
  int pageIndex = 0;


  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView(
          onPageChanged: (index){
            // print(index);
          },
          controller: controller,
          children: [
            slidingPageView(title: "Camera", image: 'cam_check.png'),
            slidingPageView(title: "Microphone", image: 'mic_check.png',),
            const GoLiveScreen()
          ],
        ),
      ),
    );

  }

  Widget slidingPageView({required String title, required String image}){
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Colors.deepPurple,
              Colors.black54
            ]
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: latoBold.copyWith(
              color: Colors.white,
            ),
          ),
          Text(
            "You should enable the ${title.toLowerCase()}\nbefore you start...",
            textAlign: TextAlign.center,
            style: latoRegular.copyWith(
              color: Colors.white,),
          ),
          Center(child: Image.asset("assets/$image",scale: 2,),),
          Center(
            child: SmoothPageIndicator(
              controller: controller,
              count: 3,
              effect: const ExpandingDotsEffect(
                dotColor: Colors.white,
                dotHeight: 8,
                dotWidth: 8,
                strokeWidth: 3,
                expansionFactor: 4,
                activeDotColor: Color(0xfff12d2c),
              ),
            ),
          ),
          const SizedBox(height: 15,),
        ],
      ),
    );
  }

}


