import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class LikesAndDislikes extends StatefulWidget {
  final int likes;
  final int disLikes;
  LikesAndDislikes({this.likes, this.disLikes});

  final String title = "Charts Demo";

  @override
  LikesAndDislikesState createState() => LikesAndDislikesState(
        likes: this.likes,
        disLikes: this.disLikes,
      );
}

class LikesAndDislikesState extends State<LikesAndDislikes> {
  List<charts.Series> seriesList;
  final int likes;
  final int disLikes;
  LikesAndDislikesState({this.likes, this.disLikes});
  static List<charts.Series<PostReactions, String>> _createRandomData(
      likes, dislikes) {
    final desktopSalesData = [
      PostReactions('Likes', likes),
      PostReactions('disLikes', dislikes),
    ];
    return [
      charts.Series<PostReactions, String>(
          id: 'postReactions',
          domainFn: (PostReactions reaction, _) => reaction.type,
          measureFn: (PostReactions reaction, _) => reaction.no,
          data: desktopSalesData,
          fillColorFn: (PostReactions reaction, _) {
            switch (reaction.type) {
              case "Likes":
                {
                  return charts.MaterialPalette.green.shadeDefault;
                }
              case "disLikes":
                {
                  return charts.MaterialPalette.red.shadeDefault;
                }
              default:
                {
                  return charts.MaterialPalette.blue.shadeDefault;
                }
            }
          }),
    ];
  }

  barChart() {
    return new charts.BarChart(
      seriesList,
      animate: true,
      vertical: false,
      primaryMeasureAxis: new charts.NumericAxisSpec(
        renderSpec: new charts.NoneRenderSpec(),
        tickProviderSpec: new charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(5),
            charts.TickSpec<num>(10),
          ],
        ),
      ),
      domainAxis: new charts.OrdinalAxisSpec(
          showAxisLine: true, renderSpec: new charts.GridlineRendererSpec()),
    );
  }

  @override
  void initState() {
    super.initState();
    print("bargraph");
    seriesList = _createRandomData(this.likes, this.disLikes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: barChart(),
      ),
    );
  }
}

class PostReactions {
  final String type;
  final int no;

  PostReactions(this.type, this.no);
}
