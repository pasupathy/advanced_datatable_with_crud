import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:advanced_datatable_with_crud/permissions_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class AddEditPermission extends StatefulWidget {
  final Permissionsmodel perm;

  const AddEditPermission({
    Key? key,
    required this.perm,
  }) : super(key: key);

  @override
  State<AddEditPermission> createState() => _AddEditPermissionState();
}

class _AddEditPermissionState extends State<AddEditPermission> {
  var _permSequenceController = TextEditingController();
  var _permNameController = TextEditingController();
  bool _validateName = false;
  bool _validateSequence = false;
  late String modulevalue = "purchasing";
  String actions = "Add";

  List modulelist = [
    {"id": "purchasing"},
    {"id": "workflows"},
    {"id": "quality"},
    {"id": "company"},
    {"id": "currency"},
    {"id": "delivery"},
    {"id": "invoice"},
    {"id": "mode"},
    {"id": "permissions"},
    {"id": "packing"},
    {"id": "product"},
    {"id": "quotation"},
    {"id": "receive"},
    {"id": "roles"},
    {"id": "salesorder"},
    {"id": "stockorder"},
    {"id": "supplier"},
    {"id": "tariff"},
    {"id": "tnc"},
    {"id": "users"},
  ];
  bool isloading = false;

  SavePermission(Permissionsmodel perm) async {
    try {
      var phpApi = actions == 'Add' ? 'addPermissions' : 'updatePermissions';
      final requestUri =
          Uri.http('192.168.43.11', 'smith9/public/api/' + phpApi);
      final response = await http.post(requestUri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'id': perm.id,
            'name': perm.name,
            'module': perm.module,
            'sequence': perm.sequence
          }));
      print(response.statusCode);
      print(jsonDecode(response.body));
      if (response.statusCode == 201 || response.statusCode == 200) {
        var message = actions == 'Add' ? 'Created' : 'Updated';
        var error = jsonDecode(response.body);
        print(error);
        Fluttertoast.showToast(
            msg: "Permission " + message + " Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        // set state update datatable

        return 'redirect';
      }
      if (response.statusCode == 422) {
        var error = jsonDecode(response.body);
        print(error.toString());
        return error['message'].toString();
      }
    } catch (e) {
      //ignored
      print('catch');
      print(e);
    }
  }

  @override
  void initState() {
    setState(() {
      _permNameController.text = widget.perm.name ?? '';
      if (_permNameController.text != '') actions = 'Edit';

      _permSequenceController.text =
          widget.perm.sequence == null ? '' : widget.perm.sequence.toString();
      modulevalue = widget.perm.module ?? 'afe';
    });
    super.initState();
  }

  String errorText = 'Name Value Can\'t Be Empty';
  //var _userService = UserService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(actions + " Permissions"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Modules',
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.blueGrey,
                        width: 1,
                        style: BorderStyle.solid),
                    //  borderRadius: BorderRadius.
                    //
                    //  circular(8)
                  ),
                  child: DropdownButton(
                    value: modulevalue,
                    hint: Text("Select Modules",
                        style: TextStyle(color: Colors.black)),
                    items: modulelist.map((list) {
                      return DropdownMenuItem(
                        child: Text(list['id']),
                        value: list['id'].toString(),
                      );
                    }).toList(),
                    onChanged: (String? newValue3) {
                      setState(() {
                        modulevalue = newValue3!;
                      });
                    },
                  )),
              const SizedBox(
                height: 20.0,
              ),
              Text('Enter Sequence',
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: _permSequenceController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Sequence',
                  labelText: 'Sequence',
                  errorText:
                      _validateSequence ? 'Sequence Value Can\'t Be Empty' : '',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text('Enter Name',
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                  controller: _permNameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter Name',
                    labelText: 'Name',
                    errorText: _validateName ? errorText : '',
                  )),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  isloading
                      ? Center(child: CircularProgressIndicator())
                      : TextButton(
                          style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.teal,
                              textStyle: const TextStyle(fontSize: 15)),
                          onPressed: () async {
                            setState(() {
                              _permNameController.text.isEmpty
                                  ? _validateName = true
                                  : _validateName = false;
                              _permSequenceController.text.isEmpty
                                  ? _validateSequence = true
                                  : _validateSequence = false;
                            });
                            if (_validateName == false &&
                                _validateSequence == false) {
                              isloading = true;
                              var _perm = Permissionsmodel(
                                  widget.perm.id,
                                  modulevalue,
                                  int.parse(_permSequenceController.text),
                                  _permNameController.text,
                                  'web',
                                  '',
                                  '');

                              String result = await SavePermission(_perm);
                              print(result);
                              if (result == 'redirect') {
                                Navigator.pop(context, true);
                              } else {
                                setState(() {
                                  isloading = false;
                                  _validateName = true;
                                  errorText = result;
                                });
                              }
                            }
                          },
                          child: const Text('Save')),
                  const SizedBox(
                    width: 10.0,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red,
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: () {
                        _permNameController.text = '';
                        _permSequenceController.text = '';
                      },
                      child: const Text('Clear'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
