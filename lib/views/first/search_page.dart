import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/utils/toast.dart';
import 'package:bbs/views/bbs/bbs_item.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.search});
  final String search;
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  RefreshController _refreshController = RefreshController();
  int _searchType = 0; //全部
  List<BBSModel> _bbsList = [];
  int _startIndex = 0;
  int _totalData = 0;
  late String _search;
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _search = widget.search;
    _searchController.text = _search;
    getSearch();
  }

  Future<void> getSearch({bool clear = false}) async {
    if (clear) {
      _startIndex = 0;
      _bbsList.clear();
    }
    Map _res = await Api.searchBBS(_search, type: _searchType, start: _startIndex);
    if (_res['code'] == 200) {
      List<Map<String, dynamic>> _list = List<Map<String, dynamic>>.from(_res['result']['data']);
      for (final json in _list) {
        BBSModel _bbsModel = BBSModel.fromJson(json);
        _bbsList.add(_bbsModel);
      }
      _totalData = _res['result']['page']['total'];
      _startIndex += (_res['result']['page']['returnDataCount'] ?? 0) as int;
      setState(() {});
    } else {
      Toast.showToast(_res['msg'] ?? "出错了");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget search = Container(
        height: 32,
        width: double.infinity,
        alignment: Alignment.center,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(width: 32, height: 32, child: Icon(Icons.arrow_back_ios)),
            ),
            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 14),
                controller: _searchController,
                decoration: InputDecoration(
                    fillColor: Colors.grey[200],
                    filled: true,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                    hintText: "请输入搜索内容",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    contentPadding: EdgeInsets.only(left: 12)),
              ),
            )
          ],
        ));
    Widget typeBar = TabBar(
      tabs: [
        Tab(text: "全部"),
        Tab(text: "问答"),
        Tab(text: "WIKI"),
        Tab(text: "帖子"),
      ],
      controller: _tabController,
      onTap: (value) {
        _searchType = value;
        getSearch(clear: true);
      },
    );

    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          search,
          typeBar,
          Expanded(
              child: SmartRefresher(
            onLoading: () {
              if (_startIndex == _totalData) {
                _refreshController.loadNoData();
              } else {
                getSearch().then((value) {
                  _refreshController.loadComplete();
                });
              }
            },
            enablePullUp: false,
            controller: _refreshController,
            child: ListView.builder(
              itemCount: _bbsList.length,
              itemBuilder: (BuildContext context, int index) {
                return BBSItem(
                  key: UniqueKey(),
                  bbs: _bbsList[index],
                );
              },
            ),
          ))
        ],
      ),
    ));
  }
}
