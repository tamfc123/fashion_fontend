import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/product_input_entity.dart';
import '../../domain/entities/variant_input_entity.dart';
import '../bloc/add_product_bloc.dart';
import '../bloc/add_product_event.dart';
import '../bloc/add_product_state.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _VariantFormState {
  final TextEditingController colorController;
  final TextEditingController sizeController;
  final TextEditingController priceController;
  final TextEditingController stockController;

  _VariantFormState({
    required this.colorController,
    required this.sizeController,
    required this.priceController,
    required this.stockController,
  });

  void dispose() {
    colorController.dispose();
    sizeController.dispose();
    priceController.dispose();
    stockController.dispose();
  }
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();

  // List of controllers for dynamic variants
  final List<_VariantFormState> _variants = [];

  // List to hold selected image files
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (_selectedImages.length >= 5) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Tối đa 5 ảnh được phép chọn.')),
      );
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80, // Compress to save bandwidth
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var file in pickedFiles) {
            if (_selectedImages.length < 5) {
              _selectedImages.add(File(file.path));
            }
          }
        });
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    // Start with one variant by default
    _addVariant();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    for (var variant in _variants) {
      variant.dispose();
    }
    super.dispose();
  }

  void _addVariant() {
    setState(() {
      _variants.add(
        _VariantFormState(
          colorController: TextEditingController(),
          sizeController: TextEditingController(),
          priceController: TextEditingController(),
          stockController: TextEditingController(),
        ),
      );
    });
  }

  void _removeVariant(int index) {
    if (_variants.length > 1) {
      setState(() {
        final variant = _variants.removeAt(index);
        variant.dispose(); // Prevent memory leak
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần ít nhất 1 phân loại sản phẩm')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_variants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng thêm ít nhất một phân loại.')),
        );
        return;
      }

      // Read bloc reference before async gap if any, although here it's sync
      final addProductBloc = context.read<AddProductBloc>();

      final variantInputs = _variants.map((v) {
        return VariantInputEntity(
          color: v.colorController.text.trim(),
          size: v.sizeController.text.trim(),
          price: double.parse(v.priceController.text.trim()),
          stock: int.parse(v.stockController.text.trim()),
        );
      }).toList();

      final productInput = ProductInputEntity(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _categoryController.text.trim(),
        imageFiles: _selectedImages.isNotEmpty ? _selectedImages : null,
        variants: variantInputs,
      );

      // Fire event to Bloc
      addProductBloc.add(AddProductSubmitted(productInput));
    }
  }

  // UI Builder specifically for Variants to keep `build` clean
  Widget _buildVariantItem(
    int index,
    _VariantFormState variant,
    bool isLoading,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phân loại #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: isLoading ? null : () => _removeVariant(index),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: variant.colorController,
                    decoration: const InputDecoration(
                      labelText: 'Màu sắc (tuỳ chọn)',
                    ),
                    enabled: !isLoading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: variant.sizeController.text.isEmpty
                        ? null
                        : variant.sizeController.text,
                    decoration: const InputDecoration(labelText: 'Kích cỡ *'),
                    items: const [
                      DropdownMenuItem(value: 'XS', child: Text('XS')),
                      DropdownMenuItem(value: 'S', child: Text('S')),
                      DropdownMenuItem(value: 'M', child: Text('M')),
                      DropdownMenuItem(value: 'L', child: Text('L')),
                      DropdownMenuItem(value: 'XL', child: Text('XL')),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              variant.sizeController.text = value;
                            }
                          },
                    validator: (value) =>
                        value == null ? 'Bắt buộc chọn' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: variant.priceController,
                    decoration: const InputDecoration(labelText: 'Giá bán *'),
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bắt buộc nhập';
                      }
                      if ((double.tryParse(value) ?? -1) < 0) {
                        return 'Giá phải >= 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: variant.stockController,
                    decoration: const InputDecoration(labelText: 'Tồn kho *'),
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bắt buộc nhập';
                      }
                      if ((int.tryParse(value) ?? -1) < 0) {
                        return 'Tồn kho >= 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Sản Phẩm Mới')),
      body: BlocConsumer<AddProductBloc, AddProductState>(
        listener: (context, state) {
          if (state is AddProductSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thêm sản phẩm thành công! 🎉')),
            );
            Navigator.of(context).pop();
          } else if (state is AddProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AddProductLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'THÔNG TIN CƠ BẢN',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isLoading,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Bắt buộc nhập' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  enabled: !isLoading,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Bắt buộc nhập' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _categoryController.text.isEmpty
                      ? null
                      : _categoryController.text,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'SHIRT', child: Text('Áo (SHIRT)')),
                    DropdownMenuItem(
                      value: 'PANTS',
                      child: Text('Quần (PANTS)'),
                    ),
                    DropdownMenuItem(
                      value: 'HOODIE',
                      child: Text('Hoodie (HOODIE)'),
                    ),
                    DropdownMenuItem(
                      value: 'DRESS',
                      child: Text('Váy (DRESS)'),
                    ),
                    DropdownMenuItem(
                      value: 'JACKET',
                      child: Text('Áo khoác (JACKET)'),
                    ),
                  ],
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            _categoryController.text = value;
                          }
                        },
                  validator: (value) => value == null ? 'Bắt buộc chọn' : null,
                ),
                const SizedBox(height: 32),

                // --- Image Picker Section ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HÌNH ẢNH SẢN PHẨM',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: isLoading ? null : _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Thêm ảnh'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8, top: 8),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        style: BorderStyle.solid,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Chưa chọn ảnh (Tối đa 5)'),
                  ),
                const SizedBox(height: 32),

                // --- End Image Picker Section ---
                const Text(
                  'PHÂN LOẠI SẢN PHẨM',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._variants.asMap().entries.map((entry) {
                  return _buildVariantItem(entry.key, entry.value, isLoading);
                }),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _addVariant,
                  icon: const Icon(Icons.add),
                  label: const Text('+ Thêm phân loại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ĐĂNG SẢN PHẨM',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
