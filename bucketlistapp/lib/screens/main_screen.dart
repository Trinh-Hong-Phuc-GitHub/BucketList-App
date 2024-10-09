import 'package:bucketlistapp/screens/view_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'add_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<dynamic> bucketListData = [];
  bool isLoading = false;
  bool isError = false;

  Future<void> getData() async {
    // Get Data From API
    setState(() {
      isLoading = true;
    });
    try {
      Response response = await Dio().get(
          "https://flutterapitest-605cc-default-rtdb.firebaseio.com/bucketlist.json");
      if (response.data is List) {
        bucketListData = response.data;
      } else {
        bucketListData = [];
      }
      isLoading = false;
      isError = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      isError = true;
      setState(() {});
    }
  }

  @override
  void initState() {
    getData();
    // TODO: implement initState
    super.initState();
  }

  Widget errorWidget({required String errorText}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning),
          Text(errorText),
          ElevatedButton(
            onPressed: getData,
            child: Text('Try Again'),
          )
        ],
      ),
    );
  }

  Widget listDataWidget() {
    List<dynamic> filteredList = bucketListData
        .where((element) => (!element["completed"] ?? false))
        .toList();
    return filteredList.length < 1
        ? Center(
            child: Text("No data on bucket list"),
          )
        : ListView.builder(
            itemCount: bucketListData.length,
            itemBuilder: (context, index) {
              return (bucketListData[index] is Map &&
                      (!bucketListData[index]?["completed"] ?? false))
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ViewItemScreen(
                                title: bucketListData[index]['item'] ?? "",
                                index: index,
                                image: bucketListData[index]['image'] ?? "",
                              );
                            },
                          )).then(
                            (value) {
                              if (value == "refresh") {
                                getData();
                              }
                            },
                          );
                        },
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(bucketListData[index]?['image']),
                        ),
                        title: Text(bucketListData[index]?['item'] ?? ""),
                        trailing: Text(
                            bucketListData[index]?['cost'].toString() ?? ""),
                      ),
                    )
                  : SizedBox();
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return AddBucketList(
                newIndex: bucketListData.length,
              );
            },
          )).then(
            (value) {
              if (value == "refresh") {
                getData();
              }
            },
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Bucket List"),
        actions: [
          InkWell(
            onTap: getData,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getData();
        },
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : isError
                ? errorWidget(errorText: "Error connecting...")
                : listDataWidget(),
      ),
    );
  }
}
