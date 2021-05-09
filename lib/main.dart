import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './widgets/chart.dart';
import 'widgets/transaction_list.dart';
import 'model/transaction.dart';
import 'widgets/new_transaction.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // To fux portrait mode
  // SystemChrome.setPreferredOrientations(
  //   [DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,]
  // );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return MaterialApp(
      title: 'My Expenses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        errorColor: Colors.red,
        fontFamily: 'Quicksand',
        //family name in yaml file
        textTheme: ThemeData
            .light()
            .textTheme
            .copyWith(
          title: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData
              .light()
              .textTheme
              .copyWith(
            title: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // List of transactions

  // bottom Modal sheet
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'Watermelon',
    //   amount: 40.00,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Mango',
    //   amount: 60.00,
    //   date: DateTime.now(),
    // ),
  ];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTrans(String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
        title: txTitle,
        amount: txAmount,
        date: chosenDate,
        id: DateTime.now().toString());

    // On new tx State is changed
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTrans(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          // to prevent sheet from getting closed when you tap on it
          child: NewTransaction(_addNewTrans),
          behavior: HitTestBehavior
              .opaque, // in current version we don't need to do this
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(MediaQueryData mediaQuery,
      AppBar appBar,
      Widget txListWidget,) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Show Chart', style: Theme
              .of(context)
              .textTheme
              .title,),
          Switch.adaptive(
            activeColor: Theme
                .of(context)
                .accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          )
        ],
      ),
      _showChart
          ? Container(
        height: (mediaQuery.size.height -
            appBar.preferredSize.height -
            mediaQuery.padding.top) *
            0.7,
        child: Chart(_recentTransactions)
        ,)
          : txListWidget,
    ];
  }

  List<Widget> _buildPortraitContent(MediaQueryData mediaQuery,
      AppBar appBar,
      Widget txListWidget) {
    return [Container(
      height: (mediaQuery.size.height -
          appBar.preferredSize.height -
          mediaQuery.padding.top) *
          0.3,
      child: Chart(_recentTransactions),
    ), txListWidget];
  }

  Widget _cupertinoAppBar()
  {
   return CupertinoNavigationBar(
      middle: Text(
        'My Expenses',
        style: TextStyle(fontFamily: 'Open Sans'),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: () => _startAddNewTrans(context),
          )
        ],
      ),
    );
  }

  Widget _normalAppBar()
  {
    return AppBar(
      title: Text(
        'My Expenses',
        style: TextStyle(fontFamily: 'Open Sans'),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTrans(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS ? _cupertinoAppBar()
        : _normalAppBar();
    final txListWidget = Container(
      height: (mediaQuery.size.height -
          appBar.preferredSize.height -
          mediaQuery.padding.top) *
          0.7,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );

    final page = SafeArea(child: SingleChildScrollView(
      child: Column(
        //To position items we have Main Axis (y) & Cross Axis (x) for Column
        //  For row these are opposite
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // Adding two children in column because two sections
        children: <Widget>[
          if (isLandscape)
          //Spread Operator converting to list of widgets
            ..._buildLandscapeContent(mediaQuery,
              appBar,
              txListWidget,),
          if(!isLandscape)
            ..._buildPortraitContent(
              mediaQuery,
              appBar,
              txListWidget,
            ),
        ],
      ),
    ),
    );

    return Platform.isIOS ? CupertinoPageScaffold(
      child: page, navigationBar: appBar,) : Scaffold(
      appBar: appBar,
      body: page,
      floatingActionButton: Platform.isIOS ? Container() : FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTrans(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
