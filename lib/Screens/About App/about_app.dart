import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    List about = [
      "Coronavirus disease (COVID-19) is an infectious disease caused by the SARS-CoV-2 virus."
          "Most people who fall sick with COVID-19 will experience mild to moderate symptoms and recover without special treatment. However, some will become seriously ill and require medical attention."
          "The virus can spread from an infected person’s mouth or nose in small liquid particles when they cough, sneeze, speak, sing or breathe. These particles range from larger respiratory droplets to smaller aerosols."
          "You can be infected by breathing in the virus if you are near someone who has COVID-19, or by touching a contaminated surface and then your eyes, nose or mouth. The virus spreads more easily indoors and in crowded settings."
    ];
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text("zaitoon_note"),
                background: Container(
                  color: Colors.teal,
                  child: const Icon(Icons.coronavirus,
                      size: 100, color: Colors.white),
                ),
              ),
            ),
            SliverFillRemaining(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Version: 1.0.0+1",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RichText(
                        softWrap:true,
                        textAlign:TextAlign.justify,
                        text:TextSpan(
                            style:const TextStyle(color: Colors.black87),
                            children:[
                              TextSpan(text: about[0]),

                            ])),
                  ),

                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Developed by",style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                "Basir Hashimi"
                            ),
                            Text(
                                "©2023"
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
      }
}



