import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Điều khoản sử dụng')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: const [
          _DocSection(
            title: '1. Chấp nhận điều khoản',
            body:
                'Khi sử dụng FoodRush, bạn đồng ý tuân thủ các điều khoản và chính sách hiện hành của dịch vụ.',
          ),
          _DocSection(
            title: '2. Tài khoản người dùng',
            body:
                'Bạn chịu trách nhiệm bảo mật thông tin đăng nhập và mọi hoạt động phát sinh từ tài khoản của mình.',
          ),
          _DocSection(
            title: '3. Đặt hàng và thanh toán',
            body:
                'Đơn hàng chỉ được xử lý sau khi gửi thành công. Tổng tiền có thể thay đổi nếu bạn cập nhật giỏ hàng '
                'hoặc sử dụng mã khuyến mãi không hợp lệ.',
          ),
          _DocSection(
            title: '4. Hủy đơn và hoàn tiền',
            body:
                'Đơn hàng có thể bị hạn chế hủy theo từng trạng thái xử lý. Hoàn tiền (nếu có) phụ thuộc phương thức thanh toán.',
          ),
          _DocSection(
            title: '5. Giới hạn trách nhiệm',
            body:
                'FoodRush là nền tảng trung gian kết nối người dùng và nhà hàng. Chúng tôi không chịu trách nhiệm trực tiếp '
                'với chất lượng món ăn ngoài phạm vi chính sách dịch vụ.',
          ),
          _DocSection(
            title: '6. Cập nhật điều khoản',
            body:
                'Điều khoản có thể được cập nhật theo thời gian. Phiên bản mới nhất sẽ được công bố trong ứng dụng.',
          ),
          SizedBox(height: 8),
          Text(
            'Cập nhật lần cuối: 30/04/2026',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _DocSection extends StatelessWidget {
  const _DocSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}
