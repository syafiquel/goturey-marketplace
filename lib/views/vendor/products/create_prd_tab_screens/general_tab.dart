import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goturey_marketplace/views/widgets/loading_widget.dart';
import '../../../../constants/color.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../providers/product.dart';
import '../../../../resources/styles_manager.dart';
import '../../../widgets/message_alert.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'dart:io'; // Import for File
import 'add_variant_modal.dart'; // Import the new modal

import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/foundation.dart'; // Import for kIsWeb

// ignore: must_be_immutable
class GeneralTab extends StatefulWidget {
  GeneralTab({
    Key? key,
    this.showAlert = false,
  }) : super(key: key);
  bool showAlert;

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final formKey = GlobalKey<FormState>();
  final productName = TextEditingController();
  final productPriceAdult = TextEditingController(); // Renamed from productPrice
  final productDescription = TextEditingController();
  final variantStock = TextEditingController(); // Renamed from productQuantity

  // New controllers for Node.js structure
  final productCategory = TextEditingController(); // Using a text field for category now

  List<XFile> _featureImages = []; // To store selected feature images
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _variants = []; // To store product variants

  DateTime selectedDate = DateTime.now(); // Keep for now, but not used in Node.js structure
  bool isDateSelected = false;

  List<String> _categories = []; // To store fetched categories
  String? _selectedCategory; // To store the selected category
  bool _isFetchingCategories = true; // To manage loading state for categories

  bool isLoading = false;

  bool dateSelected = false;

  // Fetch categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('categories').get();
      final fetchedCategories = querySnapshot.docs.map((doc) => doc['category'] as String).toList();
      setState(() {
        _categories = fetchedCategories;
        _isFetchingCategories = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isFetchingCategories = false;
      });
    }
  }

  // pick date
  Future pickDate() async {
    var pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        isDateSelected = true;
        selectedDate = pickedDate;
      });
    }
  }

  // Method to pick multiple feature images
  Future<void> _pickFeatureImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _featureImages.addAll(selectedImages);
      });
    }
  }

  // showInstruction
  showInstruction() {
    messageDialog(
      title: 'Instructions',
      content:
          'After filling every detail you want on each product detail tab, click the save button so that it can be saved for you.',
      context: context,
    );
  }

  // Method to show add variant modal
  Future<void> _showAddVariantModal() async {
    final newVariant = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddVariantModal(),
    );

    if (newVariant != null) {
      setState(() {
        _variants.add(newVariant);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories on init

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showAlert) {
        Future.delayed(const Duration(seconds: 2), showInstruction());
        setState(() {
          widget.showAlert = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final productProvider = Provider.of<ProductData>(context);
    final user = FirebaseAuth.instance.currentUser; // Get current user

    // submit data
    Future<void> submitData() async {
      var valid = formKey.currentState!.validate();

      if (!valid) {
        return;
      }

      if (user == null) {
        // Handle case where user is not logged in
        messageDialog(
          title: 'Authentication Error',
          content: 'You must be logged in to create a product.',
          context: context,
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        await productProvider.updateProductGeneralData(
          productName: productName.text.trim(),
          category: _selectedCategory, // Use the selected category
          description: productDescription.text.trim(),
          featureImages: _featureImages, // Pass the list of XFile
          variants: _variants, // Pass the list of variants
          vendorId: user.uid, // Use the authenticated user's UID
          // scheduleDate: selectedDate, // Not part of Node.js structure
        );

        productProvider.updateProductGeneralInfoState();
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    // Save product data to Firestore
    Future<void> _saveProductToFirestore(Map<String, dynamic> productData) async {
      final category = productData['category'];
      debugPrint('[_saveProductToFirestore] Attempting to save product for category: $category');
      debugPrint('[_saveProductToFirestore] Product data to save: $productData');

      if (category == null || category.isEmpty) {
        messageDialog(
          title: 'Error',
          content: 'Product category is missing, cannot save product.',
          context: context,
        );
        debugPrint('[_saveProductToFirestore] Error: Product category is missing.');
        return;
      }

      // Save the product as a new document in the 'products' collection
      final productRef = FirebaseFirestore.instance.collection('products').doc(productData['category']);

      try {
        await productRef.set(productData); // Set the entire productData as the document
        debugPrint('[_saveProductToFirestore] Product document set with ID: ${productData['productId']} and data: $productData');

        messageDialog(
          title: 'Success',
          content: 'Product saved successfully to Firestore!',
          context: context,
        );
        debugPrint('[_saveProductToFirestore] Product saved successfully.');
      } catch (e) {
        debugPrint('[_saveProductToFirestore] Error saving product to Firestore: $e');
        messageDialog(
          title: 'Error',
          content: 'Failed to save product to Firestore: $e',
          context: context,
        );
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await submitData();
          if (!isLoading && formKey.currentState!.validate()) { // Only save to Firestore if form is valid and not loading
            await _saveProductToFirestore(productProvider.productData);
          }
        },
        child: const Icon(
          Icons.save,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18.0,
          vertical: 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: !isLoading
                ? Column(
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: productName,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Product name can not be empty';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter product name',
                          labelText: 'Product Name',
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isFetchingCategories
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              hint: const Text('Select Product Category'),
                              decoration: const InputDecoration(
                                labelText: 'Product Category',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            ),
                      const SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        maxLines: 7,
                        maxLength: 500,
                        controller: productDescription,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Product description can not be empty';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter product description',
                          labelText: 'Product Description',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Feature Image Upload Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Feature Images',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _pickFeatureImages,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Add Feature Images'),
                      ),
                      if (_featureImages.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: _featureImages.length,
                          itemBuilder: (context, index) {
                            return kIsWeb
                                ? Image.network(
                                    _featureImages[index].path, // XFile path is a blob URL on web
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_featureImages[index].path),
                                    fit: BoxFit.cover,
                                  );
                          },
                        ),
                      const SizedBox(height: 20),
                      // Variants Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Product Variants',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _showAddVariantModal,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Variant'),
                      ),
                      if (_variants.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _variants.length,
                          itemBuilder: (context, index) {
                            final variant = _variants[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(variant['name']),
                                subtitle: Text('Type: ${variant['type']}, Stock: ${variant['stock']}, Price Adult: ${variant['priceAdult']}, Price Child: ${variant['priceChild']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _variants.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 5),

                      // schedule.... (keeping for now, but not used in submitData)
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     TextButton(
                      //       onPressed: () => pickDate(),
                      //       child: Text(
                      //         'Schedule date',
                      //         style: getRegularStyle(color: accentColor),
                      //       ),
                      //     ),
                      //     isDateSelected
                      //         ? Text(
                      //             'Selected Date:  ${intl.DateFormat.yMMMEd().format(selectedDate)}',
                      //             style: const TextStyle(
                      //               fontWeight: FontWeight.w700,
                      //             ),
                      //           )
                      //         : const SizedBox.shrink(),
                      //   ],
                      // ),
                    ],
                  )
                : const Center(
                    child: LoadingWidget(size: 50),
                  ),
          ),
        ),
      ),
      bottomSheet: productProvider.isProductGeneralInfoSubmittedStatus
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Saved general details successfully',
                    style: getRegularStyle(color: accentColor),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.check_circle_outline,
                    color: accentColor,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
