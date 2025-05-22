// import 'package:cityvoice/pages/home.dart';
import 'package:cityvoice/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:cityvoice/pages/log_in.dart';
import 'package:cityvoice/pages/create_report.dart';
import 'package:cityvoice/pages/report_list_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    // '/': (context) => const HomePage(),
    '/': (context) => const LogInPage(),
    '/home': (context) => const HomeScreen(),
    '/new-report': (context) => const NewReportScreen(),
    '/resport_list_screen': (context) => const ReportListScreen(),
  };
}
