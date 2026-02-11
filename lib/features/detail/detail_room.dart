import 'package:flutter/material.dart';
import 'add_new_device.dart';

class HomeOfficePage extends StatefulWidget {
  const HomeOfficePage({super.key});

  @override
  State<HomeOfficePage> createState() => _HomeOfficePageState();
}

class _HomeOfficePageState extends State<HomeOfficePage> {
  TimeOfDay startTime = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 6, minute: 0);
  bool _isEditingTitle = false;
  late TextEditingController _titleController;
  String roomTitle = "Home Office";
  String selectedDevice = "Air Conditioner";

  final Map<String, bool> days = {
    "Sunday": false,
    "Monday": false,
    "Tuesday": false,
    "Wednesday": false,
    "Thursday": false,
    "Friday": false,
    "Saturday": false,
  };

  final TextEditingController energyController =
  TextEditingController(text: "20");

  double energyUsage = 20.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: roomTitle);
  }

  @override
  void dispose() {
    energyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _saveTitle() {
    setState(() {
      roomTitle = _titleController.text.trim().isEmpty
          ? roomTitle
          : _titleController.text.trim();
      _isEditingTitle = false;
    });
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
                  _mainCard(),
                  const SizedBox(height: 16),
                  _saveButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ================= HEADER =================
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
                onPressed: () {
                  if (_isEditingTitle) {
                    _saveTitle();
                  } else {
                    setState(() {
                      _isEditingTitle = true;
                    });
                  }
                },
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddNewDevicePage(),
          ),
        );
      },
    );
  }

  // ================= DEVICE TABS =================
  Widget _deviceTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        children: [
          _addDeviceChip(),
          _chip("Lamp"),
          _chip("Air Conditioner"),
          _chip("CCTV"),
          _chip("Computer"),
          _chip("Speaker"),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    final isActive = selectedDevice == label;

    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      selectedColor: Colors.blue[700],
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.black,
      ),
      onSelected: (_) {
        if (label == "+") return;
        setState(() => selectedDevice = label);
      },
    );
  }

  // ================= MAIN CARD =================
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
                  children: days.keys.map((day) {
                    return SizedBox(
                      width: itemWidth,
                      child: Row(
                        children: [
                          Checkbox(
                            value: days[day],
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              setState(() => days[day] = val!);
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

  // ================= TIME BOX =================
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

  // ================= SAVE BUTTON =================
  Widget _saveButton() {
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
          onPressed: () {},
          child: const Text(
            "Save",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ================= DECORATIONS =================
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
