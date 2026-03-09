import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/address_entity.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _streetController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _confirm(BuildContext context, String userName) {
    if (_formKey.currentState!.validate()) {
      final address = AddressEntity(
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
      );
      Navigator.of(context).pop(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'ĐỊA CHỈ GIAO HÀNG',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            // Người nhận (read-only from Auth)
            _buildReadOnlyField(label: 'Người nhận', value: userName),
            const SizedBox(height: 16),

            // Số điện thoại
            _buildField(
              controller: _phoneController,
              label: 'Số điện thoại *',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (!RegExp(r'^0\d{9}$').hasMatch(value.trim())) {
                  return 'SĐT phải có 10 số và bắt đầu bằng 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Địa chỉ cụ thể
            _buildField(
              controller: _streetController,
              label: 'Địa chỉ cụ thể *',
              hint: 'Số nhà, tên đường',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập địa chỉ cụ thể'
                  : null,
            ),
            const SizedBox(height: 16),

            // Quận / Huyện
            _buildField(
              controller: _districtController,
              label: 'Quận / Huyện *',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập Quận/Huyện'
                  : null,
            ),
            const SizedBox(height: 16),

            // Tỉnh / Thành phố
            _buildField(
              controller: _cityController,
              label: 'Tỉnh / Thành phố *',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập Tỉnh/TP'
                  : null,
            ),
            const SizedBox(height: 40),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _confirm(context, userName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'XÁC NHẬN ĐỊA CHỈ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.black),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
