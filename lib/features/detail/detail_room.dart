import 'package:flutter/material.dart';
import 'apiclient.dart';

class HomeOfficePage extends StatefulWidget {
  final String roomId;
  final String roomName;

  const HomeOfficePage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<HomeOfficePage> createState() => _HomeOfficePageState();
}
class Item {
  final String id;
  final String name;
  final List<String> usageDays;
  final String startTime;
  final String endTime;
  final int usageWatt;
  bool isLocal;

  Item({
    required this.id,
    required this.name,
    required this.usageDays,
    required this.startTime,
    required this.endTime,
    required this.usageWatt,
    this.isLocal = false,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['item_id'],
      name: json['name'],
      usageDays: List<String>.from(json['usage_days']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      usageWatt: (json['usage_watt'] as num).toInt(),
    );
  }
}

class _HomeOfficePageState extends State<HomeOfficePage> {
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 0, minute: 0);
  bool _isEditingTitle = false;
  late TextEditingController _titleController;
  late String roomTitle;
  String selectedDevice = "";
  bool isSaving = false;
  final Map<String, bool> days = {
    "Sunday": false,
    "Monday": false,
    "Tuesday": false,
    "Wednesday": false,
    "Thursday": false,
    "Friday": false,
    "Saturday": false,
    "Every day": false,
  };

