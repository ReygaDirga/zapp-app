import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zapp/features/detail/apiclient.dart';
import 'package:zapp/features/models/usage_item.dart';
import 'package:zapp/features/models/room.dart';
enum DateMode { day, month, year }

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});

  @override
  State<SimulationPage> createState() => _SimulationState();
}

class _SimulationState extends State<SimulationPage> {
  final TextEditingController _roomNameController = TextEditingController();
  DateMode _mode = DateMode.day;
  late DateTime _selectedDate;

  int get _currentYear => DateTime.now().year;
  late int _yearPageStart;
  static const int _yearPageSize = 12;

  double totalWatt = 0;
  double totalCost = 0;

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  final numberFormatter = NumberFormat('#,###', 'id_ID');

  String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

  List<UsageItem> itemList = [];
  bool isLoading = false;
  Future<void> fetchUsage() async {
    try {
      setState(() {
        isLoading = true;
        itemList = [];
        totalCost = 0;
        totalWatt = 0;
      });

      final Map<String, dynamic> query = {
        "mode": "simulation",
        "range": _mode.name,
        "date": _selectedDate.toIso8601String().split('T').first,
      };

      if (selectedRoom != null) {
        query["roomId"] = selectedRoom;
      }

      final response = await ApiClient.dio.get(
        '/usage',
        queryParameters: query,
      );

      final Map<String, dynamic> json = response.data;

      final List rooms = json["rooms"] ?? [];

      final double fetchedTotalWatt = (json["totalWatt"] ?? 0).toDouble();
      final double fetchedTotalCost = (json["totalCost"] ?? 0).toDouble();

      List<UsageItem> allItems = [];

      for (var room in rooms) {
        final List items = room["items"] ?? [];
        allItems.addAll(
          items.map((e) => UsageItem.fromJson(e)).toList(),
        );
      }

      setState(() {
        itemList = allItems;
        totalWatt = fetchedTotalWatt;
        totalCost = fetchedTotalCost;
      });
    } catch (e) {
      print(e);

      setState(() {
        itemList = [];
        totalCost = 0;
        totalWatt = 0;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Room> roomList = [];
  String? selectedRoom;
  bool isRoomLoading = false;
  Future<void> fetchRooms() async {
  try {
    setState(() => isRoomLoading = true);

    final response = await ApiClient.dio.get('/rooms');

    final data = response.data as List;

    setState(() {
      roomList = data.map((e) => Room.fromJson(e)).toList();
    });
  } catch (e) {
      print(e);
  } finally {
    setState(() => isRoomLoading = false);
  }
}

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = now;
    _yearPageStart = now.year - (_yearPageSize ~/ 2);

    fetchRooms();
    fetchUsage();
  }

  Widget _segmentedButton() {
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF053886),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: DateMode.values.map((mode) {
          final isActive = mode == _mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _mode = mode;
                });
                fetchUsage();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _label(mode),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                    isActive ? const Color(0xFF053886) : Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(DateMode mode) {
    switch (mode) {
      case DateMode.day:
        return 'Day';
      case DateMode.month:
        return 'Monthly';
      case DateMode.year:
        return 'Year';
    }
  }

  Widget _buildPicker() {
    switch (_mode) {
      case DateMode.day:
        return Column(
          children: [
            _dayPicker(),
            const SizedBox(height: 25),
          ],
        );
      case DateMode.month:
        return Column(
          children: [
            _monthPicker(),
            const SizedBox(height: 25),
          ],
        );
      case DateMode.year:
        return Column(
          children: [
            _yearPicker(),
            const SizedBox(height: 25),
          ],
        );
    }
  }

  DateTime _adjustDate(int year, int month, int currentDay) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    final safeDay = currentDay > daysInMonth
        ? daysInMonth
        : currentDay;

    return DateTime(year, month, safeDay);
  }

  void _syncYearPage() {
    final selectedYear = _selectedDate.year;

    if (selectedYear < _yearPageStart ||
        selectedYear >= _yearPageStart + _yearPageSize) {
      _yearPageStart =
          selectedYear - (selectedYear % _yearPageSize);
    }
  }

  Widget _dayPicker() {
    final now = DateTime.now();
    final year = _selectedDate.year;
    final month = _selectedDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth =
    DateUtils.getDaysInMonth(year, month);
    final startOffset = firstDayOfMonth.weekday % 7;
    final totalItems = startOffset + daysInMonth;
    final firstDayThisMonth = DateTime(now.year, now.month, 1);
    final currentMonth = DateTime(year, month, 1);

    final isPrevDisabled = currentMonth.isAtSameMomentAs(firstDayThisMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: '${_monthNames[month - 1]} $year',
          onPrev: isPrevDisabled
            ? () {}
            : () {
              final now = DateTime.now();

              final newMonth = _selectedDate.month - 1;
              final newYear = _selectedDate.year;

              DateTime newDate = _adjustDate(
                newYear,
                newMonth,
                _selectedDate.day,
              );

              if (newDate.isBefore(DateTime(now.year, now.month, now.day))) {
                newDate = DateTime(now.year, now.month, now.day);
              }

              setState(() {
                _selectedDate = newDate;
              });

              _syncYearPage();
              fetchUsage();
            },
          onNext: () {
            final newMonth = _selectedDate.month + 1;
            final newYear = _selectedDate.year;

            setState(() {
              _selectedDate = _adjustDate(
                newYear,
                newMonth,
                _selectedDate.day,
              );
            });

            _syncYearPage();
            fetchUsage();
          },
        ),
        const SizedBox(height: 8),
        _weekdayHeader(),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalItems,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (_, index) {
            if (index < startOffset) {
              return const SizedBox();
            }

            final day = index - startOffset + 1;

            final currentDate = DateTime.now();

            final candidateDate = DateTime(
              year,
              month,
              day,
            );

            final isDisabled = candidateDate.isBefore(
              DateTime(currentDate.year, currentDate.month, currentDate.day),
            );

            final isSelected =
                _selectedDate.year == year &&
                    _selectedDate.month == month &&
                    _selectedDate.day == day;

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isDisabled 
                ? null
                : () {
                  setState(() {
                    _selectedDate = _adjustDate(
                      year,
                      month,
                      day,
                    );
                  });
                  _syncYearPage();
                  fetchUsage();
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3F6EB4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : isDisabled ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _monthPicker() {
    final year = _selectedDate.year;
    final month = _selectedDate.month;
    final now = DateTime.now();

    return Column(
      children: [
        _header(
          title: '$year',
          onPrev: () {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final newYear = year - 1;

            if (newYear < now.year) return;

            DateTime newDate = _adjustDate(newYear, month, _selectedDate.day,);

            if (newDate.isBefore(today)) {
              newDate = today;
            }

            setState(() {
              _selectedDate = newDate;
            });
            _syncYearPage();
            fetchUsage();
          },
          onNext: () {
            setState(() {
              _selectedDate = _adjustDate(year + 1, month, _selectedDate.day,);
            });
            _syncYearPage();
            fetchUsage();
          },
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (_, i) {
            final month = i + 1;
            final isSelected = month == _selectedDate.month;

            final isDisabled =
                year < now.year || (year == now.year && month < now.month);

            return _pickerItem(
              label: _monthNames[i],
              isSelected: isSelected,
              isDisabled: isDisabled,
              onTap: () {
                if (isDisabled) return;

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                DateTime newDate = _adjustDate(year, month, _selectedDate.day);

                if (newDate.isBefore(today)) {
                  newDate = today;
                }

                setState(() {
                  _selectedDate = newDate;
                });
                _syncYearPage();
                fetchUsage();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _yearPicker() {
    final years = List.generate(
      _yearPageSize,
          (i) => _yearPageStart + i,
    );

    return Column(
      children: [
        _header(
          title: '${years.first} - ${years.last}',
          onPrev: () {
            final now = DateTime.now();
            if (_yearPageStart < now.year) return;

            final today = DateTime(now.year, now.month, now.day);
            final newYear = years.first - _yearPageSize;

            DateTime newDate = _adjustDate(newYear, _selectedDate.month, _selectedDate.day,);

            if (newDate.isBefore(today)) {
              newDate = today;
            }

            setState(() {
              _yearPageStart -= _yearPageSize;
              _selectedDate = newDate;
            });
            fetchUsage();
          },
          onNext: () {
            final now = DateTime.now();

            final today = DateTime(now.year, now.month, now.day);
            final newYear = years.first + _yearPageSize;

            DateTime newDate = _adjustDate(newYear, _selectedDate.month, _selectedDate.day,);

            if (newDate.isBefore(today)) {
              newDate = today;
            }
            setState(() {
              _yearPageStart += _yearPageSize;
              _selectedDate = newDate;
            });
            fetchUsage();
          },
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: years.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (_, i) {
            final year = years[i];
            final now = DateTime.now();
            final isSelected = year == _selectedDate.year;
            final isDisabled = year < now.year;

            return _pickerItem(
              label: year.toString(),
              isSelected: isSelected,
              isDisabled: isDisabled,
              onTap: () {
                if (isDisabled) return;

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                DateTime newDate = _adjustDate(year, _selectedDate.month, _selectedDate.day);

                if (newDate.isBefore(today)) {
                  newDate = today;
                }

                setState(() {
                  _selectedDate = newDate;
                });
                fetchUsage();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _pickerItem({
    required String label,
    required bool isSelected,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: isDisabled ? null : onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3F6EB4)
              : isDisabled
              ? Colors.grey.shade100
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF053886)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : isDisabled
                ? Colors.grey
                : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }


  Widget _header({
    required String title,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }

  Widget _weekdayHeader() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (d) => Expanded(
          child: Center(
            child: Text(
              d,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  Widget _simulationItem({
    required String title,
    required String days,
    required String start,
    required String end,
    required String watt,
    required String price,
    required Color wattColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              color: Colors.blue.shade700,
            ),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Usage days : $days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Start Time : $start',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'End Time   : $end',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Price   : $price',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            watt,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: wattColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printreport() async {
    try {
      setState(() {
        isLoading = true;
      });

      final Map<String, dynamic> query = {
        "mode": "simulation",
        "range": _mode.name,
        "date": _selectedDate.toIso8601String().split('T').first,
      };

      if (selectedRoom != null) {
        query["roomId"] = selectedRoom;
      }

      final response = await ApiClient.dio.get(
        '/usage/pdf',
        queryParameters: query,
        options: Options(responseType: ResponseType.bytes),
      );

      String filename = "report.pdf";

      final contentDisposition = 
        response.headers.value("content-disposition");

      if (contentDisposition != null) {
        final regex = RegExp(r'filename="?([^\";]+)"?');
        final match = regex.firstMatch(contentDisposition);
        if (match != null) {
          filename = match.group(1)!;
        }
      }
      filename = filename.replaceAll('"', '');
      if (!filename.toLowerCase().endsWith(".pdf")) {
        filename = "$filename.pdf";
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$filename");
      await file.writeAsBytes(response.data);

      await OpenFilex.open(file.path);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSimulationPopup() {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Simulation Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300),

                Flexible(
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : itemList.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child:
                                  Center(child: Text("No items found.")),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: itemList.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: Colors.grey.shade300),
                              itemBuilder: (_, index) {
                                final item = itemList[index];
                                return _simulationItem(
                                  title: item.name,
                                  days: item.usageDays.map((d) => capitalize(d)).join(', '),
                                  start: item.startTime,
                                  end: item.endTime,
                                  watt: '${item.usageWatt} watt',
                                  price: '${currencyFormatter.format(item.totalCost)}',
                                  wattColor: Colors.red,
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Room",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField2<String?>(
                value: selectedRoom,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('All')),
                  ...roomList.map((room) {
                    return DropdownMenuItem<String?>(value: room.roomId, child: Text(room.name));
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRoom = value;
                  });

                  fetchUsage();
                },
                dropdownStyleData: DropdownStyleData(
                  width: MediaQuery.of(context).size.width - 40,
                  maxHeight: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                "Select",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              _segmentedButton(),
              const SizedBox(height: 8),
              AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: _buildPicker()),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F6EB4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on, color: Colors.white),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Watt',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${numberFormatter.format(totalWatt)} Watt',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F6EB4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.white),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Cost',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                currencyFormatter.format(totalCost),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Simulation Activity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            isLoading ? null : _printreport();
                          },
                          child: Text(
                            'Print Report',
                            style: TextStyle(
                              fontSize: 12,
                              color: isLoading ? Colors.grey : Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _showSimulationPopup();
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),


                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300),
                    isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : itemList.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("No items found."),
                          )
                          : _simulationItem(
                            title: itemList.first.name,
                            days: itemList.first.usageDays.map((d) => capitalize(d)).join(', '),
                            start: itemList.first.startTime,
                            end: itemList.first.endTime,
                            watt: '${itemList.first.usageWatt} Watt',
                            price: '${currencyFormatter.format(itemList.first.totalCost)}',
                            wattColor: Colors.red,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
