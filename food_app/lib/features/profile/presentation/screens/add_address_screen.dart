import 'package:flutter/material.dart';

import '../../data/models/address_model.dart';
import '../../data/user_repository.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    super.key,
    required this.userRepository,
    this.initial,
  });

  final UserRepository userRepository;
  final AddressModel? initial;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalController = TextEditingController();
  bool _defaultAddress = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _labelController.text = i.label;
      _line1Controller.text = i.streetLine1;
      _line2Controller.text = i.streetLine2 ?? '';
      _cityController.text = i.city;
      _stateController.text = i.state;
      _postalController.text = i.postalCode;
      _defaultAddress = i.defaultAddress;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (widget.initial == null) {
        await widget.userRepository.addAddress(
          label: _labelController.text.trim(),
          streetLine1: _line1Controller.text.trim(),
          streetLine2: _line2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalController.text.trim(),
          defaultAddress: _defaultAddress,
        );
      } else {
        await widget.userRepository.updateAddress(
          addressId: widget.initial!.id,
          label: _labelController.text.trim(),
          streetLine1: _line1Controller.text.trim(),
          streetLine2: _line2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalController.text.trim(),
          defaultAddress: _defaultAddress,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initial == null ? 'Đã thêm địa chỉ' : 'Đã cập nhật địa chỉ',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Sửa địa chỉ' : 'Thêm địa chỉ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_labelController, 'Nhãn (Nhà/Công ty)'),
              const SizedBox(height: 10),
              _field(_line1Controller, 'Địa chỉ dòng 1'),
              const SizedBox(height: 10),
              _field(
                _line2Controller,
                'Địa chỉ dòng 2 (tuỳ chọn)',
                required: false,
              ),
              const SizedBox(height: 10),
              _field(_cityController, 'Thành phố'),
              const SizedBox(height: 10),
              _field(_stateController, 'Quận/Huyện/Tỉnh'),
              const SizedBox(height: 10),
              _field(_postalController, 'Mã bưu chính'),
              SwitchListTile(
                value: _defaultAddress,
                onChanged: (value) => setState(() => _defaultAddress = value),
                title: const Text('Đặt làm địa chỉ mặc định'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(editing ? 'Lưu thay đổi' : 'Thêm địa chỉ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (!required) return null;
        return (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null;
      },
    );
  }
}
