import 'package:celechron/page/scholar/scholar_view.dart';
import 'package:celechron/page/search/search_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'page/calendar/calendar_view.dart';
import 'model/user.dart';
import 'page/flow/flow_view.dart';
import 'page/task/task_view.dart';
import 'database/database_helper.dart';
import 'page/option/option_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

void main() async {
  // 从数据库读取数据
  await Hive.initFlutter();

  // 注入数据库
  var db = Get.put(DatabaseHelper(), tag: 'db');
  await db.init();

  // 注入数据观察项（相当于事件总线，更新这些变量将导致Widget重绘
  Get.put(db.getUser().obs, tag: 'user');
  Get.put(db.getDeadlineList().obs, tag: 'deadlineList');
  Get.put(db.getDeadlineListUpdateTime().obs, tag: 'deadlineListLastUpdate');
  Get.put(db.getFlowList().obs, tag: 'flowList');
  Get.put(db.getFlowListUpdateTime().obs, tag: 'flowListLastUpdate');

  runApp(const CelechronApp());
  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness:
          SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark
              ? Brightness.light
              : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ));
  }
}

class CelechronApp extends StatefulWidget {
  const CelechronApp({super.key});

  @override
  State<CelechronApp> createState() => _CelechronAppState();
}

class _CelechronAppState extends State<CelechronApp> {
  Future<void> initTimezone() async {}

  Future<void> initUser() async {
    var user = Get.find<Rx<User>>(tag: 'user');
    if (user.value.isLogin) {
      // ignore: avoid_print
      print("数据加载成功");
      await user.value.login();
      await user.value.refresh();
      user.refresh();
    } else {
      // ignore: avoid_print
      print("数据加载失败");
    }
  }

  @override
  void initState() {
    super.initState();
    initTimezone();
    initUser();
  }

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      theme: const CupertinoThemeData(
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
      ],
      locale: const Locale('zh'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      title: 'Celechron',
      home: const MyHomePage(title: 'Celechron'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _indexNum = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBuilder: (context, index) => CupertinoTabView(
        builder: (context) => _getPagesWidget(index),
      ),
      tabBar: CupertinoTabBar(
        iconSize: 26,
        backgroundColor: CupertinoDynamicColor.resolve(
                CupertinoColors.secondarySystemBackground, context)
            .withOpacity(0.5),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.time),
            label: '接下来',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: '日程',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.check_mark),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: '学业',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _indexNum,
        onTap: (int index) {
          if (index != _indexNum) {
            setState(() {
              _indexNum = index;
            });
          }
        },
      ),
    );
  }

  Widget _getPagesWidget(int index) {
    List<Widget> widgetList = [
      FlowPage(),
      CalendarPage(),
      TaskPage(),
      ScholarPage(),
      OptionPage(),
      SearchPage(), // 缓存一下
    ];

    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness:
            SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ));
    }

    return Offstage(
      offstage: _indexNum != index,
      child: TickerMode(enabled: _indexNum == index, child: widgetList[index]),
    );
  }
}
