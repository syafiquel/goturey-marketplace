import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import for kIsWeb

class AddVariantModal extends StatefulWidget {
  const AddVariantModal({Key? key}) : super(key: key);

  @override
  State<AddVariantModal> createState() => _AddVariantModalState();
}

class _AddVariantModalState extends State<AddVariantModal> {
  final _formKey = GlobalKey<FormState>();
  final _variantNameController = TextEditingController();
  final _variantStockController = TextEditingController();
  // final _variantTypeController = TextEditingController(); // No longer needed
  final _priceAdultController = TextEditingController();
  final _priceChildController = TextEditingController();

  String? _selectedVariantType; // New state variable for dropdown

  XFile? _variantImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVariantImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _variantImage = image;
    });
  }

  void _submitVariant() {
    if (_formKey.currentState!.validate()) {
      if (_variantImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image for the variant')),
        );
        return;
      }
      if (_selectedVariantType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a variant type')),
        );
        return;
      }

      Navigator.of(context).pop({
        'name': _variantNameController.text.trim(),
        'stock': int.parse(_variantStockController.text.trim()),
        'type': _selectedVariantType, // Use the selected value
        'priceAdult': double.parse(_priceAdultController.text.trim()),
        'priceChild': double.parse(_priceChildController.text.trim()),
        'image': _variantImage, // Pass the XFile object
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Variant'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _variantNameController,
                decoration: const InputDecoration(labelText: 'Variant Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter variant name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _variantStockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedVariantType,
                hint: const Text('Select Variant Type'),
                decoration: const InputDecoration(
                  labelText: 'Variant Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'malaysian', child: Text('Malaysian')),
                  DropdownMenuItem(value: 'international', child: Text('International')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedVariantType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a variant type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceAdultController,
                decoration: const InputDecoration(labelText: 'Price (Adult)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter adult price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceChildController,
                decoration: const InputDecoration(labelText: 'Price (Child)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickVariantImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Variant Image'),
              ),
              if (_variantImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: kIsWeb
                      ? Image.network(
                          _variantImage!.path, // XFile path is a blob URL on web
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_variantImage!.path),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitVariant,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
