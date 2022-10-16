import 'package:flutter/material.dart';
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:advanced_datatable_with_crud/permissions_model.dart';
import 'package:advanced_datatable_with_crud/addEditPermission.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  var _rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;
  var _sortIndex = 0;
  var _sortAsc = true;
  final _searchController = TextEditingController();
  var _customFooter = false;
  List data = [];
  var currentpageindex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.text = '';
  }

  var fields = ['Name', 'Sequence', 'Module', 'Created Date'];
  late String fieldvalue = "Name";
  late final _source = ExampleSource(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Change footer',
            onPressed: () {
              // handle the press
              setState(() {
                _customFooter = !_customFooter;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, bottom: 0, right: 0, top: 18),
                        child: DropdownButton(
                          // dropdownColor: Colors.redAccent, //dropdown background color

                          value: fieldvalue,
                          hint: Text("Select Modules",
                              style: TextStyle(color: Colors.black)),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: fields.map((String fields) {
                            return DropdownMenuItem(
                              value: fields,
                              child: Text(fields),
                            );
                          }).toList(),
                          onChanged: (String? newValue3) {
                            setState(() {
                              fieldvalue = newValue3!;
                            });
                          },
                        ))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 0, bottom: 0, right: 20, top: 2),
                    child: TextField(
                      controller: _searchController,
                      // decoration: const InputDecoration(
                      //   labelText: 'Search by permission',
                      // ),
                      onSubmitted: (value) {
                        _source.filterServerSide(
                            _searchController.text, fieldvalue);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.text = '';
                    });
                    _source.filterServerSide(
                        _searchController.text, fieldvalue);
                  },
                  icon: const Icon(Icons.clear),
                ),
                IconButton(
                  onPressed: () => _source.filterServerSide(
                      _searchController.text, fieldvalue),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            AdvancedPaginatedDataTable(
              addEmptyRows: false,
              source: _source,
              sortAscending: _sortAsc,
              sortColumnIndex: _sortIndex,
              showFirstLastButtons: true,
              showCheckboxColumn: false,
              rowsPerPage: _rowsPerPage,
              availableRowsPerPage: const [10, 20, 30, 50],
              onRowsPerPageChanged: (newRowsPerPage) {
                if (newRowsPerPage != null) {
                  setState(() {
                    _rowsPerPage = newRowsPerPage;
                  });
                }
              },
              columns: [
                DataColumn(
                  label: const Text('ID'),
                  numeric: true,
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Module'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Sequence'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Name'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Guard Name'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Created Date'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Updated Date'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Edit'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Delete'),
                  onSort: setSort,
                ),
              ],

              //Optianl override to support custom data row text / translation
              getFooterRowText:
                  (startRow, pageSize, totalFilter, totalRowsWithoutFilter) {
                final localizations = MaterialLocalizations.of(context);
                var amountText = localizations.pageRowsInfoTitle(
                  startRow,
                  pageSize,
                  totalFilter ?? totalRowsWithoutFilter,
                  false,
                );

                if (totalFilter != null) {
                  //Filtered data source show addtional information
                  amountText += ' filtered from ($totalRowsWithoutFilter)';
                }
                currentpageindex = startRow;

                return amountText;
              },
              customTableFooter: _customFooter
                  ? (source, offset) {
                      const maxPagesToShow = 6;
                      const maxPagesBeforeCurrent = 3;
                      final lastRequestDetails = source.lastDetails!;
                      final rowsForPager = lastRequestDetails.filteredRows ??
                          lastRequestDetails.totalRows;
                      final totalPages = rowsForPager ~/ _rowsPerPage;
                      final currentPage = (offset ~/ _rowsPerPage) + 1;

                      final List<int> pageList = [];
                      if (currentPage > 1) {
                        pageList.addAll(
                          List.generate(currentPage - 1, (index) => index + 1),
                        );
                        //Keep up to 3 pages before current in the list
                        pageList.removeWhere(
                          (element) =>
                              element < currentPage - maxPagesBeforeCurrent,
                        );
                      }
                      pageList.add(currentPage);
                      //Add reminding pages after current to the list
                      pageList.addAll(
                        List.generate(
                          maxPagesToShow - (pageList.length - 1),
                          (index) => (currentPage + 1) + index,
                        ),
                      );
                      pageList.removeWhere((element) => element > totalPages);

                      currentpageindex = (currentPage + 1);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: pageList
                            .map(
                              (e) => TextButton(
                                onPressed: e != currentPage
                                    ? () {
                                        //Start index is zero based
                                        source.setNextView(
                                          startIndex: (e - 1) * _rowsPerPage,
                                        );
                                      }
                                    : null,
                                child: Text(
                                  e.toString(),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var _user = Permissionsmodel(null, 'afe', null, '', '', '', '');

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddEditPermission(
                        perm: _user,
                      ))).then((response) {
            // _source.filterServerSide('', '');
            // print(_sortAsc);
            if (currentpageindex > 1) {
              _source.setNextView();
              setSort(0, false);
            } else {
              if (_sortAsc == false)
                _source.setNextView();
              else
                setSort(0, false);
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // ignore: avoid_positional_boolean_parameters
  void setSort(int i, bool asc) => setState(() {
        _sortIndex = i;
        _sortAsc = asc;
        //   ExampleSource(context).setNextView(startIndex: 0);
      });
}

typedef SelectedCallBack = Function(String id, bool newSelectState);

class ExampleSource extends AdvancedDataTableSource<Permissionsmodel> {
  List<String> selectedIds = [];
  String lastSearchTerm = '';
  String searchField = '';
  final context;

  ExampleSource(this.context);

  @override
  DataRow? getRow(int index) {
    final currentRowData = lastDetails!.rows[index];
    //  print(currentRowData.toJson());

    return DataRow(
      cells: [
        DataCell(Text(currentRowData.id.toString())),
        DataCell(Text(currentRowData.module)),
        DataCell(Text(currentRowData.sequence.toString())),
        DataCell(Text(currentRowData.name)),
        DataCell(Text(currentRowData.guard_name)),
        DataCell(Text(currentRowData.created_at)),
        DataCell(Text(currentRowData.updated_at)),
        DataCell(Icon(Icons.edit), onTap: () {
          var _user = Permissionsmodel(
              currentRowData.id,
              currentRowData.module,
              currentRowData.sequence,
              currentRowData.name,
              currentRowData.guard_name,
              currentRowData.created_at,
              currentRowData.updated_at);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddEditPermission(
                        perm: _user,
                      ))).then((data) {
            forceRemoteReload = true;
            notifyListeners();
          });
        }),
        DataCell(Icon(Icons.delete), onTap: () {
          //    print(currentRowData.id.toString() + 'delete');
          var rowid = currentRowData.id.toString();
          var rowname = currentRowData.name;
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('$rowid  $rowname'),
                content: Text('Are you sure to delete this row?'),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Delete'),
                    onPressed: () async {
                      // delete api
                      var delete = await deletePermission(currentRowData.id);
                      //if (delete) {
                      Fluttertoast.showToast(
                          msg: "Permission deleted successfully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 5,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      Navigator.of(context).pop();
                      forceRemoteReload = true;
                      notifyListeners();
                      // }
                    },
                  ),
                ],
              );
            },
          );
        }),
      ],
      onSelectChanged: (newState) {
        //  print(currentRowData.id.toString());
        //callback(currentRowData.id.toString(), newState ?? false);
      },
      selected: selectedIds.contains(currentRowData.id.toString()),
    );
  }

  @override
  int get selectedRowCount => selectedIds.length;

  // ignore: avoid_positional_boolean_parameters
  void selectedRow(String id, bool newSelectState) {
    if (selectedIds.contains(id)) {
      print('remove');
      selectedIds.remove(id);
    } else {
      print('add');
      selectedIds.add(id);
    }
    notifyListeners();
  }

  void filterServerSide(String filterQuery, String fieldvalue) {
    lastSearchTerm = filterQuery.toLowerCase().trim();
    searchField = fieldvalue;
    setNextView();
  }

  @override
  Future<RemoteDataSourceDetails<Permissionsmodel>> getNextPage(
    NextPageRequest pageRequest,
  ) async {
    //the remote data source has to support the pagaing and sorting
    final queryParameter = <String, dynamic>{
      'offset': pageRequest.offset.toString(),
      'pageSize': pageRequest.pageSize.toString(),
      'sortIndex': ((pageRequest.columnSortIndex ?? 0) + 1).toString(),
      'sortAsc': ((pageRequest.sortAscending ?? true) ? 1 : 0).toString(),
      if (lastSearchTerm.isNotEmpty) 'searchValue': lastSearchTerm,
      if (searchField.isNotEmpty) 'fieldName': searchField,
    };

    final requestUri = Uri.http(
      '192.168.43.11',
      'smith9/public/api/permissions',
      queryParameter,
    );

    final response = await http.get(requestUri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RemoteDataSourceDetails(
        int.parse(data['totalRows'].toString()),
        (data['rows'] as List<dynamic>)
            .map(
              (json) => Permissionsmodel.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
        filteredRows: lastSearchTerm.isNotEmpty
            ? (data['rows'] as List<dynamic>).length
            : null,
      );
    } else {
      throw Exception('Unable to query remote server');
    }
  }

  deletePermission(id) async {
    try {
      var requestUri =
          Uri.http('192.168.43.11', 'smith9/public/api/deletePermission');
      var response = await http.post(requestUri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'id': id}));
      if (response.statusCode == '200') {
        Fluttertoast.showToast(
            msg: "Permission deleted Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        // set state update datatable

      }
    } catch (e) {
      print(e);
    }
  }
}
