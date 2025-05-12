import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:swee16/widget/numberWidget.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: blackColor,

        automaticallyImplyLeading: false,
        title: Text("Fawad Kaleem", style: TextStyle(color: whiteColor)),
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 160,
                      width: 380,
                      child: Card(
                        color: textFieldColor,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  "23 December 2023",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),

                            //1 to 8
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Numberwidget(
                                    title: "1",
                                    color: redOrange,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "2",
                                    color: lightGreen,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "3",
                                    color: brightNeonGreen,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "4",
                                    color: vivedYellow,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "5",
                                    color: brownishOrange,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "6",
                                    color: hotPink,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "7",
                                    color: oliveGreen,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "8",
                                    color: goldenOrange,
                                    number: "1%",
                                  ),
                                ],
                              ),
                            ),
                            //9 to 16
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Numberwidget(
                                    title: "9",
                                    color: red,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "10",
                                    color: goldenYellow,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "11",
                                    color: lightGrey,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "12",
                                    color: purpleBlue,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "13",
                                    color: warmOrange,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "14",
                                    color: royalPurple,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "15",
                                    color: greenishGrey,
                                    number: "1%",
                                  ),
                                  Numberwidget(
                                    title: "16",
                                    color: margintaPink,
                                    number: "1%",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete, color: removeColor),
                  ),
                ],
              ),
              Divider(color: whiteColor, height: 3),
            ],
          );
        },
      ),
    );
  }
}
