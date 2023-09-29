import 'package:flutter/material.dart';
import 'wifi_view.dart';
import 'bluetooth_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Wifi And Bluetooth"),
          bottom: const PreferredSize(
            preferredSize: Size(double.infinity, 45),
            child: TabBar(
              tabs: [
                Tab(
                  text: "Wifi",
                ),
                Tab(
                  text: "Bluetooth",
                ),
              ] 
            )),
        ),
        body: const TabBarView(
          children:[
            WifiVIew(),
            BluetoothView()
          ] 
        ) ,
      ),
    );
  }
}