import 'package:acadpal_task/repositories/enums.dart';
import 'package:acadpal_task/ui/screens/home.dart';
import 'package:acadpal_task/ui/widgets/noNetwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:acadpal_task/utils/data.dart';
import 'package:acadpal_task/utils/data_containers.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:acadpal_task/utils/graph_duration.dart';
import 'package:provider/provider.dart';

class StatePage extends StatefulWidget {
  final int index;
  final String stateName;
  final String confirmed;
  final String deltaConfirmed;
  final String active;
  final String recovered;
  final String deltaRecovered;
  final String decreased;
  final String deltaDecreased;
  final data;

  StatePage(
      {Key key,
        this.index,
        this.stateName,
        this.confirmed,
        this.deltaConfirmed,
        this.active,
        this.recovered,
        this.deltaRecovered,
        this.decreased,
        this.deltaDecreased,
        this.data})
      : super(key: key);

  @override
  _StatePageState createState() => _StatePageState();
}

class _StatePageState extends State<StatePage> {

  SwiperController _swiperController = SwiperController();
  bool _animateCharts = true;

  GraphDuration _graphDuration = GraphDuration.lifetime;


  final List<String> _lineGraphTitle = [
    'Daily Data',
    'Daily Confirmed',
    'Daily Recovered',
    'Daily Deceased'
  ];

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () => _animateCharts = false);
    super.initState();
  }

  List<charts.Series<CADRPie, String>> _seriesPieData() {
    var pieData = [
      CADRPie('Active', Data.caseData.states[widget.index].active,
          Color(0xff0099cf)),
      CADRPie('Recovered', Data.caseData.states[widget.index].recovered,
          Color(0xff61dd74)),
      CADRPie('Deceased', Data.caseData.states[widget.index].deceased,
          Color(0xffe75f5f))
    ];
    return [
      charts.Series(
          data: pieData,
          domainFn: (CADRPie cadr, _) => cadr.label,
          measureFn: (CADRPie cadr, _) => cadr.value,
          colorFn: (CADRPie cadr, _) =>
              charts.ColorUtil.fromDartColor(cadr.color),
          id: 'Cases Pie Chart',
          labelAccessorFn: (CADRPie cadr, _) => '${cadr.value}')
    ];
  }

  List<charts.Series<DateVsValue, DateTime>> _dailyConfirmedData() {
    int maxIndex = _graphDuration == GraphDuration.week
        ? 7
        : _graphDuration == GraphDuration.month ? 30 : Data.caseData
        .states[widget.index].daily.length;
    var confirmedData = List<DateVsValue>.generate(
        maxIndex,
            (index) =>
            DateVsValue(
                Data.caseData.states[widget.index].daily[Data.caseData
                    .states[widget.index].daily.length - maxIndex + index].date,
                Data.caseData.states[widget.index].daily[Data.caseData
                    .states[widget.index].daily.length - maxIndex + index]
                    .confirmed
                    .toDouble()));
    return [
      charts.Series(
          id: 'ID',
          data: confirmedData,
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff0099cf)),
          domainFn: (DateVsValue dvv, _) => dvv.date,
          measureFn: (DateVsValue dvv, _) => dvv.value)
    ];
  }

  List<charts.Series<DateVsValue, DateTime>> _dailyRecoveredData() {
    int maxIndex = _graphDuration == GraphDuration.week
        ? 7
        : _graphDuration == GraphDuration.month ? 30 : Data.caseData
        .states[widget.index].daily.length;
    var recoveredData = List<DateVsValue>.generate(
        maxIndex,
            (index) =>
            DateVsValue(
                Data.caseData.states[widget.index].daily[Data.caseData
                    .states[widget.index].daily.length - maxIndex + index].date,
                Data.caseData.states[widget.index].daily[Data.caseData
                    .states[widget.index].daily.length - maxIndex + index]
                    .recovered
                    .toDouble()));
    return [
      charts.Series(
          id: 'ID',
          data: recoveredData,
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff61dd74)),
          domainFn: (DateVsValue dvv, _) => dvv.date,
          measureFn: (DateVsValue dvv, _) => dvv.value)
    ];
  }

  List<charts.Series<DateVsValue, DateTime>> _dailyDeceasedData() {
    int maxIndex = _graphDuration == GraphDuration.week
        ? 7
        : _graphDuration == GraphDuration.month ? 30 : Data.caseData
        .states[widget.index].daily.length;
    var deceasedData = List<DateVsValue>.generate(
        maxIndex,
            (index) =>
            DateVsValue(
                Data.caseData.states[widget.index].daily[Data.caseData
                    .states[widget.index].daily.length - maxIndex + index].date,
                Data.caseData.states[widget.index].daily[Data.caseData
                    .states[widget.index].daily.length - maxIndex + index]
                    .deceased
                    .toDouble()));
    return [
      charts.Series(
          id: 'ID',
          data: deceasedData,
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xffe75f5f)),
          domainFn: (DateVsValue dvv, _) => dvv.date,
          measureFn: (DateVsValue dvv, _) => dvv.value)
    ];
  }


  Widget _swiperGraph(int index) {
    var data = [
      _dailyConfirmedData(),
      _dailyRecoveredData(),
      _dailyDeceasedData()
    ];
    if (index == 0) {
      return charts.TimeSeriesChart([data[0][0], data[1][0], data[2][0]],
          defaultRenderer: charts.LineRendererConfig(includeArea: true),
          behaviors: [
            charts.PanAndZoomBehavior(),
          ],
          animate: _animateCharts);
    }
    return charts.TimeSeriesChart(data[index - 1],
        defaultRenderer: charts.LineRendererConfig(includeArea: true),
        behaviors: [
          charts.PanAndZoomBehavior(),
        ],
        animate: _animateCharts);
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(Data.caseData.states[widget.index].name,
            style: TextStyle(color: Colors.green)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: connectionStatus == ConnectivityStatus.offline
          ? NoNetwork()
          :Column(
        children: <Widget>[
          Container(
            height: 10,
          ),
          Text('Total Cases  (${Data.caseData.states[widget.index]
              .confirmed} Confirmed)',
              style: TextStyle(
                  fontFamily: 'Darker Grotesque',
                  fontSize: MediaQuery
                      .of(context)
                      .size
                      .width / 24,
                  fontWeight: FontWeight.w500)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery
                    .of(context)
                    .size
                    .width / 20),
            child: SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 3,
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: charts.PieChart(
                      _seriesPieData(),
                      animate: _animateCharts,
                      animationDuration: Duration(milliseconds: 300),
                      defaultRenderer: charts.ArcRendererConfig(
                          arcWidth: MediaQuery
                              .of(context)
                              .size
                              .width ~/ 6,
                          arcRendererDecorators: [
                            charts.ArcLabelDecorator(
                              labelPosition: charts.ArcLabelPosition.auto,
                            )
                          ]),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.lens, color: Color(0xff0099cf)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Hero(
                                  tag: 'activetext',
                                  child: Text('Active',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1)),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.lens, color: Color(0xff61dd74)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Hero(
                                  tag: 'recoveredtext',
                                  child: Text('Recovered',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1)),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.lens, color: Color(0xffe75f5f)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Hero(
                                  tag: 'deceasedtext',
                                  child: Text('Deceased',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1)),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                _swiperController.index == null
                    ? _lineGraphTitle[0]
                    : _lineGraphTitle[_swiperController.index],
                style: TextStyle(
                    fontFamily: 'Darker Grotesque',
                    fontSize: MediaQuery
                        .of(context)
                        .size
                        .width / 24,
                    fontWeight: FontWeight.w500)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 6,
                  decoration: BoxDecoration(
                      color: _graphDuration == GraphDuration.week
                          ? Theme
                          .of(context)
                          .accentColor
                          : Theme
                          .of(context)
                          .backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() {
                          _graphDuration = GraphDuration.week;
                        }),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text('Week',
                          textAlign: TextAlign.center,
                          style: Theme
                              .of(context)
                              .textTheme
                              .button),
                    ),
                  )),
              Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 6,
                  decoration: BoxDecoration(
                      color: _graphDuration == GraphDuration.month
                          ? Theme
                          .of(context)
                          .accentColor
                          : Theme
                          .of(context)
                          .backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() {
                          _graphDuration = GraphDuration.month;
                        }),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text('Month',
                          textAlign: TextAlign.center,
                          style: Theme
                              .of(context)
                              .textTheme
                              .button),
                    ),
                  )),
              Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 6,
                  decoration: BoxDecoration(
                      color: _graphDuration == GraphDuration.lifetime
                          ? Theme
                          .of(context)
                          .accentColor
                          : Theme
                          .of(context)
                          .backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() {
                          _graphDuration = GraphDuration.lifetime;
                        }),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text('Lifetime',
                          textAlign: TextAlign.center,
                          style: Theme
                              .of(context)
                              .textTheme
                              .button),
                    ),
                  )),
            ],
          ),
          Expanded(
              child: Swiper(
                autoplay: true,
                itemCount: 4,
                itemBuilder: (context, index) =>
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _swiperGraph(index),
                    ),
                pagination: SwiperPagination(),
                controller: _swiperController,
                onIndexChanged: (index) =>
                    setState(() {
                      _swiperController.index = index;
                    }),
              )),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 16.0,
                borderRadius: BorderRadius.all(Radius.circular((5.0))),
                color: Theme
                    .of(context)
                    .accentColor,
                child: InkWell(
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              Home())),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:
                    Text('View Statewise Data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize:
                            MediaQuery
                                .of(context)
                                .size
                                .width / 24,
                            fontFamily: 'Darker Grotesque',
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}