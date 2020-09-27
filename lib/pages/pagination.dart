// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// void main() => runApp(Test());

// class Test extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   Firestore firestore = Firestore.instance;
//   List<DocumentSnapshot> products = [];
//   bool isLoading = false;
//   bool hasMore = true;
//   int documentLimit = 10;
//   DocumentSnapshot lastDocument;
//   ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     getProducts();
//     _scrollController.addListener(() {
//       double maxScroll = _scrollController.position.maxScrollExtent;
//       double currentScroll = _scrollController.position.pixels;
//       double delta = MediaQuery.of(context).size.height * 0.20;
//       if (maxScroll - currentScroll <= delta) {
//         getProducts();
//       }
//     });
//   }

//   getProducts() async {
//     if (!hasMore) {
//       print('No More Products');
//       return;
//     }
//     if (isLoading) {
//       return;
//     }
//     setState(() {
//       isLoading = true;
//     });
//     QuerySnapshot querySnapshot;
//     if (lastDocument == null) {
//       querySnapshot = await firestore
//           .collection('dummyPosts')
//           .orderBy('timestamp')
//           .limit(documentLimit)
//           .getDocuments();
//     } else {
//       querySnapshot = await firestore
//           .collection('dummyPosts')
//           .orderBy('timestamp')
//           .startAfter([lastDocument])
//           .limit(documentLimit)
//           .getDocuments();
//       print(1);
//     }
//     if (querySnapshot.documents.length < documentLimit) {
//       hasMore = false;
//     }
//     lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
//     products.addAll(querySnapshot.documents);
//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Pagination with Firestore'),
//       ),
//       body: Column(children: [
//         Expanded(
//           child: products.length == 0
//               ? Center(
//                   child: Text('No Data...'),
//                 )
//               : ListView.builder(
//                   controller: _scrollController,
//                   itemCount: products.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       contentPadding: EdgeInsets.all(5),
//                       title: Text(products[index].data['username']),
//                       subtitle: Text(products[index].data['postId']),
//                     );
//                   },
//                 ),
//         ),
//         isLoading
//             ? Container(
//                 width: MediaQuery.of(context).size.width,
//                 padding: EdgeInsets.all(5),
//                 color: Colors.yellowAccent,
//                 child: Text(
//                   'Loading',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               )
//             : Container()
//       ]),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartsDemo extends StatefulWidget {
  ChartsDemo() : super();

  final String title = "Charts Demo";

  @override
  ChartsDemoState createState() => ChartsDemoState();
}

class ChartsDemoState extends State<ChartsDemo> {
  List<charts.Series> seriesList;
  static List<charts.Series<PostReactions, String>> _createRandomData() {
    final desktopSalesData = [
      PostReactions('Likes', 10),
      PostReactions('disLikes', 50),
    ];
    return [
      charts.Series<PostReactions, String>(
          id: 'postReactions',
          domainFn: (PostReactions posts, _) => posts.type,
          measureFn: (PostReactions posts, _) => posts.no,
          data: desktopSalesData,
          fillColorFn: (PostReactions posts, _) {
            switch (posts.type) {
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
          },
          labelAccessorFn: (PostReactions posts, _) =>
              '${posts.type}: \$${posts.no.toString()}'),
    ];
  }

  barChart() {
    return new charts.BarChart(
      seriesList,
      animate: true,
      vertical: false,

      /// Assign a custom style for the measure axis.
      primaryMeasureAxis:
          new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),
      domainAxis: new charts.OrdinalAxisSpec(
          showAxisLine: true,
          renderSpec: new charts.GridlineRendererSpec(
              // Display the measure axis labels below the gridline.
              //
              // 'Before' & 'after' follow the axis value direction.
              // Vertical axes draw 'before' below & 'after' above the tick.
              // Horizontal axes draw 'before' left & 'after' right the tick.

              // Left justify the text in the axis.
              //
              // Note: outside means that the secondary measure axis would right
              // justify.
              )),
    );
  }

  @override
  void initState() {
    super.initState();
    seriesList = _createRandomData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // height: 100,
        // padding: EdgeInsets.all(20.0),
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
