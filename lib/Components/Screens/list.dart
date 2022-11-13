import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pagination_project/Model/pokedex.dart';
import 'package:pagination_project/Model/pokemon.dart';
import 'package:refresh_loadmore/refresh_loadmore.dart';
import 'package:http/http.dart' as http;

class PokePage extends StatefulWidget {
  PokePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PokePageState createState() => _PokePageState();
}

class _PokePageState extends State<PokePage> {
  bool isLastPage = false;
  bool loading = false;
  int count = 20;
  String _apiUrl = "https://pokeapi.co/api/v2/pokemon/";
  List<Pokemon> list = [];
  int page = 1;

  @override
  void initState() {
    super.initState();
    loadFirstData();
  }

  Future<List<Pokemon>> getPokemon(bool isFirst) async {
    List<Pokemon> resultData = [];
    int i;
    if (isFirst) {
      page = 1;
    }
    for (i = page; i <= (page + count); i++) {
      final res = await http.get(Uri.parse(_apiUrl + (i).toString()));
      Map<String, dynamic> jsonDecoded = json.decode(res.body);
      resultData.add(Pokemon.fromJson(jsonDecoded));
    }
    page = i;
    return resultData;
  }

  Future<void> loadFirstData() async {
    await Future.delayed(Duration(seconds: 1), () async {
      loading = true;
      var data = await getPokemon(true);

      setState(() {
        list = data;
        loading = false;
        isLastPage = false;
      });
    });
  }

  Future<void> loadMore() async {
    await Future.delayed(Duration(seconds: 1), () async {
      loading = true;
      var data = await getPokemon(false);
      setState(() {
        list.addAll(data);
        loading = false;
        isLastPage = list.length == 0;
      });
    });
  }

  Future<void> filterPokemon(String name) async {
    loading = true;

    await Future.delayed(Duration(seconds: 1), () async {
      var allData = await getPokemon(true);
      var data;
      if (name != "") {
        data = list
            .where(
                (element) => element.name.toLowerCase() == name.toLowerCase())
            .toList();
        setState(() {
          list = data;

          loading = false;
        });
      } else {
        setState(() {
          list = allData;
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromRGBO(213, 229, 233, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(66, 195, 151, 1),
          centerTitle: true,
          title: const Text("Pokedex"),
        ),
        body: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    onChanged: (value) => filterPokemon(value),
                    decoration: (new InputDecoration(
                        hintStyle: (TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(90, 90, 90, 0.6))),
                        hintText: 'Search for Pokemon',
                        labelStyle: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(90, 90, 90, 0.6)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: InputBorder.none,
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white)),
                  ),
                ),
              ),
              loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: const Color.fromRGBO(66, 195, 151, 1),
                      ),
                    )
                  : Expanded(
                      child: RefreshLoadmore(
                        onRefresh: loadFirstData,
                        onLoadmore: loadMore,
                        noMoreWidget: Text(
                          'No more data, you are at the end',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        isLastPage: isLastPage,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: AlignedGridView.count(
                            shrinkWrap: true,
                            itemCount: list.length,
                            physics: ScrollPhysics(),
                            crossAxisCount: 3,
                            itemBuilder: (context, index) {
                              return list != null
                                  ? Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Image.network(list[index].image),
                                          Text(list[index].name),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ],
                                      ),
                                    )
                                  : Container();
                            },
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ));
  }
}
