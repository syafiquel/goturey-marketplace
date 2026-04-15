import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingOption {
  final String label;
  final int hours;
  final bool usePerEntry;

  const BookingOption({
    required this.label,
    required this.hours,
    this.usePerEntry = false,
  });
}

class ParkingBookingResult {
  final DateTime date;
  final BookingOption option;

  ParkingBookingResult({
    required this.date,
    required this.option,
  });
}

class ParkingBookingScreen extends StatefulWidget {
  const ParkingBookingScreen({
    super.key,
    this.initialDate,
    this.initialOption,
  });

  final DateTime? initialDate;
  final BookingOption? initialOption;

  @override
  State<ParkingBookingScreen> createState() => _ParkingBookingScreenState();
}

class _ParkingBookingScreenState extends State<ParkingBookingScreen> {
  static const List<BookingOption> _bookingOptions = [
    BookingOption(label: '1 Hour', hours: 1),
    BookingOption(label: '2 Hours', hours: 2),
    BookingOption(label: '3 Hours', hours: 3),
    BookingOption(label: '4 Hours', hours: 4),
    BookingOption(label: '5 Hours', hours: 5),
    BookingOption(label: 'One Day', hours: 24, usePerEntry: true),
  ];

  late DateTime _selectedDate;
  late BookingOption _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedOption = widget.initialOption ?? _bookingOptions.first;
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  void _onOptionSelected(BookingOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  void _confirmSelection() {
    Navigator.of(context).pop(
      ParkingBookingResult(
        date: _selectedDate,
        option: _selectedOption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEE, d MMM yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Booking Date'),
        backgroundColor: const Color(0xFFef2b7c),
      ),
      backgroundColor: const Color(0xFFF8F5FF),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CalendarDatePicker(
              currentDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDate: _selectedDate,
              onDateChanged: _onDateChanged,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Duration',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _bookingOptions.map(
                (option) {
                  final isSelected = option.label == _selectedOption.label;
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: isSelected,
                    onSelected: (_) => _onOptionSelected(option),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFef2b7c),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade400,
                    ),
                  );
                },
              ).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _confirmSelection,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}

