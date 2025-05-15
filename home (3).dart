import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class OnlineApiPage extends StatefulWidget {
  const OnlineApiPage({super.key});

  @override
  State<OnlineApiPage> createState() => _OnlineApiPageState();
}

class _OnlineApiPageState extends State<OnlineApiPage> {
  bool isConnectedToInternet = false;
  StreamSubscription? _internetConnectionStreamSubscription;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();

  String? _selectedCourseName;
  String? _selectedSemester;
  String? _selectedCreditHours;

  bool _isSubmitting = false;
  bool _isFetching = false;
  bool _isSuccess = false;
  String _responseMessage = '';
  String _sortOrder = 'oldest';

  List<dynamic> _gradesData = [];
  List<String> _courseNames = [];

  final List<String> _semesterOptions = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> _creditHourOptions = ['1', '2', '3', '4'];

  final String _postUrl = 'https://devtechtop.com/management/public/api/grades';
  final String _getUrl = 'https://devtechtop.com/management/public/api/select_data';
  final String _coursesUrl = 'https://bgnuerp.online/api/get_courses?user_id=12122';

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _internetConnectionStreamSubscription =
        InternetConnection().onStatusChange.listen((event){
          switch(event){
            case InternetStatus.connected:
              setState(() {
                isConnectedToInternet = true;
              });
              break;

            case InternetStatus.disconnected:
              setState(() {
                isConnectedToInternet = false;
              });
              break;

              default:
                setState(() {
                  isConnectedToInternet = false;
                });

                break;
          }
        });

  }
  @override
  void dispose()
  {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }
  Future<void> _fetchCourses() async {
    try {
      final response = await http.get(Uri.parse(_coursesUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            _courseNames = data.map((course) => course['subject_name'].toString()).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load data: $e");
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _responseMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(_postUrl),
        body: {
          'user_id': _userIdController.text.trim(),
          'course_name': _selectedCourseName!,
          'semester_no': _selectedSemester!,
          'credit_hours': _selectedCreditHours!,
          'marks': _marksController.text.trim(),
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        setState(() {
          _isSuccess = true;
          _responseMessage = '✅ Data Submitted Successfully!';
        });
        _formKey.currentState!.reset();
        _userIdController.clear();
        _marksController.clear();
        _selectedCourseName = null;
        _selectedSemester = null;
        _selectedCreditHours = null;
        _fetchData();
      } else {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _isSuccess = false;
          _responseMessage = jsonResponse['message'] ?? 'Submission failed.';
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _responseMessage = '❌ Error: $e';
      });
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isFetching = true);

    try {
      final response = await http.get(Uri.parse(_getUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          setState(() => _gradesData = jsonData);
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          setState(() => _gradesData = jsonData['data']);
        } else {
          setState(() {
            _responseMessage = 'Unexpected response format';
            _gradesData = [];
          });
        }
      } else {
        setState(() {
          _responseMessage = 'Failed to load data';
          _gradesData = [];
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
        _gradesData = [];
      });
    } finally {
      setState(() => _isFetching = false);
    }
  }

  List<dynamic> _getSortedData() {
    List<dynamic> sorted = List.from(_gradesData);
    sorted.sort((a, b) {
      int idA = int.tryParse(a['id'].toString()) ?? 0;
      int idB = int.tryParse(b['id'].toString()) ?? 0;
      return _sortOrder == 'oldest' ? idA.compareTo(idB) : idB.compareTo(idA);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        title: const Text(
          'API Insert & Fetch',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isFetching ? null : _fetchData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isConnectedToInternet ? Icons.wifi : Icons.wifi_off, // ✅ Use `Icons.wifi_off` not `Icon.wifi_off`
                    size: 50,
                    color: isConnectedToInternet ? Colors.green : Colors.red,
                  ),
                  Text(isConnectedToInternet
                      ? "You are connected to the internet" 
                        : "You are not connected to net",
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_userIdController, 'User ID'),
                  const SizedBox(height: 12),
                  _buildDropdown(_selectedCourseName, 'Course Name', _courseNames, (val) {
                    setState(() => _selectedCourseName = val);
                  }),
                  const SizedBox(height: 12),
                  _buildDropdown(_selectedSemester, 'Semester No', _semesterOptions, (val) {
                    setState(() => _selectedSemester = val);
                  }),
                  const SizedBox(height: 12),
                  _buildDropdown(_selectedCreditHours, 'Credit Hours', _creditHourOptions, (val) {
                    setState(() => _selectedCreditHours = val);
                  }),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _marksController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Marks (0-100)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter marks';
                      final marks = int.tryParse(value);
                      if (marks == null || marks < 0 || marks > 100) {
                        return 'Marks must be between 0 and 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitData,
                    icon: const Icon(Icons.send),
                    label: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isFetching ? null : _fetchData,
              icon: const Icon(Icons.cloud_download),
              label: _isFetching
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Load Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_responseMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green[700] : Colors.red[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _responseMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sort by:', style: TextStyle(color: Colors.white)),
                DropdownButton<String>(
                  dropdownColor: Colors.grey[900],
                  value: _sortOrder,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => setState(() => _sortOrder = val!),
                  items: const [
                    DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                    DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _gradesData.isEmpty
                ? const Text('No data loaded yet.', style: TextStyle(color: Colors.white))
                : Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 14,
                  headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  dataTextStyle: const TextStyle(color: Colors.white),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('User ID')),
                    DataColumn(label: Text('Course')),
                    DataColumn(label: Text('Sem')),
                    DataColumn(label: Text('CH')),
                    DataColumn(label: Text('Marks')),
                  ],
                  rows: _getSortedData().map((row) {
                    return DataRow(cells: [
                      DataCell(Text(row['id'].toString())),
                      DataCell(Text(row['user_id'].toString())),
                      DataCell(Text(row['course_name'].toString())),
                      DataCell(Text(row['semester_no'].toString())),
                      DataCell(Text(row['credit_hours'].toString())),
                      DataCell(Text(row['marks'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
      validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
    );
  }

  Widget _buildDropdown(String? value, String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label),
      dropdownColor: Colors.grey[900],
      style: const TextStyle(color: Colors.white),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select $label' : null,
    );
  }
}