  final dayList = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Every day",
  ];


  List<Item> items = [];
  bool isLoading = true;

  final TextEditingController energyController =
  TextEditingController(text: "0");

  double energyUsage = 0.0;

  @override
  void initState() {
    super.initState();
    roomTitle = widget.roomName;
    _titleController = TextEditingController(text: roomTitle);
    fetchItems();
  }

  void _loadItemToUI(Item item) {
    selectedDevice = item.id;

    energyUsage = item.usageWatt.toDouble();
    energyController.text = item.usageWatt.toString();

    final start = item.startTime.split(":");
    startTime = TimeOfDay(
      hour: int.parse(start[0]),
      minute: int.parse(start[1]),
    );

    final end = item.endTime.split(":");
    endTime = TimeOfDay(
      hour: int.parse(end[0]),
      minute: int.parse(end[1]),
    );

    for (var key in days.keys) {
      days[key] = false;
    }

    for (var day in item.usageDays) {
      final formatted =
          day[0].toUpperCase() + day.substring(1).toLowerCase();
      if (days.containsKey(formatted)) {
        days[formatted] = true;
      }
    }

    final allChecked = days.entries
        .where((e) => e.key != "Every day")
        .every((e) => e.value);

    days["Every day"] = allChecked;
  }

  Future<void> fetchItems() async {
    try {
      final res = await ApiClient.dio
          .get('/rooms/${widget.roomId}/items');

      debugPrint("ROOM ID GET: ${widget.roomId}");
      debugPrint("ITEM STATUS: ${res.statusCode}");
      debugPrint("ITEM DATA: ${res.data}");
      final data = res.data as List;

      setState(() {
        items = data.map((e) => Item.fromJson(e)).toList();
        if (items.isNotEmpty) {
          _loadItemToUI(items.first);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("ITEM ERROR: $e");
    }
  }

  @override
  void dispose() {
    energyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveTitle() async {
    final newTitle = _titleController.text.trim();
    if (newTitle.isEmpty) return;

    try {
      final res = await ApiClient.dio.patch(
        '/rooms/${widget.roomId}',
        data: {"name": newTitle},
      );

      debugPrint("STATUS: ${res.statusCode}");
      debugPrint("DATA: ${res.data}");

      if (!mounted) return;

      setState(() {
        roomTitle = newTitle;
        _isEditingTitle = false;
      });

    } catch (e) {
      debugPrint("ERROR PATCH: $e");
    }
  }

  void _showAddDeviceDialog() {
    final TextEditingController deviceController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Device"),
          content: TextField(
            controller: deviceController,
            decoration:
            const InputDecoration(labelText: "Device name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newDevice = deviceController.text.trim();
                if (newDevice.isEmpty) return;

                final tempItem = Item(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: newDevice,
                  usageDays: [],
                  startTime: "${startTime.hour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}:00",
                  endTime: "${endTime.hour.toString().padLeft(2,'0')}:${endTime.minute.toString().padLeft(2,'0')}:00",
                  usageWatt: 0,
                  isLocal: true,
                );

                setState(() {
                  items.add(tempItem);
                  selectedDevice = tempItem.id;

                  startTime = const TimeOfDay(hour: 0, minute: 0);
                  endTime = const TimeOfDay(hour: 0, minute: 0);
                  energyUsage = 0;
                  energyController.text = "0";

                  for (var key in days.keys) {
                    days[key] = false;
                  }
                });

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }


  Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: Colors.white,
              hourMinuteTextColor: Colors.black,
              dialHandColor: const Color(0xFFF2B599C),
              dialBackgroundColor: Colors.white,
              entryModeIconColor: Colors.blue,
              dayPeriodColor: Colors.blue.shade100,
              dayPeriodTextColor: Colors.blue.shade900,
            ),
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFF2B599C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      if (isStart) {
        startTime = picked;
      } else {
        endTime = picked;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: Column(
        children: [
          _header(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _deviceTabs(),
                  const SizedBox(height: 12),

                  if (items.isNotEmpty && selectedDevice.isNotEmpty) ...[
                    _mainCard(),
                    const SizedBox(height: 16),
                    _saveButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Stack(
      children: [
        Image.asset(
          "assets/images/home_office.jpg",
          height: 230,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 40,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: _isEditingTitle
                    ? TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _saveTitle(),
                )
                    : Text(
                  roomTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                icon: Icon(
                  _isEditingTitle ? Icons.check : Icons.edit,
                  color: Colors.white,
                ),
                  onPressed: () async {
                    if (_isEditingTitle) {
                      await _saveTitle();
                    } else {
                      setState(() {
                        _isEditingTitle = true;
                      });
                    }
                  }
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _addDeviceChip() {
    return ActionChip(
      avatar: const Icon(Icons.add, size: 18),
      label: const Text(""),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onPressed: () {
        _showAddDeviceDialog();
      },
    );
  }

  Widget _deviceTabs() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          _addDeviceChip(),
          ...items.map((item) => _chip(item)).toList(),
        ],
      ),
    );
  }

  Widget _chip(Item item) {
    final isActive = selectedDevice == item.id;

    return ChoiceChip(
      label: Text(item.name),
      selected: isActive,
      showCheckmark: false,
      selectedColor: Colors.blue[700],
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.black,
      ),
        onSelected: (_) {
          final selectedItem =
          items.firstWhere((e) => e.id == item.id);

          setState(() {
            _loadItemToUI(selectedItem);
          });
        }
    );
  }

  Widget _mainCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _outerCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Schedule",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _timeBox(
                  "Start Time",
                  startTime.format(context),
                      () => pickTime(true),
                ),
                const SizedBox(width: 12),
                _timeBox(
                  "End Time",
                  endTime.format(context),
                      () => pickTime(false),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Usage Days",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: dayList.map((day) {
                    return SizedBox(
                      width: itemWidth,
                      child: Row(
                        children: [
                          Checkbox(
                            value: days[day],
                            activeColor: const Color(0xFF2B599C),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              setState(() {
                                days[day] = val!;

                                if (day == "Every day") {
                                  for (var key in days.keys) {
                                    days[key] = val;
                                  }
                                } else {
                                  final allChecked = days.entries
                                      .where((e) => e.key != "Every day")
                                      .every((e) => e.value == true);

                                  days["Every day"] = allChecked;
                                }
                              });
                            },

                          ),
                          Expanded(
                            child: Text(
                              day,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              "Energy Usage",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: _innerCardDecoration(),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Energy Usage"),
                        Text(
                          "Update manually",
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: energyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        suffixText: " Watt",
                        suffixStyle: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          energyUsage = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBox(String title, String time, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: _innerCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveButton() {
    final item = items.firstWhere((e) => e.id == selectedDevice);

    final isUpdate = !item.isLocal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: isSaving
              ? null
              : () async {
            setState(() => isSaving = true);

            try {
              if (item.isLocal) {
                await ApiClient.dio.post(
                  '/rooms/${widget.roomId}/items',
                  data: {
                    "name": item.name,
                    "usage_days": days.entries
                        .where((e) =>
                    e.value && e.key != "Every day")
                        .map((e) => e.key.toLowerCase())
                        .toList(),
                    "start_time":
                    "${startTime.hour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}",
                    "end_time":
                    "${endTime.hour.toString().padLeft(2,'0')}:${endTime.minute.toString().padLeft(2,'0')}",
                    "usage_watt": energyUsage.toInt(),
                  },
                );
              } else {
                await ApiClient.dio.patch(
                  '/rooms/${widget.roomId}/items/${item.id}',
                  data: {
                    "usage_days": days.entries
                        .where((e) =>
                    e.value && e.key != "Every day")
                        .map((e) => e.key.toLowerCase())
                        .toList(),
                    "start_time":
                    "${startTime.hour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}",
                    "end_time":
                    "${endTime.hour.toString().padLeft(2,'0')}:${endTime.minute.toString().padLeft(2,'0')}",
                    "usage_watt": energyUsage.toInt(),
                  },
                );
              }

              await fetchItems();
            } finally {
              if (mounted) {
                setState(() => isSaving = false);
              }
            }
          },
          child: isSaving
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text(
            isUpdate ? "Update Schedule" : "Save",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _outerCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  BoxDecoration _innerCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
