import 'package:flutter/material.dart';
import 'package:zaitoonnote/Methods/z_button.dart';
import 'package:zaitoonnote/Screens/Onboarding/model.dart';
import 'package:zaitoonnote/Screens/Onboarding/signup.dart';
import '../../Methods/colors.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  int currentIndex = 0;

  List<Onboardings> onboardingItems = [
    Onboardings(
        title: "Notes",
        description: "Take note of your thoughts, and they’ll take note of you, the power of the pen is in the note-taking, keep your notes organized, and your life simplified",
        image: "assets/onboarding/notes.gif"),

    Onboardings(
        title: "Activity",
        description: "Your data, our responsibility, don't compromise on your data safety, trust us with your data storage needs, local data storage with backup and safe",
        image: "assets/onboarding/acitivity.gif"),

    Onboardings(
        title: "Backup",
        description: "Don't be a data disaster, back it up faster, Keep your vital notes and activities safe, take care of your data, it's the heart of your matter",
        image: "assets/onboarding/image2.gif"),

    Onboardings(
        title: "Authentication",
        description: "Your documents, our authentication, a perfect match, Keep your documents secure, authenticate them for the future",
        image: "assets/onboarding/image3.gif"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: PageView.builder(
                  onPageChanged: (value){
                    setState(() {
                      currentIndex = value;
                    });
                  },
                  itemCount: onboardingItems.length,

                  itemBuilder: (context,index){
                return OnboardingWidget(
                    imagePath: onboardingItems[currentIndex].image,
                    title: onboardingItems[currentIndex].title,
                    description: onboardingItems[currentIndex].description);
              }),
            ),

           SingleChildScrollView(
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.end,
               mainAxisAlignment: MainAxisAlignment.center,
               children: List.generate(
                 onboardingItems.length,
                     (index) => buildDot(index: index),
               ),
             ),
           ),

           Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     const SizedBox(width: 10),
                     currentIndex == 3?  const SizedBox() : currentIndex>0? Expanded(
                       child: ZButton(
                         label: "previous",
                         onTap: (){
                           setState(() {
                             currentIndex< onboardingItems.length? currentIndex-- : null;
                           });
                         },
                       ),
                     ): const SizedBox(),

                     currentIndex == 3? const SizedBox() : Expanded(
                       flex: 2,
                       child: ZButton(
                         label: "next",
                         onTap: (){
                           setState(() {
                             currentIndex< onboardingItems.length? currentIndex++ : null;
                           });
                         },
                       ),
                     ),



                   ],
                 ),
               ),
               currentIndex == 3? ZButton(
                 label: "get_started",
                 onTap: (){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> const SignUp()));
                 },
               ):const SizedBox(),
             ],
           )
            

          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: currentIndex == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentIndex == index ? zPrimaryColor : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

}

class OnboardingWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  const OnboardingWidget({super.key,required this.imagePath, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath),
        Text(title,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
          child: RichText(
              softWrap: true,
              textAlign: TextAlign.justify,
              text: TextSpan(
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      ),
                  children: [
                    TextSpan(text: description),
                  ])),
        ),
      ],
    );
  }
}




