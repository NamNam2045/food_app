import 'package:flutter/material.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  static const _faq = <({String question, String answer})>[
    (
      question: 'Tôi có thể hủy đơn hàng khi nào?',
      answer:
          'Bạn có thể hủy khi đơn đang ở trạng thái Chờ xác nhận hoặc Đã xác nhận. '
          'Khi nhà hàng đã chuẩn bị hoặc shipper đã nhận hàng thì không thể hủy trực tiếp.',
    ),
    (
      question: 'Tôi không thấy mã giảm giá được áp dụng?',
      answer:
          'Hãy kiểm tra điều kiện đơn tối thiểu, thời gian hiệu lực và số lượt sử dụng còn lại của mã.',
    ),
    (
      question: 'Làm sao đổi địa chỉ giao hàng?',
      answer:
          'Vào Hồ sơ > Địa chỉ của tôi để thêm/chỉnh sửa địa chỉ. Bạn có thể chọn địa chỉ giao ở bước checkout.',
    ),
    (
      question: 'Đơn hàng giao chậm thì xử lý thế nào?',
      answer:
          'Bạn có thể theo dõi tiến trình trong màn hình Theo dõi đơn hàng và liên hệ trực tiếp nhà hàng '
          'từ nút hỗ trợ trong chi tiết đơn.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ giúp & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Câu hỏi thường gặp',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ..._faq.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                title: Text(item.question),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(item.answer),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.support_agent),
              title: Text('Hotline hỗ trợ'),
              subtitle: Text('1900 1234 (08:00 - 22:00)'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.mail_outline),
              title: Text('Email hỗ trợ'),
              subtitle: Text('support@foodrush.vn'),
            ),
          ),
        ],
      ),
    );
  }
}
